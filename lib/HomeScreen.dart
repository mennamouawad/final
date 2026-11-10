import 'dart:async';

import 'package:flutter/material.dart';

import 'search_screen.dart';
import 'ProfileScreen.dart';
import 'member3_bridge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color yellow = Color(0xFFF6BD00);
  static const Color bg = Color(0xFF121312);

  final PageController _controller = PageController(
    viewportFraction: 0.62,
    initialPage: 1000,
  );

  Timer? _timer;

  // MAIN CAROUSEL MOVIES
  final List<String> movies = [
    'assets/movie1.jpg',
    'assets/onboarding6.png',
    'assets/movie2.jpg',
  ];

  // ACTION MOVIES
  final List<String> actionMovies = [
    'assets/movie2.jpg',
    'assets/movie3.jpg',
    'assets/movie4.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 3),
          (timer) {
        if (_controller.hasClients) {
          _controller.nextPage(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ==========================================
  // MEMBER 3 INTEGRATION
  // ==========================================

  Future<void> openMoviePicker() async {
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose a Movie',
                  style: TextStyle(
                    color: yellow,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Select a movie to view its details',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),

                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableMovies.length,
                    itemBuilder: (context, index) {
                      final movie = availableMovies[index];

                      return Card(
                        color: const Color(0xFF282A28),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(
                            Icons.movie,
                            color: yellow,
                          ),
                          title: Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: yellow,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pop(
                              sheetContext,
                              movie.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
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
  }

  Future<void> openSavedMovies() async {
    await Member3Bridge.openSavedMovies(context);
  }

  // ==========================================
  // RATING BADGE
  // ==========================================

  Widget ratingBadge(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.012,
      ),
      decoration: BoxDecoration(
        color: const Color(0xCC282A28),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '7.7',
            style: TextStyle(
              color: Colors.white,
              fontSize:
              (screenWidth * 0.035).clamp(11.0, 17.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.012,
          ),
          Icon(
            Icons.star,
            color: yellow,
            size:
            (screenWidth * 0.045).clamp(14.0, 22.0),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MAIN MOVIE CARD
  // ==========================================

  Widget mainMovieCard({
    required String image,
    required double width,
    required double height,
    required double screenWidth,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: openMoviePicker,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            screenWidth * 0.045,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                image,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: screenWidth * 0.025,
                left: screenWidth * 0.025,
                child: ratingBadge(screenWidth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ACTION MOVIE CARD
  // ==========================================

  Widget actionMovieCard({
    required String image,
    required double width,
    required double height,
    required double screenWidth,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: openMoviePicker,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.only(
          right: screenWidth * 0.035,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            screenWidth * 0.045,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                image,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: screenWidth * 0.025,
                left: screenWidth * 0.025,
                child: ratingBadge(screenWidth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final horizontalPadding = screenWidth * 0.035;

    // MAIN CAROUSEL
    final carouselWidth = screenWidth * 0.62;

    final carouselHeight =
    (carouselWidth * 1.48).clamp(280.0, 650.0);

    // ACTION CARDS
    final actionCardWidth =
    (screenWidth * 0.35).clamp(110.0, 220.0);

    final actionCardHeight = actionCardWidth * 1.55;

    // BOTTOM NAVIGATION
    final bottomNavHeight =
    (screenHeight * 0.065).clamp(58.0, 85.0);

    final availableWidth =
        screenWidth - (horizontalPadding * 2);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ==========================================
          // BACKGROUND IMAGE
          // ==========================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.68,
            child: Image.asset(
              'assets/onboarding6.png',
              width: screenWidth,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // ==========================================
          // BACKGROUND GRADIENT
          // ==========================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.75,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.0,
                    0.465,
                    1.0,
                  ],
                  colors: [
                    Color.fromRGBO(18, 19, 18, 0.80),
                    Color.fromRGBO(18, 19, 18, 0.60),
                    Color(0xFF121312),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // MAIN CONTENT
          // ==========================================

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.018,
                        ),

                        // ==================================
                        // AVAILABLE NOW
                        // ==================================

                        Center(
                          child: Image.asset(
                            'assets/available_now.png',
                            width: screenWidth * 0.66,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.025,
                        ),

                        // ==================================
                        // MAIN CAROUSEL
                        // ==================================

                        SizedBox(
                          width: screenWidth,
                          height: carouselHeight,
                          child: PageView.builder(
                            controller: _controller,
                            itemBuilder: (context, index) {
                              final movie =
                              movies[index % movies.length];

                              return AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  double page = _controller
                                      .initialPage
                                      .toDouble();

                                  if (_controller.position
                                      .haveDimensions) {
                                    page = _controller.page ??
                                        _controller.initialPage
                                            .toDouble();
                                  }

                                  final distance =
                                  (page - index).abs();

                                  final scale =
                                  (1 - distance * 0.22)
                                      .clamp(0.78, 1.0);

                                  return Center(
                                    child: Transform.scale(
                                      scale: scale,
                                      child: child,
                                    ),
                                  );
                                },
                                child: mainMovieCard(
                                  image: movie,
                                  width: carouselWidth,
                                  height: carouselHeight,
                                  screenWidth: screenWidth,
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.035,
                        ),

                        // ==================================
                        // WATCH NOW
                        // ==================================

                        Center(
                          child: Image.asset(
                            'assets/watch_now.png',
                            width: screenWidth * 0.88,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.045,
                        ),

                        // ==================================
                        // ACTION HEADER
                        // ==================================

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Action',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),

                              const Spacer(),

                              TextButton(
                                onPressed: openMoviePicker,
                                child: const Text(
                                  'See More →',
                                  style: TextStyle(
                                    color: yellow,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.008,
                        ),

                        // ==================================
                        // ACTION MOVIES
                        // ==================================

                        SizedBox(
                          height: actionCardHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics:
                            const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            itemCount: actionMovies.length,
                            itemBuilder: (context, index) {
                              return actionMovieCard(
                                image: actionMovies[index],
                                width: actionCardWidth,
                                height: actionCardHeight,
                                screenWidth: screenWidth,
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.025,
                        ),
                      ],
                    ),
                  ),
                ),

                // ==========================================
                // BOTTOM NAVIGATION
                // ==========================================

                Container(
                  width: availableWidth,
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
                      // HOME - ACTIVE
                      Icon(
                        Icons.home,
                        color: yellow,
                        size: screenWidth * 0.065,
                      ),

                      // SEARCH
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const SearchScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: screenWidth * 0.065,
                        ),
                      ),

                      // EXPLORE / SAVED MOVIES
                      IconButton(
                        onPressed: openSavedMovies,
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
        ],
      ),
    );
  }
}