import 'package:flutter/material.dart';

import 'ProfileScreen.dart';
import 'HomeScreen.dart';
import 'member3_bridge.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color yellow = Color(0xFFF6BD00);
  static const Color bg = Color(0xFF121312);

  final TextEditingController searchController = TextEditingController();

  bool showMovies = false;

  final List<String> movies = [
    'assets/search1.png',
    'assets/search2.jpg',
    'assets/search3.jpg',
    'assets/search4.jpg',
    'assets/search5.jpg',
    'assets/search6.jpg',
  ];

  // =========================================
  // OPEN MOVIE DETAILS - MEMBER 3
  // =========================================

  Future<void> openMoviePicker() async {
    try {
      final availableMovies =
      await Member3Bridge.movieService.listDemoMovies();

      if (!mounted) return;

      if (availableMovies.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No movies available'),
          ),
        );
        return;
      }

      final selectedId = await showModalBottomSheet<int>(
        context: context,
        backgroundColor: bg,
        isScrollControlled: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: MediaQuery.sizeOf(sheetContext).height * 0.55,
                child: Column(
                  children: [
                    const Text(
                      'Choose a Movie',
                      style: TextStyle(
                        color: yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: ListView.builder(
                        itemCount: availableMovies.length,
                        itemBuilder: (context, index) {
                          final movie = availableMovies[index];

                          return ListTile(
                            title: Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: yellow,
                            ),
                            onTap: () {
                              Navigator.pop(
                                sheetContext,
                                movie.id,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      if (!mounted || selectedId == null) return;

      await Member3Bridge.openDetails(
        context,
        selectedId,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load movies: $error',
          ),
        ),
      );
    }
  }

  // =========================================
  // SEARCH FUNCTION
  // =========================================

  void searchMovies(String value) {
    setState(() {
      showMovies = value.trim().toLowerCase() == 'marvel';
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final horizontalPadding = screenWidth * 0.04;

    final bottomNavHeight =
    (screenHeight * 0.065).clamp(58.0, 85.0);

    return Scaffold(
      backgroundColor: bg,

      body: SafeArea(
        child: Column(
          children: [
            // =================================
            // SEARCH BAR
            // =================================

            Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 21,
              ),
              child: Container(
                height: 55.72,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF282A28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: searchMovies,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        cursorColor: yellow,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =================================
            // MOVIES GRID / EMPTY IMAGE
            // =================================

            Expanded(
              child: showMovies
                  ? LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth =
                      constraints.maxWidth -
                          (horizontalPadding * 2);

                  final itemWidth =
                      (availableWidth - 12) / 2;

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      10,
                      horizontalPadding,
                      10,
                    ),

                    itemCount: movies.length,

                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                      itemWidth / (itemWidth / 0.68),
                    ),

                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: openMoviePicker,

                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(14),

                          child: Stack(
                            children: [
                              // MOVIE IMAGE

                              Positioned.fill(
                                child: Image.asset(
                                  movies[index],
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // MOVIE RATING

                              Positioned(
                                top: 8,
                                left: 8,

                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withOpacity(0.65),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),

                                  child: const Row(
                                    mainAxisSize:
                                    MainAxisSize.min,

                                    children: [
                                      Text(
                                        '7.7',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),

                                      SizedBox(width: 4),

                                      Icon(
                                        Icons.star,
                                        color: yellow,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              )

                  : Center(
                child: Image.asset(
                  'assets/Empty.png',
                  width: screenWidth * 0.30,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // =================================
            // BOTTOM NAVIGATION
            // =================================

            Container(
              width: screenWidth -
                  (horizontalPadding * 2),

              height: bottomNavHeight,

              margin: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: screenHeight * 0.008,
                bottom: screenHeight * 0.008,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFF282A28),
                borderRadius: BorderRadius.circular(
                  screenWidth * 0.045,
                ),
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,

                children: [
                  // HOME

                  IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const HomeScreen(),
                        ),
                            (route) => false,
                      );
                    },

                    icon: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: screenWidth * 0.065,
                    ),
                  ),

                  // SEARCH ACTIVE

                  Icon(
                    Icons.search,
                    color: yellow,
                    size: screenWidth * 0.065,
                  ),

                  // EXPLORE - SAVED MOVIES

                  IconButton(
                    onPressed: () {
                      Member3Bridge.openSavedMovies(context);
                    },

                    icon: Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: screenWidth * 0.065,
                    ),
                  ),

                  // PROFILE

                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const ProfileScreen(),
                        ),
                      );
                    },

                    icon: Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: screenWidth * 0.065,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}