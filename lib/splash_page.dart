import 'package:flutter/material.dart';
import 'package:mexam/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) {
  runApp(SplashPage());
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isDarkMode = false;

  Future<void> _loadThemePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isDarkMode = prefs.getBool('is_darkmode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_darkmode', value);

    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadThemePrefs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Splashing(toggleDarkMode: _toggleDarkMode),
    );
  }
}

class Splashing extends StatefulWidget {
  const Splashing({super.key, required this.toggleDarkMode});
  final toggleDarkMode;

  @override
  State<Splashing> createState() => _SplashingState();
}

class _SplashingState extends State<Splashing> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              child: Image.asset('assets/images/splash_logo.jpg'),
            ),
            Text(
              'MeXam',
              style: TextStyle(fontSize: 30),
            ),
            Text(
              'V 1.0 (build 1)',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
