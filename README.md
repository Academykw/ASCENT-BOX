#  Motivate - Beautiful Offline Motivational App

A stunning, fully offline Flutter motivational app with 5 powerful features.

##  Features

### 1.  Daily Quotes
- 35+ curated motivational quotes
- Swipeable card interface with beautiful gradients
- Category filter (Courage, Resilience, Dreams, Success, etc.)
- Save favorites with a heart tap
- Copy to clipboard / share any quote
- Today's quote highlighted automatically

### 2.  Habit Tracker
- Add custom habits with emoji + color pickers
- Preset popular habits (Workout, Read, Meditate, etc.)
- Daily streak counter with fire icon
- Progress bar showing today's completion
- Swipe-to-delete habits
- Total completions count

### 3.  Mood Journal
- Write journal entries with mood rating (1-5)
- Beautiful mood emoji selector
- Writing prompts to inspire entries
- Add custom tags to entries
- Mood overview bar chart
- Swipe-to-delete entries
- Sorted by date (newest first)

### 4.  Affirmations
- 6 categories: Self-Love, Confidence, Abundance, Health, Success, Peace
- 5-6 affirmations per category
- Tap-through interface with animated transitions
- Copy any affirmation to clipboard
- Beautiful gradient card design

### 5.  Breathing Exercises
- 4 breathing patterns:
  - **4-7-8** (Sleep/Anxiety relief)
  - **Box Breathing** (Balance)
  - **4-4-4** (Energizing)
  - **Calming** (Deep relaxation)
- Animated breathing circle (expands/contracts)
- Cycle counter
- Benefit cards (Reduces Anxiety, Lowers HR, Improves Focus, Better Sleep)

###  Dark/Light Mode
- Beautiful warm light theme and deep dark theme
- Toggle with FAB button
- Preference saved across sessions

---

##  Setup Instructions

### Prerequisites
- Flutter SDK 3.0+
- Android Studio or VS Code with Flutter extension
- Android device/emulator or iOS device/simulator

### Installation

```bash
# Clone or extract the project
cd motivate_app

# Install dependencies
flutter pub get

# Run on device
flutter run

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

### Running
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

---

##  Project Structure

```
lib/
├── main.dart               # App entry & theme state
├── data/
│   └── quotes_data.dart    # All quotes (35+)
├── models/
│   ├── habit.dart          # Habit data model
│   └── journal_entry.dart  # Journal entry model
├── screens/
│   ├── splash_screen.dart  # Animated splash
│   ├── home_screen.dart    # Bottom nav shell
│   ├── quote_screen.dart   # Daily quotes
│   ├── habits_screen.dart  # Habit tracker
│   ├── journal_screen.dart # Mood journal
│   ├── affirmations_screen.dart # Affirmations
│   └── breathe_screen.dart # Breathing exercises
└── utils/
    └── app_theme.dart      # Colors, typography, themes
```

##  Design System

- **Primary**: Golden (`#E8B86D`)
- **Accent**: Coral (`#FF6B6B`), Mint (`#4ECDC4`), Purple (`#9B59B6`)
- **Typography**: Playfair Display (headings) + Lato (body)
- **Dark BG**: `#0D1117` | **Light BG**: `#FFF8F0`

##  Dependencies

| Package | Purpose |
|---------|---------|
| `shared_preferences` | Local data persistence |
| `flutter_animate` | Smooth animations |
| `google_fonts` | Playfair Display + Lato |
| `fl_chart` | Charts (mood tracking) |
| `percent_indicator` | Progress indicators |
| `confetti` | Celebration effects |

---

Built with  using Flutter
