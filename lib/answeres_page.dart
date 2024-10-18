import 'package:flutter/material.dart';
import 'package:mexam/database_helper.dart';

class AnsweresPage extends StatefulWidget {
  const AnsweresPage({super.key, required this.categoryId});
  final int categoryId;

  @override
  State<AnsweresPage> createState() => _AnsweresPageState();
}

class _AnsweresPageState extends State<AnsweresPage> {
  List<Map<String, dynamic>> _quizList = [];

  String? selectedAns;
  int quizIndex = 0;

  void _getQuiz() async {
    final data = await DatabaseHelper().getAnsweredQuiz(widget.categoryId);
    setState(() {
      if (data.isNotEmpty) {
        _quizList = data;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Card(
          elevation: 10,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.transparent)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CloseButton(
                style: const ButtonStyle(iconSize: WidgetStatePropertyAll(30)),
                color: Colors.red,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  '${quizIndex + 1} of ${_quizList.length} Questions',
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Text(
                    '${_quizList.isNotEmpty ? _quizList[quizIndex]['text'] : ''}',
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    List<String> questionCount = ['a', 'b', 'c', 'd'];
                    return Card(
                      elevation: 3,
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: ListTile(
                        trailing: _quizList.isNotEmpty
                            ? Icon(
                                _quizList[quizIndex]['u_ans'] ==
                                        _quizList[quizIndex][
                                            'ans_${_quizList[quizIndex]['correct_ans']}']
                                    ? Icons.check_circle
                                    : _quizList[quizIndex]['u_ans'] ==
                                            _quizList[quizIndex]
                                                ['ans_${questionCount[index]}']
                                        ? Icons.cancel
                                        : null,
                                color: _quizList[quizIndex]['score'] == 0
                                    ? Colors.red
                                    : Colors.white,
                              )
                            : null,
                        tileColor: _quizList.isNotEmpty
                            ? _quizList[quizIndex][
                                        'ans_${_quizList[quizIndex]['correct_ans']}'] ==
                                    _quizList[quizIndex]
                                        ['ans_${questionCount[index]}']
                                ? Colors.green
                                : Colors.white
                            : Colors.white,
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                        title: Text(
                          "${index + 1}: ${_quizList.isNotEmpty ? _quizList[quizIndex]['ans_${questionCount[index]}'] : ''}",
                          style: TextStyle(
                            fontSize: _quizList.isNotEmpty
                                ? _quizList[quizIndex][
                                            'ans_${_quizList[quizIndex]['correct_ans']}'] ==
                                        _quizList[quizIndex]
                                            ['ans_${questionCount[index]}']
                                    ? 25
                                    : 15
                                : 15,
                            fontWeight: FontWeight.bold,
                            color: _quizList.isNotEmpty
                                ? _quizList[quizIndex][
                                            'ans_${_quizList[quizIndex]['correct_ans']}'] ==
                                        _quizList[quizIndex]
                                            ['ans_${questionCount[index]}']
                                    ? Colors.white
                                    : Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 30,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'or',
                              style: TextStyle(fontSize: 50),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 30,
                            ),
                          ],
                        ),
                        Text('are indicate of your choosen answer!',
                            style: TextStyle(fontSize: 30))
                      ],
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilledButton(
                        onPressed: () {
                          if (quizIndex > 0) {
                            quizIndex--;
                            _getQuiz();
                          } else {
                            Navigator.of(context).pop;
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.arrow_back),
                            Text(
                              'Previus',
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
                          if (quizIndex < _quizList.length - 1) {
                            quizIndex++;
                            _getQuiz();
                          } else {
                            Navigator.of(context).pop;
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
    );
  }
}
