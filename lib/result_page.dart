import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:mexam/answeres_page.dart';
import 'package:mexam/database_helper.dart';
import 'package:mexam/quiz_page.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart'; // Optional: For saving to the gallery

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.quizCategory});
  final int quizCategory;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Map<String, dynamic>> _quizAnsweredList = [];
  List<Map<String, dynamic>> _quizAllList = [];
  int? totalScore;
  final GlobalKey _globalKey = GlobalKey(); // Key for RepaintBoundary

  void _getAnsweredQuiz() async {
    final data = await DatabaseHelper().getAnsweredQuiz(widget.quizCategory);
    setState(() {
      _quizAnsweredList = data;
    });
  }

  // Function to fetch the total score from the database
  void _fetchTotalScore() async {
    int fetchedTotalScore = await DatabaseHelper()
        .getQuizScore(widget.quizCategory); // Call your function
    setState(() {
      totalScore =
          fetchedTotalScore; // Update the state with the fetched total score
    });
  }

  void _getAllQuiz() async {
    final data = await DatabaseHelper().getAllQuiz(widget.quizCategory);
    setState(() {
      _quizAllList = data;
    });
  }

  Future<void> _restartQuiz() async {
    await DatabaseHelper.restartQuiz(widget.quizCategory);
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // Request permission
      await Permission.storage.request();
    } else {
      _capturePng();
    }
  }

  @override
  void initState() {
    super.initState();
    _getAnsweredQuiz();
    _getAllQuiz();
    _fetchTotalScore(); // Fetch the total score when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: RepaintBoundary(
          key: _globalKey,
          child: Card(
            elevation: 10,
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: Colors.transparent)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  totalScore != null
                      ? totalScore! < 40
                          ? '-\t\tFailed\t\t-'
                          : '-\t\tCongratulations\t\t-'
                      : 'Loading',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: totalScore != null
                          ? totalScore! < 40
                              ? Colors.red
                              : Colors.green
                          : Colors.black),
                ),
                Text(
                  'You answered ${_quizAnsweredList.length} out of ${_quizAllList.length} Questions',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 100,
                ),
                Text(
                  'Your Score\n-\t\t$totalScore\t\t-',
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                AnsweresPage(categoryId: widget.quizCategory)));
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.question_answer),
                          Text('Answeres')
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.home),
                          Center(child: Text('Home'))
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Column(
                        children: [Icon(Icons.share), Text('Share')],
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          requestStoragePermission();
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.save),
                            Center(
                              child: Text('Save'),
                            )
                          ],
                        ))
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                    onPressed: () {
                      _restartQuiz();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              QuizPage(catId: widget.quizCategory)));
                    },
                    child: const Text(
                      'Restart quiz',
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _capturePng() async {
    try {
      // Get the RenderRepaintBoundary object
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Capture the image in the form of ui.Image
      ui.Image image = await boundary.toImage(
          pixelRatio: 3.0); // Adjust the pixel ratio if necessary

      // Convert ui.Image to byte data
      ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png); // Start with PNG

      if (byteData != null) {
        /* Uint8List pngBytes = byteData.buffer.asUint8List();

        // Convert PNG bytes to JPG format using the image package
        img.Image? decodedImage = img.decodeImage(pngBytes);
        Uint8List jpgBytes = img.encodeJpg(decodedImage!,
            quality: 90); // Adjust quality as needed */

        // Save the file to the device
        /* final directory =
            await getExternalStorageDirectory(); // You can also use getExternalStorageDirectory
        String path =
            '${directory!.path}/MeXam Quiz Result - ${DateTime.now()}.png';
        File file = File(path);
        await file.writeAsBytes(jpgBytes);

        print('Image saved to $path'); */

        final result = await ImageGallerySaverPlus.saveImage(
            byteData.buffer.asUint8List());
        bool isSuccess = result['isSuccess'];
        showResultSnackBar(isSuccess);
        print('the resutl - $isSuccess');
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  void showResultSnackBar(bool isSuccess) {
    String saveText = 'Error';
    isSuccess
        ? saveText = 'Saved to gallery'
        : saveText = 'Failed to save!\nPlease try again...';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(saveText),
      action: SnackBarAction(
          label: 'Close',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar),
    ));
  }
}
