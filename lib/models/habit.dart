class Habit {
  final String id;
  final String name;
  final String emoji;
  final String color;
  final List<String> completedDates; // ISO date strings

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  bool isCompletedToday() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    return completedDates.contains(todayStr);
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = [...completedDates]..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime check = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final str = '${check.year}-${check.month}-${check.day}';
      if (sorted.contains(str)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else if (i == 0) {
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get totalCompleted => completedDates.length;

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    String? color,
    List<String>? completedDates,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'color': color,
        'completedDates': completedDates,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'],
        color: json['color'],
        completedDates: List<String>.from(json['completedDates'] ?? []),
      );
}
