import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  runApp(MotivateApp(prefs: prefs));
}

class MotivateApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MotivateApp({super.key, required this.prefs});

  @override
  State<MotivateApp> createState() => _MotivateAppState();
}

class _MotivateAppState extends State<MotivateApp> {
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _isDark = widget.prefs.getBool('isDark') ?? false;
  }

  void toggleTheme() {
    setState(() => _isDark = !_isDark);
    widget.prefs.setBool('isDark', _isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motivate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(
        prefs: widget.prefs,
        isDark: _isDark,
        onToggleTheme: toggleTheme,
      ),
    );
  }
}
