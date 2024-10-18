import 'package:flutter/material.dart';
import 'package:mexam/home_page.dart';
import 'package:mexam/reports_page.dart';
import 'package:mexam/settings_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      title: 'Quiz App',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MyHomePage(
        toggleDarkMode: _toggleDarkMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.toggleDarkMode});
  final Function toggleDarkMode;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedBNB = 0;
  double fontSize = 12;

  Future<void> _saveFontSize(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', value);

    setState(() {
      fontSize = value;
    });
  }

  Future<void> _loadFontSizePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      fontSize = prefs.getDouble('font_size') ?? 12;
    });
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;

    // If the permission is not granted, request it
    if (!status.isGranted) {
      // Request permission
      status = await Permission.storage.request();

      // Check the status after requesting permission
      if (status.isGranted) {
        // Permission granted
        print('Storage permission granted');
      } else if (status.isDenied) {
        // Permission denied
        print('Storage permission denied');
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, open settings
        print('Storage permission permanently denied, opening settings');
        await openAppSettings();
      }
    } else {
      print('Storage permission already granted');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFontSizePrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Quiz App',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            elevation: 10,
            currentIndex: selectedBNB,
            unselectedFontSize: fontSize + 3,
            iconSize: fontSize + 20,
            selectedFontSize: fontSize + 8,
            onTap: (value) {
              setState(() {
                selectedBNB = value;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Home', tooltip: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.question_answer),
                  label: 'Reports',
                  tooltip: 'Reports'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                  tooltip: 'Settings'),
            ]),
        body: selectedBNB == 0
            ? const HomePage()
            : selectedBNB == 1
                ? const ReportsPage()
                : SettingsPage(
                    toggleNightMode: widget.toggleDarkMode,
                    fontSize: _saveFontSize,
                  ));
  }
}
