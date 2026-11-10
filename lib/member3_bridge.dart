import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'member3/screens/movie_details_screen.dart';
import 'member3/screens/saved_movies_screen.dart';
import 'member3/services/bookmark_store.dart';
import 'member3/services/demo_bookmark_store.dart';
import 'member3/services/firestore_bookmark_store.dart';
import 'member3/services/yts_movie_service.dart';

/// Public integration API for the other two team members.
/// Does not modify their files. Member 2 passes a numeric YTS movie ID.
class Member3Bridge {
  Member3Bridge._();

  static final YtsMovieService movieService = YtsMovieService();
  static final DemoBookmarkStore _demoBookmarks = DemoBookmarkStore();
  static final Map<String, FirestoreBookmarkStore> _userStores = {};

  static bool get isFirebaseReady {
    if (Firebase.apps.isEmpty) return false;
    return FirebaseAuth.instance.currentUser != null;
  }

  static BookmarkStore get bookmarks {
    if (!isFirebaseReady) return _demoBookmarks;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _userStores.putIfAbsent(uid, () => FirestoreBookmarkStore(uid: uid));
  }

  static Future<void> openDetails(BuildContext context, int movieId) async {
    if (movieId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid movie ID')),
      );
      return;
    }
    final store = bookmarks;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MovieDetailsScreen(
          movieId: movieId,
          movieService: movieService,
          bookmarks: store,
        ),
      ),
    );
  }

  static Future<void> openSavedMovies(BuildContext context) async {
    final store = bookmarks;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SavedMoviesScreen(
          movieService: movieService,
          bookmarks: store,
        ),
      ),
    );
  }
}
