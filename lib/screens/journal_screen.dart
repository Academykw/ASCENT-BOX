import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../utils/app_theme.dart';

class JournalScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const JournalScreen({super.key, required this.prefs});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    final data = widget.prefs.getStringList('journal_entries') ?? [];
    setState(() {
      _entries = data
          .map((s) => JournalEntry.fromJson(json.decode(s) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _saveEntries() {
    widget.prefs.setStringList(
      'journal_entries',
      _entries.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  void _addEntry(JournalEntry entry) {
    setState(() => _entries.insert(0, entry));
    _saveEntries();
  }

  void _deleteEntry(String id) {
    setState(() => _entries.removeWhere((e) => e.id == id));
    _saveEntries();
  }

  double get _avgMood {
    if (_entries.isEmpty) return 0;
    return _entries.map((e) => e.mood).reduce((a, b) => a + b) / _entries.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white60 : Colors.black45;

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
                        Text('My Journal', style: GoogleFonts.playfairDisplay(
                          fontSize: 26, fontWeight: FontWeight.w700, color: textColor,
                        )),
                        GestureDetector(
                          onTap: _showWriteDialog,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentMint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Reflect, feel, grow', style: GoogleFonts.lato(fontSize: 13, color: subColor)),
                    const SizedBox(height: 20),
                    if (_entries.isNotEmpty) _buildMoodSummary(isDark, subColor),
                    const SizedBox(height: 16),
                    if (_entries.isEmpty) _buildEmptyState(isDark),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final entry = _entries[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key(entry.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteEntry(entry.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                        child: _JournalCard(entry: entry, isDark: isDark, index: i),
                      ),
                    ).animate(delay: (i * 40).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
                  },
                  childCount: _entries.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSummary(bool isDark, Color subColor) {
    final moodColors = {
      1: AppTheme.accentCoral,
      2: Colors.orange,
      3: Colors.amber,
      4: AppTheme.accentMint,
      5: const Color(0xFF44CF6C),
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mood Overview', style: GoogleFonts.lato(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              )),
              Text('${_entries.length} entries', style: GoogleFonts.lato(
                fontSize: 12, color: subColor,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [1, 2, 3, 4, 5].map((mood) {
              final count = _entries.where((e) => e.mood == mood).length;
              final color = moodColors[mood]!;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: double.infinity,
                          height: _entries.isEmpty ? 4 : (count / _entries.length * 36 + 4).clamp(4.0, 40.0),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        JournalEntry(id: '', content: '', mood: mood, date: '').moodEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Text('✍️', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('Start your story',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text('Write your first journal entry.\nCapture your thoughts and feelings.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 14, color: isDark ? Colors.white60 : Colors.black45),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showWriteDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentMint,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Write First Entry', style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showWriteDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WriteEntrySheet(
        onSave: _addEntry,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final bool isDark;
  final int index;

  const _JournalCard({required this.entry, required this.isDark, required this.index});

  @override
  Widget build(BuildContext context) {
    final moodColors = [
      AppTheme.accentCoral,
      Colors.orange,
      Colors.amber,
      AppTheme.accentMint,
      const Color(0xFF44CF6C),
    ];
    final color = moodColors[(entry.mood - 1).clamp(0, 4)];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(entry.moodEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(entry.moodLabel, style: GoogleFonts.lato(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color,
                  )),
                ],
              ),
              Text(_formatDate(entry.date), style: GoogleFonts.lato(
                fontSize: 12, color: isDark ? Colors.white38 : Colors.black38,
              )),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF4A4A4A),
              height: 1.5,
            ),
          ),
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: entry.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('#$tag', style: GoogleFonts.lato(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600,
                )),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month-1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _WriteEntrySheet extends StatefulWidget {
  final Function(JournalEntry) onSave;
  final bool isDark;
  const _WriteEntrySheet({required this.onSave, required this.isDark});

  @override
  State<_WriteEntrySheet> createState() => _WriteEntrySheetState();
}

class _WriteEntrySheetState extends State<_WriteEntrySheet> {
  final _controller = TextEditingController();
  int _mood = 3;
  final _tagController = TextEditingController();
  List<String> _tags = [];

  final _prompts = [
    'What are you grateful for today?',
    'What challenged you and what did you learn?',
    'What made you smile today?',
    'What do you want to achieve tomorrow?',
    'How are you feeling right now and why?',
  ];

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppTheme.darkSurface : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);
    final moodEmojis = ['😔', '😕', '😐', '😊', '🤩'];
    final moodLabels = ['Struggling', 'Low', 'Okay', 'Good', 'Amazing'];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 20),
            Text('New Entry', style: GoogleFonts.playfairDisplay(
              fontSize: 22, fontWeight: FontWeight.w700, color: textColor,
            )),
            const SizedBox(height: 16),
            // Mood selector
            Text('How are you feeling?', style: GoogleFonts.lato(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white60 : Colors.black54,
            )),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final selected = _mood == i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _mood = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.accentMint.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: selected ? Border.all(color: AppTheme.accentMint) : null,
                    ),
                    child: Column(
                      children: [
                        Text(moodEmojis[i], style: const TextStyle(fontSize: 24)),
                        Text(moodLabels[i], style: GoogleFonts.lato(
                          fontSize: 9, color: selected ? AppTheme.accentMint : (widget.isDark ? Colors.white38 : Colors.black38),
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        )),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Prompt chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _prompts.map((p) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _controller.text = p,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentMint.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentMint.withOpacity(0.3)),
                      ),
                      child: Text(p, style: GoogleFonts.lato(
                        fontSize: 11, color: AppTheme.accentMint, fontWeight: FontWeight.w600,
                      )),
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 5,
              style: GoogleFonts.lato(color: textColor, fontSize: 14, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Write your thoughts...',
                hintStyle: GoogleFonts.lato(color: widget.isDark ? Colors.white30 : Colors.black26),
                filled: true,
                fillColor: widget.isDark ? AppTheme.darkCard : AppTheme.lightCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tags
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    style: GoogleFonts.lato(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Add tag (press +)',
                      hintStyle: GoogleFonts.lato(fontSize: 13, color: widget.isDark ? Colors.white30 : Colors.black26),
                      filled: true,
                      fillColor: widget.isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (_tagController.text.trim().isNotEmpty) {
                      setState(() {
                        _tags.add(_tagController.text.trim());
                        _tagController.clear();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _tags.map((t) => GestureDetector(
                  onTap: () => setState(() => _tags.remove(t)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentMint.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('#$t', style: GoogleFonts.lato(fontSize: 12, color: AppTheme.accentMint)),
                        const SizedBox(width: 4),
                        const Icon(Icons.close, size: 12, color: AppTheme.accentMint),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isEmpty) return;
                  widget.onSave(JournalEntry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    content: _controller.text.trim(),
                    mood: _mood,
                    date: DateTime.now().toIso8601String(),
                    tags: _tags,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentMint,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Save Entry', style: GoogleFonts.lato(
                  fontSize: 15, fontWeight: FontWeight.w700,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
