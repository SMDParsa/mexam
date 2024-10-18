import 'package:flutter/material.dart';
import 'package:mexam/database_helper.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> userInfo = [];
  late Future<List<Map<String, dynamic>>> quizListData;

  Future<void> _getUserInfo() async {
    await DatabaseHelper().database;

    userInfo = await DatabaseHelper().getUserInfo();

    setState(() {
      userInfo = userInfo;
    });
  }

  Future<List<Map<String, dynamic>>> _getQuizList() async {
    await DatabaseHelper().database;

    List<Map<String, dynamic>> quizList =
        await DatabaseHelper().getQuizReport();

    return quizList;
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    quizListData = _getQuizList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: quizListData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('data');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              String title = snapshot.data![index]['text'];
              List<String> ansList = [
                snapshot.data![index]['ans_a'],
                snapshot.data![index]['ans_b'],
                snapshot.data![index]['ans_c'],
                snapshot.data![index]['ans_d'],
              ];

              String corrAns = snapshot.data![index]['correct_ans'];
              // String categoryName = snapshot.data![index]['Name'];

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  child: Column(
                    children: [
                      Text(title),
                      ListTile(title: Text(ansList[0])),
                      ListTile(title: Text(ansList[1])),
                      ListTile(title: Text(ansList[2])),
                      ListTile(title: Text(ansList[3])),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    ));
  }
}
