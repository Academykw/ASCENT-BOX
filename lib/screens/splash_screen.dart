import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SplashScreen({
    super.key,
    required this.prefs,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          prefs: widget.prefs,
          isDark: widget.isDark,
          onToggleTheme: widget.onToggleTheme,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldGradient = [AppTheme.primaryGold, AppTheme.accentCoral];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          // Background subtle glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withValues(alpha: 0.05),
              ),
            ),
          ).animate().fadeIn(duration: 1200.ms),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon/Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: goldGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withValues(alpha: 0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 56,
                  ),
                )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .shimmer(
                  delay: 1000.ms,
                  duration: 1800.ms,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                
                const SizedBox(height: 40),
                
                // App Name
                Text(
                  'ASCENT',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                    color: isDark ? Colors.white : AppTheme.darkBg,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                
                const SizedBox(height: 12),
                
                // Tagline
                Text(
                  'DAILY WISDOM • DAILY GROWTH',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: (isDark ? Colors.white : AppTheme.darkBg).withValues(alpha: 0.5),
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 800.ms),
                
                const SizedBox(height: 80),
                
                // Progress Indicator
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGold.withValues(alpha: 0.5),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 1200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
