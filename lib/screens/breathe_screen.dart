import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key});

  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleAnim;
  bool _isRunning = false;
  int _phase = 0; // 0=idle, 1=inhale, 2=hold, 3=exhale, 4=hold2
  String _phaseLabel = 'Tap to Begin';
  String _selectedPattern = '4-7-8';
  int _cycleCount = 0;

  final Map<String, List<int>> _patterns = {
    '4-7-8': [4, 7, 8, 0],
    'Box': [4, 4, 4, 4],
    '4-4-4': [4, 0, 4, 0],
    'Calming': [6, 0, 9, 0],
  };

  final Map<String, String> _patternDesc = {
    '4-7-8': 'Inhale 4s · Hold 7s · Exhale 8s',
    'Box': 'Inhale 4s · Hold 4s · Exhale 4s · Hold 4s',
    '4-4-4': 'Inhale 4s · Exhale 4s (energizing)',
    'Calming': 'Inhale 6s · Exhale 9s (deep calm)',
  };

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _circleAnim = CurvedAnimation(parent: _circleController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  void _startBreathing() async {
    setState(() => _isRunning = true);
    _runCycle();
  }

  void _stopBreathing() {
    _circleController.stop();
    setState(() {
      _isRunning = false;
      _phase = 0;
      _phaseLabel = 'Tap to Begin';
    });
  }

  void _runCycle() async {
    if (!_isRunning) return;
    final pattern = _patterns[_selectedPattern]!;

    // Inhale
    final inhaleSecs = pattern[0];
    setState(() { _phase = 1; _phaseLabel = 'Inhale'; });
    _circleController.duration = Duration(seconds: inhaleSecs);
    await _circleController.animateTo(1.0);
    if (!_isRunning) return;

    // Hold after inhale
    if (pattern[1] > 0) {
      setState(() { _phase = 2; _phaseLabel = 'Hold'; });
      await Future.delayed(Duration(seconds: pattern[1]));
      if (!_isRunning) return;
    }

    // Exhale
    final exhaleSecs = pattern[2];
    setState(() { _phase = 3; _phaseLabel = 'Exhale'; });
    _circleController.duration = Duration(seconds: exhaleSecs);
    await _circleController.animateTo(0.0);
    if (!_isRunning) return;

    // Hold after exhale
    if (pattern[3] > 0) {
      setState(() { _phase = 4; _phaseLabel = 'Hold'; });
      await Future.delayed(Duration(seconds: pattern[3]));
      if (!_isRunning) return;
    }

    setState(() => _cycleCount++);
    _runCycle();
  }

  Color get _phaseColor {
    switch (_phase) {
      case 1: return AppTheme.accentMint;
      case 2: return AppTheme.primaryGold;
      case 3: return AppTheme.accentCoral;
      case 4: return AppTheme.accentPurple;
      default: return AppTheme.primaryGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white60 : Colors.black45;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Breathe', style: GoogleFonts.playfairDisplay(
                fontSize: 26, fontWeight: FontWeight.w700, color: textColor,
              )),
              Text('Find your calm 🌊', style: GoogleFonts.lato(
                fontSize: 13, color: subColor,
              )),
              const SizedBox(height: 20),
              // Pattern selector
              Row(
                children: _patterns.keys.map((pat) {
                  final sel = pat == _selectedPattern;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: _isRunning ? null : () => setState(() => _selectedPattern = pat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.accentMint
                              : (isDark ? AppTheme.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: sel ? [
                            BoxShadow(
                              color: AppTheme.accentMint.withOpacity(0.3),
                              blurRadius: 12, offset: const Offset(0, 4),
                            ),
                          ] : null,
                        ),
                        child: Text(pat, style: GoogleFonts.lato(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : subColor,
                        )),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                _patternDesc[_selectedPattern] ?? '',
                style: GoogleFonts.lato(fontSize: 12, color: subColor),
              ),
              // Main breathing circle
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _isRunning ? _stopBreathing : _startBreathing,
                    child: AnimatedBuilder(
                      animation: _circleAnim,
                      builder: (_, __) {
                        final scale = 0.6 + _circleAnim.value * 0.4;
                        final color = _phaseColor;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow rings
                            ...List.generate(3, (i) => Container(
                              width: 260 * scale + (i * 20),
                              height: 260 * scale + (i * 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withOpacity(0.03 - i * 0.008),
                              ),
                            )),
                            // Main circle
                            Container(
                              width: 260 * scale,
                              height: 260 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    color.withOpacity(0.6),
                                    color.withOpacity(0.15),
                                  ],
                                ),
                                border: Border.all(
                                  color: color.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.2 + _circleAnim.value * 0.2),
                                    blurRadius: 40 + _circleAnim.value * 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      _phaseLabel,
                                      key: ValueKey(_phaseLabel),
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                  if (_isRunning) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Cycle $_cycleCount',
                                      style: GoogleFonts.lato(fontSize: 13, color: subColor),
                                    ),
                                  ],
                                  if (!_isRunning) ...[
                                    const SizedBox(height: 8),
                                    Icon(
                                      Icons.play_circle_outline_rounded,
                                      size: 32,
                                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Benefits cards
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _BenefitCard('Reduces Anxiety', '🧠', AppTheme.accentMint, isDark),
                    _BenefitCard('Lowers HR', '❤️', AppTheme.accentCoral, isDark),
                    _BenefitCard('Improves Focus', '🎯', AppTheme.primaryGold, isDark),
                    _BenefitCard('Better Sleep', '😴', AppTheme.accentPurple, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isRunning)
                Center(
                  child: GestureDetector(
                    onTap: _stopBreathing,
                    child: Text(
                      'Tap circle or here to stop',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: subColor,
                        decoration: TextDecoration.underline,
                        decorationColor: subColor,
                      ),
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

class _BenefitCard extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isDark;

  const _BenefitCard(this.label, this.emoji, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.lato(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: color,
          )),
        ],
      ),
    );
  }
}
