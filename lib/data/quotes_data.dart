class Quote {
  final String text;
  final String author;
  final String category;
  final String emoji;

  const Quote({
    required this.text,
    required this.author,
    required this.category,
    required this.emoji,
  });
}

class QuoteData {
  static const List<Quote> quotes = [
    Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs", category: "Work", emoji: "💼"),
    Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt", category: "Belief", emoji: "✨"),
    Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius", category: "Persistence", emoji: "🐢"),
    Quote(text: "Everything you've ever wanted is on the other side of fear.", author: "George Addair", category: "Courage", emoji: "🦁"),
    Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill", category: "Success", emoji: "🏆"),
    Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt", category: "Dreams", emoji: "🌟"),
    Quote(text: "Hardships often prepare ordinary people for an extraordinary destiny.", author: "C.S. Lewis", category: "Resilience", emoji: "💪"),
    Quote(text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis", category: "Dreams", emoji: "🌈"),
    Quote(text: "Act as if what you do makes a difference. It does.", author: "William James", category: "Action", emoji: "⚡"),
    Quote(text: "What you get by achieving your goals is not as important as what you become by achieving your goals.", author: "Henry David Thoreau", category: "Growth", emoji: "🌱"),
    Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson", category: "Persistence", emoji: "⏰"),
    Quote(text: "Keep your face always toward the sunshine, and shadows will fall behind you.", author: "Walt Whitman", category: "Optimism", emoji: "☀️"),
    Quote(text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky", category: "Action", emoji: "🎯"),
    Quote(text: "Whether you think you can or you think you can't, you're right.", author: "Henry Ford", category: "Mindset", emoji: "🧠"),
    Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain", category: "Action", emoji: "🚀"),
    Quote(text: "Life is what happens when you're busy making other plans.", author: "John Lennon", category: "Life", emoji: "🦋"),
    Quote(text: "Spread love everywhere you go. Let no one ever come to you without leaving happier.", author: "Mother Teresa", category: "Love", emoji: "❤️"),
    Quote(text: "When you reach the end of your rope, tie a knot in it and hang on.", author: "Franklin D. Roosevelt", category: "Resilience", emoji: "🪢"),
    Quote(text: "Always remember that you are absolutely unique. Just like everyone else.", author: "Margaret Mead", category: "Identity", emoji: "🦄"),
    Quote(text: "Do not go where the path may lead, go instead where there is no path and leave a trail.", author: "Ralph Waldo Emerson", category: "Leadership", emoji: "🗺️"),
    Quote(text: "You will face many defeats in life, but never let yourself be defeated.", author: "Maya Angelou", category: "Resilience", emoji: "🔥"),
    Quote(text: "The greatest glory in living lies not in never falling, but in rising every time we fall.", author: "Nelson Mandela", category: "Resilience", emoji: "⬆️"),
    Quote(text: "In the end, it's not the years in your life that count. It's the life in your years.", author: "Abraham Lincoln", category: "Life", emoji: "🎉"),
    Quote(text: "Never let the fear of striking out keep you from playing the game.", author: "Babe Ruth", category: "Courage", emoji: "⚾"),
    Quote(text: "Life is either a daring adventure or nothing at all.", author: "Helen Keller", category: "Adventure", emoji: "🌍"),
    Quote(text: "Many of life's failures are people who did not realize how close they were to success when they gave up.", author: "Thomas A. Edison", category: "Persistence", emoji: "💡"),
    Quote(text: "You have brains in your head. You have feet in your shoes. You can steer yourself any direction you choose.", author: "Dr. Seuss", category: "Empowerment", emoji: "👟"),
    Quote(text: "If life were predictable it would cease to be life, and be without flavor.", author: "Eleanor Roosevelt", category: "Life", emoji: "🌶️"),
    Quote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins", category: "Action", emoji: "🗺️"),
    Quote(text: "In this life we cannot do great things. We can only do small things with great love.", author: "Mother Teresa", category: "Love", emoji: "💝"),
    Quote(text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle", category: "Hope", emoji: "🕯️"),
    Quote(text: "Whoever is happy will make others happy too.", author: "Anne Frank", category: "Happiness", emoji: "😊"),
    Quote(text: "Do not let making a living prevent you from making a life.", author: "John Wooden", category: "Balance", emoji: "⚖️"),
    Quote(text: "If you look at what you have in life, you'll always have more.", author: "Oprah Winfrey", category: "Gratitude", emoji: "🙏"),
    Quote(text: "Challenges are what make life interesting and overcoming them is what makes life meaningful.", author: "Joshua J. Marine", category: "Growth", emoji: "🏔️"),
  ];

  static List<String> get categories =>
      quotes.map((q) => q.category).toSet().toList()..sort();

  static List<Quote> byCategory(String category) =>
      quotes.where((q) => q.category == category).toList();

  static Quote random() {
    final now = DateTime.now();
    final index = (now.day + now.hour) % quotes.length;
    return quotes[index];
  }
}
