import 'package:flutter/material.dart';
import 'package:mexam/database_helper.dart';
import 'package:mexam/quiz_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelPage extends StatefulWidget {
  const LevelPage(
      {super.key,
      required this.catId,
      required this.coverImage,
      required this.title,
      required this.description,
      required this.tag});
  final int catId;
  final String title;
  final String description;
  final Image coverImage;
  final String tag;

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  List<String> questionDefecultyItems = [
    'Elementary',
    'Intermediate',
    'Advanced'
  ];

  String? selectedLevel;
  double fontSize = 12;

  Future<void> _restartQuiz() async {
    await DatabaseHelper.restartQuiz(widget.catId);
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
    selectedLevel = questionDefecultyItems[0];
    _loadFontSizePrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Hero(tag: 'cover-${widget.tag}', child: widget.coverImage),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            widget.description,
            style: TextStyle(fontSize: fontSize + 10),
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(),
        const SizedBox(
          height: 50,
        ),
        Text('Selecte defeculty level',
            style:
                TextStyle(fontSize: fontSize + 5, fontWeight: FontWeight.bold)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: questionDefecultyItems.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: RadioListTile(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50)),
                    activeColor: Colors.green,
                    title: Center(
                      child: Text(
                        questionDefecultyItems[index],
                        style: TextStyle(
                            fontSize: fontSize + 3,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    value: questionDefecultyItems[index],
                    groupValue: selectedLevel,
                    onChanged: (value) {
                      setState(() {
                        selectedLevel = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: FilledButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green)),
              onPressed: () {
                _restartQuiz();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => QuizPage(catId: widget.catId)));
              },
              child: Text(
                'Start',
                style: TextStyle(fontSize: fontSize + 18, color: Colors.black),
              )),
        )
      ]),
    );
  }
}
