import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class AffirmationsScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const AffirmationsScreen({super.key, required this.prefs});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentAffirmIndex = 0;

  final Map<String, List<_Affirmation>> _affirmations = {
    'Self-Love': [
      _Affirmation('I am worthy of love and respect exactly as I am.', '💗'),
      _Affirmation('I celebrate my uniqueness and embrace who I am.', '🌸'),
      _Affirmation('I am enough, just as I am, right now.', '✨'),
      _Affirmation('I treat myself with kindness, compassion, and grace.', '🤗'),
      _Affirmation('I deserve all good things that come into my life.', '🌟'),
      _Affirmation('My imperfections make me human and beautifully real.', '💫'),
    ],
    'Confidence': [
      _Affirmation('I walk with confidence knowing I have value to offer.', '👑'),
      _Affirmation('I trust my instincts and make wise decisions.', '🎯'),
      _Affirmation('I am capable of achieving everything I set my mind to.', '💪'),
      _Affirmation('My voice matters and I speak my truth boldly.', '🦁'),
      _Affirmation('I radiate confidence, power, and inner strength.', '⚡'),
    ],
    'Abundance': [
      _Affirmation('I attract wealth, success, and opportunity effortlessly.', '💰'),
      _Affirmation('I am open and receptive to all good that life has to offer.', '🌊'),
      _Affirmation('My income and abundance grow exponentially.', '📈'),
      _Affirmation('I release scarcity and welcome unlimited possibilities.', '🌈'),
      _Affirmation('I deserve financial freedom and abundance in all areas.', '🎊'),
    ],
    'Health': [
      _Affirmation('My body is healthy, strong, and full of energy.', '💪'),
      _Affirmation('I nourish my body with foods that make me thrive.', '🥗'),
      _Affirmation('Every cell in my body is vibrant and alive.', '🌿'),
      _Affirmation('I listen to my body and give it what it needs.', '🧘'),
      _Affirmation('My mind is calm, my body is strong, my spirit is free.', '🕊️'),
    ],
    'Success': [
      _Affirmation('I am on my way to creating the life of my dreams.', '🚀'),
      _Affirmation('I learn from failure and grow stronger every day.', '🌱'),
      _Affirmation('Success flows naturally to me in everything I do.', '🏆'),
      _Affirmation('I have the courage to take bold action toward my goals.', '🎯'),
      _Affirmation('Opportunities are always presenting themselves to me.', '🗝️'),
    ],
    'Peace': [
      _Affirmation('I release all worries and trust in life\'s journey.', '🕊️'),
      _Affirmation('I am at peace with my past and excited for my future.', '🌅'),
      _Affirmation('Calm and serenity fill every moment of my day.', '🌊'),
      _Affirmation('I choose peace over anxiety, love over fear.', '☮️'),
      _Affirmation('My mind is quiet and my heart is full.', '💙'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _affirmations.length, vsync: this);
    _tabController.addListener(() => setState(() => _currentAffirmIndex = 0));
    final saved = widget.prefs.getInt('affirm_index') ?? 0;
    _currentAffirmIndex = saved;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Affirmation> get _currentList =>
      _affirmations.values.elementAt(_tabController.index);

  void _nextAffirmation() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentAffirmIndex = (_currentAffirmIndex + 1) % _currentList.length;
    });
    widget.prefs.setInt('affirm_index', _currentAffirmIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white60 : Colors.black45;
    final categories = _affirmations.keys.toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Affirmations', style: GoogleFonts.playfairDisplay(
                    fontSize: 26, fontWeight: FontWeight.w700, color: textColor,
                  )),
                  Text('Speak it into existence ✨', style: GoogleFonts.lato(
                    fontSize: 13, color: subColor,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              labelStyle: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.lato(fontSize: 13),
              labelColor: AppTheme.accentCoral,
              unselectedLabelColor: subColor,
              indicatorColor: AppTheme.accentCoral,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: categories.map((c) => Tab(text: c)).toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: categories.map((cat) {
                  final list = _affirmations[cat]!;
                  return _AffirmationView(
                    affirmations: list,
                    currentIndex: _currentAffirmIndex.clamp(0, list.length - 1),
                    onNext: _nextAffirmation,
                    isDark: isDark,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AffirmationView extends StatelessWidget {
  final List<_Affirmation> affirmations;
  final int currentIndex;
  final VoidCallback onNext;
  final bool isDark;

  const _AffirmationView({
    required this.affirmations,
    required this.currentIndex,
    required this.onNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final affirm = affirmations[currentIndex];
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onNext,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentCoral.withOpacity(isDark ? 0.15 : 0.08),
                      AppTheme.accentPurple.withOpacity(isDark ? 0.15 : 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.accentCoral.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(affirm.emoji, style: const TextStyle(fontSize: 64))
                        .animate(key: ValueKey(currentIndex))
                        .scale(duration: 300.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        affirm.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.5,
                        ),
                      ).animate(key: ValueKey(currentIndex))
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Tap to see next affirmation',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(affirmations.length, (i) {
              final active = i == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.accentCoral
                      : (isDark ? Colors.white24 : Colors.black12),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  color: AppTheme.accentPurple,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: affirmations[currentIndex].text));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Copied! ✨', style: GoogleFonts.lato()),
                      backgroundColor: AppTheme.accentPurple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.skip_next_rounded,
                  label: 'Next',
                  color: AppTheme.accentCoral,
                  onTap: onNext,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.lato(
              fontSize: 14, fontWeight: FontWeight.w700, color: color,
            )),
          ],
        ),
      ),
    );
  }
}

class _Affirmation {
  final String text;
  final String emoji;
  const _Affirmation(this.text, this.emoji);
}
