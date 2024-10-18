import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key, required this.toggleNightMode, required this.fontSize});
  final toggleNightMode;
  final fontSize;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool nightMode = false;
  double fontSize = 12;

  Future<void> _loadThemePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      nightMode = prefs.getBool('is_darkmode') ?? false;
    });
  }

  Future<void> _loadFontSizePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      fontSize = prefs.getDouble('font_size') ?? 12;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadThemePrefs();
    _loadFontSizePrefs();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SwitchListTile(
            value: nightMode,
            subtitle: const Text('Enable or disabel night mode'),
            title: const Text(
              'Night Mode',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            onChanged: (value) {
              setState(() {
                if (nightMode == false) {
                  nightMode = true;
                  widget.toggleNightMode(true);
                } else {
                  widget.toggleNightMode(false);
                  nightMode = false;
                }
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Font Size',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(
                  'Example font Size',
                  style: TextStyle(fontSize: fontSize),
                ),
                Slider(
                  min: 12,
                  max: 50,
                  value: fontSize,
                  onChanged: (value) {
                    setState(() {
                      widget.fontSize(value);
                      fontSize = value;
                    });
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
