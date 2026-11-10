import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'splash_screen.dart';
import 'member3_hub_screen.dart';

/// Run: flutter run -t lib/member3_team_main.dart
/// Uses Member 1's original SplashScreen, with a temporary Member 3
/// quick-launch shortcut. Never edits any file owned by other members.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Member3TeamApp());
}

class Member3TeamApp extends StatefulWidget {
  const Member3TeamApp({super.key});

  @override
  State<Member3TeamApp> createState() => _Member3TeamAppState();
}

class _Member3TeamAppState extends State<Member3TeamApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _openMember3() {
    _navigatorKey.currentState?.push<void>(
      MaterialPageRoute<void>(builder: (_) => const Member3HubScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: const SplashScreen(),
      builder: (context, child) => Stack(
        children: [
          child ?? const SizedBox.shrink(),
          Positioned(
            right: 12,
            bottom: 94,
            child: SafeArea(
              child: FloatingActionButton.small(
                heroTag: 'member3_team_quick_launch',
                tooltip: 'Open Member 3',
                onPressed: _openMember3,
                child: const Icon(Icons.movie_filter_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
