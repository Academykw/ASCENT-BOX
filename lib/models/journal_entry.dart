class JournalEntry {
  final String id;
  final String content;
  final int mood; // 1-5
  final String date; // ISO string
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.content,
    required this.mood,
    required this.date,
    List<String>? tags,
  }) : tags = tags ?? [];

  String get moodEmoji {
    switch (mood) {
      case 1: return '😔';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '😊';
      case 5: return '🤩';
      default: return '😐';
    }
  }

  String get moodLabel {
    switch (mood) {
      case 1: return 'Struggling';
      case 2: return 'Low';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Amazing';
      default: return 'Okay';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'mood': mood,
        'date': date,
        'tags': tags,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'],
        content: json['content'],
        mood: json['mood'],
        date: json['date'],
        tags: List<String>.from(json['tags'] ?? []),
      );
}
