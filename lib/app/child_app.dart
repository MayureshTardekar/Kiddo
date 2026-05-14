import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/splash_screen.dart';

class ChildApp extends StatelessWidget {
  const ChildApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        primary: const Color(0xFF6C63FF),
        secondary: const Color(0xFFFF6B9A),
        tertiary: const Color(0xFF00C2A8),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Kiddo Adventure',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF8FBFF),
        textTheme: GoogleFonts.comicNeueTextTheme(baseTheme.textTheme).apply(
          bodyColor: const Color(0xFF24304F),
          displayColor: const Color(0xFF24304F),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE9E7FF),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
