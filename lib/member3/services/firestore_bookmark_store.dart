import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import 'bookmark_store.dart';

/// Real persistent Firebase implementation used AFTER Member 1 has
/// initialized Firebase and the user has signed in.
class FirestoreBookmarkStore extends BookmarkStore {
  final FirebaseFirestore _firestore;
  final String uid;

  FirestoreBookmarkStore({
    required this.uid,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(BookmarkType type) =>
      _firestore.collection('users').doc(uid).collection(type.name);

  @override
  Stream<List<Movie>> watchMovies(BookmarkType type) =>
      _collection(type).snapshots().map((snapshot) => snapshot.docs
          .map((doc) => Movie.fromSavedJson(doc.data()))
          .toList());

  @override
  Future<void> toggle(Movie movie, BookmarkType type) async {
    final ref = _collection(type).doc('${movie.id}');
    final existing = await ref.get();
    if (existing.exists) {
      await ref.delete();
    } else {
      await ref.set({
        ...movie.toSavedJson(),
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> remove(int movieId, BookmarkType type) async {
    await _collection(type).doc('$movieId').delete();
  }
}
