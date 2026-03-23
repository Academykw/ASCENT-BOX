import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';

class HabitsScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const HabitsScreen({super.key, required this.prefs});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Habit> _habits = [];

  final List<Map<String, String>> _presets = [
    {'name': 'Morning Workout', 'emoji': '🏋️', 'color': '0xFFFF6B6B'},
    {'name': 'Read 30 Minutes', 'emoji': '📚', 'color': '0xFF4ECDC4'},
    {'name': 'Meditate', 'emoji': '🧘', 'color': '0xFF9B59B6'},
    {'name': 'Drink Water', 'emoji': '💧', 'color': '0xFF2196F3'},
    {'name': 'No Sugar', 'emoji': '🚫🍬', 'color': '0xFF44CF6C'},
    {'name': 'Journal', 'emoji': '✍️', 'color': '0xFFE8B86D'},
    {'name': 'Cold Shower', 'emoji': '🚿', 'color': '0xFF00BCD4'},
    {'name': 'Sleep by 11pm', 'emoji': '😴', 'color': '0xFF3F51B5'},
  ];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    final data = widget.prefs.getStringList('habits') ?? [];
    setState(() {
      _habits = data
          .map((s) => Habit.fromJson(json.decode(s) as Map<String, dynamic>))
          .toList();
    });
  }

  void _saveHabits() {
    widget.prefs.setStringList(
      'habits',
      _habits.map((h) => json.encode(h.toJson())).toList(),
    );
  }

  void _toggleToday(int index) {
    HapticFeedback.mediumImpact();
    final habit = _habits[index];
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final dates = [...habit.completedDates];
    if (dates.contains(todayStr)) {
      dates.remove(todayStr);
    } else {
      dates.add(todayStr);
    }
    setState(() => _habits[index] = habit.copyWith(completedDates: dates));
    _saveHabits();
  }

  void _addHabit(Habit h) {
    setState(() => _habits.add(h));
    _saveHabits();
  }

  void _deleteHabit(int index) {
    setState(() => _habits.removeAt(index));
    _saveHabits();
  }

  int get _completedToday =>
      _habits.where((h) => h.isCompletedToday()).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white60 : Colors.black45;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;

    final progress = _habits.isEmpty ? 0.0 : _completedToday / _habits.length;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Habit Tracker', style: GoogleFonts.playfairDisplay(
                          fontSize: 26, fontWeight: FontWeight.w700, color: textColor,
                        )),
                        GestureDetector(
                          onTap: _showAddDialog,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_todayDate(), style: GoogleFonts.lato(fontSize: 13, color: subColor)),
                    const SizedBox(height: 20),
                    // Progress card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8B86D), Color(0xFFFF6B6B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGold.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_completedToday / ${_habits.length} habits',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _progressLabel(progress),
                            style: GoogleFonts.lato(fontSize: 13, color: Colors.white70),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),
                    if (_habits.isEmpty)
                      _EmptyState(onAdd: _showAddDialog, isDark: isDark),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final habit = _habits[i];
                    final completed = habit.isCompletedToday();
                    final color = Color(int.parse(habit.color));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key(habit.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteHabit(i),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                        child: GestureDetector(
                          onTap: () => _toggleToday(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: completed
                                  ? color.withOpacity(isDark ? 0.2 : 0.12)
                                  : cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: completed ? color.withOpacity(0.4) : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(habit.emoji, style: const TextStyle(fontSize: 22)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.name,
                                        style: GoogleFonts.lato(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                          decoration: completed ? TextDecoration.lineThrough : null,
                                          decorationColor: color,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.local_fire_department_rounded,
                                              size: 14, color: color),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${habit.currentStreak} day streak',
                                            style: GoogleFonts.lato(
                                              fontSize: 12, color: color, fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.check_circle_outline_rounded,
                                              size: 14, color: subColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${habit.totalCompleted} total',
                                            style: GoogleFonts.lato(fontSize: 12, color: subColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: completed ? color : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: completed ? color : (isDark ? Colors.white24 : Colors.black12),
                                      width: 2,
                                    ),
                                  ),
                                  child: completed
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
                  },
                  childCount: _habits.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  String _progressLabel(double p) {
    if (p == 0) return 'Let\'s get started! 💪';
    if (p < 0.5) return 'Keep going, you\'re doing great!';
    if (p < 1) return 'Almost there! 🔥';
    return 'Perfect day! You crushed it! 🎉';
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddHabitSheet(
        presets: _presets,
        onAdd: _addHabit,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  final List<Map<String, String>> presets;
  final Function(Habit) onAdd;
  final bool isDark;

  const _AddHabitSheet({required this.presets, required this.onAdd, required this.isDark});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _controller = TextEditingController();
  String _selectedEmoji = '⭐';
  String _selectedColor = '0xFFE8B86D';

  final _emojis = ['⭐', '🏃', '🧘', '📚', '💪', '🎯', '🎨', '🎵', '🍎', '💧', '🌿', '❤️'];
  final _colors = ['0xFFE8B86D', '0xFFFF6B6B', '0xFF4ECDC4', '0xFF9B59B6', '0xFF44CF6C', '0xFF2196F3'];

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppTheme.darkSurface : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add New Habit', style: GoogleFonts.playfairDisplay(
            fontSize: 22, fontWeight: FontWeight.w700, color: textColor,
          )),
          const SizedBox(height: 16),
          // Presets
          Wrap(
            spacing: 8, runSpacing: 8,
            children: widget.presets.map((p) => GestureDetector(
              onTap: () {
                _controller.text = p['name']!;
                setState(() {
                  _selectedEmoji = p['emoji']!;
                  _selectedColor = p['color']!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(int.parse(p['color']!)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(int.parse(p['color']!)).withOpacity(0.3)),
                ),
                child: Text('${p['emoji']} ${p['name']}',
                  style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600,
                    color: Color(int.parse(p['color']!))),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            style: GoogleFonts.lato(color: textColor),
            decoration: InputDecoration(
              hintText: 'Habit name...',
              hintStyle: GoogleFonts.lato(color: widget.isDark ? Colors.white38 : Colors.black38),
              filled: true,
              fillColor: widget.isDark ? AppTheme.darkCard : AppTheme.lightCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Emoji selector
          Wrap(
            spacing: 8,
            children: _emojis.map((e) => GestureDetector(
              onTap: () => setState(() => _selectedEmoji = e),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: e == _selectedEmoji
                      ? AppTheme.primaryGold.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: e == _selectedEmoji
                      ? Border.all(color: AppTheme.primaryGold)
                      : null,
                ),
                child: Text(e, style: const TextStyle(fontSize: 22)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          // Color selector
          Row(
            children: _colors.map((c) {
              final color = Color(int.parse(c));
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: c == _selectedColor
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: c == _selectedColor
                          ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isEmpty) return;
                widget.onAdd(Habit(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _controller.text.trim(),
                  emoji: _selectedEmoji,
                  color: _selectedColor,
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Add Habit', style: GoogleFonts.lato(
                fontSize: 15, fontWeight: FontWeight.w700,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final bool isDark;
  const _EmptyState({required this.onAdd, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Text('🌱', style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('No habits yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text('Add your first habit to start building\nyour best self.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 14, color: isDark ? Colors.white60 : Colors.black45),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Add First Habit', style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
