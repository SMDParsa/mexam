import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mexam/database_helper.dart';
import 'package:mexam/result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.catId});
  final int catId;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> _quizList = [];
  List<Map<String, dynamic>> _quizAnsweredList = [];
  List<Map<String, dynamic>> _quizAllList = [];
  List<String> questionCount = ['a', 'b', 'c', 'd'];

  String? selectedAns;
  Timer? _timer;

  int _startTimer = 60;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTimer > 0) {
        setState(() {
          _startTimer--;
        });
      } else {
        _timer?.cancel();
        _saveAnswer(_quizList.isNotEmpty ? _quizList[0]['id'] : 0,
            selectedAns ?? '', 0);

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ResultPage(quizCategory: widget.catId)));
      }
    });
  }

  void _getQuiz() async {
    final data = await DatabaseHelper().getQuiz(widget.catId);
    setState(() {
      if (data.isNotEmpty) {
        _getAllQuiz();
        _getAnsweredQuiz();
        _quizList = data;
        questionCount.shuffle();
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResultPage(quizCategory: widget.catId),
        ));
      }
    });
  }

  void _getAnsweredQuiz() async {
    final data = await DatabaseHelper().getAnsweredQuiz(widget.catId);
    setState(() {
      _quizAnsweredList = data;
    });
  }

  void _getAllQuiz() async {
    final data = await DatabaseHelper().getAllQuiz(widget.catId);
    setState(() {
      _quizAllList = data;
    });
  }

  Future<void> _saveAnswer(int id, userSelected, int score) async {
    await DatabaseHelper.saveAnswer(id, userSelected, score);
    selectedAns = null;
  }

  @override
  void initState() {
    super.initState();
    _getQuiz();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //todo: make it false to prevent user from going back
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            'You will lose your scores!',
            style: TextStyle(fontSize: 20),
          ),
          action: SnackBarAction(
              label: 'EXIT',
              onPressed: () {
                _saveAnswer(_quizList.isNotEmpty ? _quizList[0]['id'] : 0,
                    selectedAns ?? '', 0);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ResultPage(
                          quizCategory: widget.catId,
                        )));
              }),
        ));
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Card(
            elevation: 10,
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.transparent)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: Stack(children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 1.0, end: 0.0),
                      duration: const Duration(seconds: 60),
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          minHeight: 50,
                          color: _startTimer > 20 ? Colors.green : Colors.red,
                          value: value,
                        );
                      },
                    ),
                    Center(
                      child: Text(
                        '$_startTimer Sec',
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.black, // Shadow or outline effect
                              ),
                            ]),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${_quizAnsweredList.length + 1} of ${_quizAllList.length} Questions',
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    '${_quizList.isNotEmpty ? _quizList[0]['text'] : ''}',
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      List<String> questionLead = ['a', 'b', 'c', 'd'];

                      return Card(
                        elevation: 3,
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: RadioListTile(
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          activeColor: Colors.green,
                          title: Text(
                            "${questionLead[index].toUpperCase()}: ${_quizList.isNotEmpty ? _quizList[0]['ans_${questionCount[index]}'] : ''}",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          value: _quizList.isNotEmpty
                              ? _quizList[0]['ans_${questionCount[index]}']
                              : '',
                          groupValue: selectedAns,
                          onChanged: (value) {
                            setState(() {
                              // Update the selected answer
                              selectedAns = value;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                          onPressed: () {
                            String correctAnswer = _quizList.isNotEmpty
                                ? _quizList[0]
                                    ['ans_${_quizList[0]['correct_ans']}']
                                : null;

                            if (selectedAns != null) {
                              _saveAnswer(
                                  _quizList.isNotEmpty ? _quizList[0]['id'] : 0,
                                  selectedAns,
                                  selectedAns == correctAnswer ? 10 : 0);

                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => ResultPage(
                                          quizCategory: widget.catId)));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'Please choose an option first!',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      )));
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.block_sharp),
                              Text(
                                'End',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                          onPressed: () {
                            _getAllQuiz();
                            _getAnsweredQuiz();
                            String correctAnswer = _quizList.isNotEmpty
                                ? _quizList[0]
                                    ['ans_${_quizList[0]['correct_ans']}']
                                : null;

                            if (selectedAns != null) {
                              _saveAnswer(
                                  _quizList.isNotEmpty ? _quizList[0]['id'] : 0,
                                  selectedAns,
                                  selectedAns == correctAnswer ? 10 : 0);
                              _getQuiz();
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'Please choose an option first!',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      )));
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.arrow_forward)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
