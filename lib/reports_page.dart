import 'dart:ui';

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

  int isFavorite = 0;

  Future<void> _getUserInfo() async {
    await DatabaseHelper().database;

    userInfo = await DatabaseHelper().getUserInfo();

    setState(() {
      userInfo = userInfo;
    });
  }

  Future<void> _addFavorite(int id, int favorite) async {
    await DatabaseHelper.adFavorite(id, favorite);
    setState(() {
      isFavorite = favorite;
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
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nearby_error,
                size: 50,
              ),
              const Text(
                'Error getting data',
                style: TextStyle(fontSize: 30),
              ),
            ],
          ));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info,
                size: 50,
              ),
              const Text(
                'No Report, please try again later',
                style: TextStyle(fontSize: 30),
              ),
            ],
          ));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              String title = snapshot.data![index]['text'];
              String corrAns = snapshot.data![index]
                  ['ans_${snapshot.data![index]['correct_ans']}'];
              String categoryName = snapshot.data![index]['Name'];
              String userAns = snapshot.data![index]['u_ans'];
              int isFavovite = snapshot.data![index]['favorite'];

              List<String> ansList = [
                snapshot.data![index]['ans_a'],
                snapshot.data![index]['ans_b'],
                snapshot.data![index]['ans_c'],
                snapshot.data![index]['ans_d'],
              ];

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  elevation: 10,
                  surfaceTintColor: Colors.red,
                  shadowColor: Colors.red,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                              width: double.infinity,
                              child: ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 10.0, sigmaY: 3.0),
                                child: Image.memory(
                                  snapshot.data![index]['Image'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              categoryName,
                              style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Positioned(
                                right: 20,
                                child: IconButton(
                                    onPressed: () {
                                      _addFavorite(snapshot.data![index]['id'],
                                          isFavovite == 1 ? 0 : 1);

                                      setState(() {
                                        quizListData = _getQuizList();
                                      });
                                    },
                                    icon: Icon(
                                      isFavovite < 1
                                          ? Icons.heart_broken
                                          : Icons.favorite,
                                      color: isFavovite < 1
                                          ? Colors.white
                                          : Colors.red,
                                      size: 30,
                                    )))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: Text(
                          'A: ${ansList[0]}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: ansList[0] == corrAns
                                  ? FontWeight.bold
                                  : null),
                        ),
                        tileColor: ansList[0] == corrAns
                            ? Colors.green.shade900
                            : null,
                        textColor: ansList[0] == corrAns ? Colors.white : null,
                        trailing: Icon(
                            ansList[0] == userAns ? Icons.check_circle : null),
                      ),
                      ListTile(
                        title: Text(
                          'B: ${ansList[1]}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: ansList[1] == corrAns
                                  ? FontWeight.bold
                                  : null),
                        ),
                        tileColor: ansList[1] == corrAns
                            ? Colors.green.shade900
                            : null,
                        textColor: ansList[1] == corrAns ? Colors.white : null,
                        trailing: Icon(
                            ansList[1] == userAns ? Icons.check_circle : null),
                      ),
                      ListTile(
                        title: Text(
                          'C: ${ansList[2]}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: ansList[2] == corrAns
                                  ? FontWeight.bold
                                  : null),
                        ),
                        tileColor: ansList[2] == corrAns
                            ? Colors.green.shade900
                            : null,
                        textColor: ansList[2] == corrAns ? Colors.white : null,
                        trailing: Icon(
                            ansList[2] == userAns ? Icons.check_circle : null),
                      ),
                      ListTile(
                        title: Text(
                          'D: ${ansList[3]}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: ansList[3] == corrAns
                                  ? FontWeight.bold
                                  : null),
                        ),
                        tileColor: ansList[3] == corrAns
                            ? Colors.green.shade900
                            : null,
                        textColor: ansList[3] == corrAns ? Colors.white : null,
                        trailing: Icon(
                            ansList[3] == userAns ? Icons.check_circle : null),
                      ),
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
