import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quotes_data.dart';
import '../utils/app_theme.dart';

class QuoteScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const QuoteScreen({super.key, required this.prefs});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  Set<int> _favorites = {};
  String _selectedCategory = 'All';
  List<Quote> _filteredQuotes = [];
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _filteredQuotes = QuoteData.quotes;
    // Start at today's quote
    final todayIndex = (DateTime.now().day + DateTime.now().hour) % QuoteData.quotes.length;
    _currentIndex = todayIndex;
    _pageController = PageController(initialPage: todayIndex, viewportFraction: 0.92);
    _heartController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _loadFavorites() {
    final data = widget.prefs.getStringList('favorite_quotes') ?? [];
    setState(() => _favorites = data.map(int.parse).toSet());
  }

  void _toggleFavorite(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_favorites.contains(index)) {
        _favorites.remove(index);
      } else {
        _favorites.add(index);
        _heartController.forward(from: 0);
      }
    });
    widget.prefs.setStringList(
      'favorite_quotes',
      _favorites.map((e) => e.toString()).toList(),
    );
  }

  void _filterByCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      _filteredQuotes = cat == 'All'
          ? QuoteData.quotes
          : QuoteData.byCategory(cat);
      _currentIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? Colors.white60 : Colors.black45;
    final categories = ['All', ...QuoteData.categories];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Wisdom', style: GoogleFonts.playfairDisplay(
                        fontSize: 26, fontWeight: FontWeight.w700, color: textColor,
                      )),
                      Text(_greeting(), style: GoogleFonts.lato(
                        fontSize: 13, color: subColor,
                      )),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppTheme.primaryGold, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Category chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final selected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _filterByCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryGold
                              : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? AppTheme.primaryGold : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : subColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Quote cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _filteredQuotes.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (_, i) {
                  final quote = _filteredQuotes[i];
                  final globalIndex = QuoteData.quotes.indexOf(quote);
                  final isFav = _favorites.contains(globalIndex);
                  return _QuoteCard(
                    quote: quote,
                    isFavorite: isFav,
                    onFavorite: () => _toggleFavorite(globalIndex),
                    onShare: () => _shareQuote(quote),
                    isDark: isDark,
                    index: i,
                  );
                },
              ),
            ),
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${_filteredQuotes.length}',
                    style: GoogleFonts.lato(fontSize: 12, color: subColor),
                  ),
                ],
              ),
            ),
            // Favorites count
            if (_favorites.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '❤️ ${_favorites.length} saved',
                    style: GoogleFonts.lato(fontSize: 12, color: AppTheme.accentCoral),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤';
    return 'Good evening 🌙';
  }

  void _shareQuote(Quote q) {
    // Would use share_plus in real app
    Clipboard.setData(ClipboardData(text: '"${q.text}" — ${q.author}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard! ✨', style: GoogleFonts.lato()),
        backgroundColor: AppTheme.primaryGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final bool isDark;
  final int index;

  const _QuoteCard({
    required this.quote,
    required this.isFavorite,
    required this.onFavorite,
    required this.onShare,
    required this.isDark,
    required this.index,
  });

  static const List<List<Color>> _gradients = [
    [Color(0xFFE8B86D), Color(0xFFFF6B6B)],
    [Color(0xFF4ECDC4), Color(0xFF44CF6C)],
    [Color(0xFF9B59B6), Color(0xFF6C5CE7)],
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    [Color(0xFF2196F3), Color(0xFF4ECDC4)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[index % _gradients.length];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: gradient.map((c) => c.withValues(alpha: isDark ? 0.12 : 0.08)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: gradient[0].withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: gradient[0].withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${quote.emoji} ${quote.category}',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: gradient[0],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 80,
                      color: gradient[0].withValues(alpha: 0.3),
                      height: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quote.text,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '— ${quote.author}',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: gradient[0],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Swipe for more →',
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onShare,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.ios_share_rounded,
                            size: 18,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? AppTheme.accentCoral.withValues(alpha: 0.15)
                                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFavorite ? AppTheme.accentCoral : (isDark ? Colors.white54 : Colors.black45),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}
