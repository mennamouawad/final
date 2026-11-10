import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'HomeScreen.dart';
import 'search_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color yellow = Color(0xFFF6BD00);
  static const Color bg = Color(0xFF111111);
  static const Color topBg = Color(0xFF212121);

  int selectedTab = 0;

  final List<String> historyMovies = [
    'assets/search1.png',
    'assets/search2.jpg',
    'assets/search3.jpg',
    'assets/search4.jpg',
    'assets/search5.jpg',
    'assets/search6.jpg',
    'assets/movie1.jpg',
    'assets/movie2.jpg',
    'assets/movie3.jpg',
    'assets/movie4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final horizontalPadding = screenWidth * 0.04;

    final bottomNavHeight =
    (screenHeight * 0.065).clamp(58.0, 85.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: topBg,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [

              // TOP SECTION - FULL WIDTH
              Container(
                width: double.infinity,
                color: topBg,
                child: Column(
                  children: [

                    // PROFILE INFORMATION
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(12),
                      color: topBg,
                      child: Column(
                        children: [
                          Row(
                            children: [

                              // PROFILE IMAGE
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: screenWidth * 0.105,
                                      backgroundColor:
                                      const Color(0xFF82D7E8),
                                      backgroundImage:
                                      const AssetImage(
                                        'assets/Avatar2.png',
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      'John Safwat',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // WISH LIST
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: const [
                                    Text(
                                      '0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      'Wish List',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // HISTORY
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: const [
                                    Text(
                                      '10',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      'History',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // EDIT PROFILE + EXIT
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Edit Profile will be connected later
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: yellow,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Edit Profile',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: SizedBox(
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFFEB2525),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text('Exit'),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.logout,
                                          size: 17,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // WATCH LIST / HISTORY TABS
                    SizedBox(
                      width: double.infinity,
                      height: 66,
                      child: Row(
                        children: [

                          // WATCH LIST
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedTab = 0;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: selectedTab == 0
                                          ? yellow
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.list,
                                      color: selectedTab == 0
                                          ? yellow
                                          : Colors.white,
                                      size: 25,
                                    ),

                                    const SizedBox(height: 3),

                                    const Text(
                                      'Watch List',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // HISTORY
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedTab = 1;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: selectedTab == 1
                                          ? yellow
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      color: selectedTab == 1
                                          ? yellow
                                          : Colors.white,
                                      size: 25,
                                    ),

                                    const SizedBox(height: 3),

                                    const Text(
                                      'History',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM SECTION
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: bg,
                  child: Column(
                    children: [

                      // TAB CONTENT
                      Expanded(
                        child: selectedTab == 0

                        // WATCH LIST EMPTY
                            ? Center(
                          child: Image.asset(
                            'assets/Empty.png',
                            width: screenWidth * 0.30,
                            fit: BoxFit.contain,
                          ),
                        )

                        // HISTORY GRID
                            : GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            14,
                            horizontalPadding,
                            14,
                          ),
                          itemCount: historyMovies.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: Stack(
                                children: [

                                  // MOVIE POSTER
                                  Positioned.fill(
                                    child: Image.asset(
                                      historyMovies[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // RATING
                                  Positioned(
                                    top: 7,
                                    left: 6,
                                    child: Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.65),
                                        borderRadius:
                                        BorderRadius.circular(7),
                                      ),
                                      child: const Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          Text(
                                            '7.7',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),

                                          SizedBox(width: 2),

                                          Icon(
                                            Icons.star,
                                            color: yellow,
                                            size: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // BOTTOM NAVIGATION
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

                            // EXPLORE
                            IconButton(
                              onPressed: () {
                                // Explore page will be connected later
                              },
                              icon: Icon(
                                Icons.explore,
                                color: Colors.white,
                                size: screenWidth * 0.065,
                              ),
                            ),

                            // PROFILE ACTIVE
                            Icon(
                              Icons.person_outline,
                              color: yellow,
                              size: screenWidth * 0.065,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
