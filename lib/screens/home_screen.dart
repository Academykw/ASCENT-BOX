import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quote_screen.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';
import 'affirmations_screen.dart';
import 'breathe_screen.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.prefs,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      QuoteScreen(prefs: widget.prefs),
      HabitsScreen(prefs: widget.prefs),
      JournalScreen(prefs: widget.prefs),
      AffirmationsScreen(prefs: widget.prefs),
      BreatheScreen(),
    ];
  }

  final _navItems = const [
    _NavItem(icon: Icons.format_quote_rounded, label: 'Quotes'),
    _NavItem(icon: Icons.check_circle_outline_rounded, label: 'Habits'),
    _NavItem(icon: Icons.book_outlined, label: 'Journal'),
    _NavItem(icon: Icons.favorite_outline_rounded, label: 'Affirm'),
    _NavItem(icon: Icons.air_rounded, label: 'Breathe'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final surfaceColor = isDark ? AppTheme.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isSelected = i == _currentIndex;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryGold.withOpacity(isDark ? 0.2 : 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? AppTheme.primaryGold
                              : (isDark ? Colors.white38 : Colors.black38),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected
                                ? AppTheme.primaryGold
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: widget.onToggleTheme,
        backgroundColor: AppTheme.primaryGold,
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
