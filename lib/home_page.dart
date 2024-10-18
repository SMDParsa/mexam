import 'package:flutter/material.dart';
import 'package:mexam/database_helper.dart';
import 'package:mexam/level_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _dbData;
  double fontSize = 12;

  Future<List<Map<String, dynamic>>> _getDataFromDB() async {
    //init copy Database from Assets
    await DatabaseHelper().database;

    //Get Category with it's quiz count
    List<Map<String, dynamic>> result = await DatabaseHelper().getEveryQuiz();
    return result;
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
    _dbData = _getDataFromDB();
    _loadFontSizePrefs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index];
              var title = Text(
                '${item['Name']}',
                style: TextStyle(
                    fontSize: fontSize + 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              );
              var image = Image.memory(
                item['Image'],
                fit: BoxFit.fitWidth,
              );

              return GestureDetector(
                onTap: () {
                  item['QuizCount'] < 1
                      ? ScaffoldMessenger.of(context)
                          .showMaterialBanner(MaterialBanner(
                              backgroundColor: Colors.red,
                              content: Text(
                                '${item['Name']} will be vailable soon...',
                                style: TextStyle(
                                    fontSize: fontSize + 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              actions: [
                              TextButton(
                                onPressed: () {
                                  // Pop the banner when the button is pressed
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentMaterialBanner();
                                },
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                      fontSize: fontSize + 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ]))
                      : {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LevelPage(
                                catId: item['ID'],
                                title: item['Name'],
                                description: item['Description'],
                                coverImage: image,
                                tag: 'cover-$index'),
                          )),
                          ScaffoldMessenger.of(context)
                              .hideCurrentMaterialBanner()
                        };
                },
                child: Card(
                  elevation: 5,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  margin: const EdgeInsets.only(
                      top: 5, left: 10, right: 10, bottom: 5),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              30), // Match the card's border radius
                          child: Hero(
                            tag: 'cover-$index',
                            child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    item['QuizCount'] < 1
                                        ? Colors.grey
                                        : Colors.transparent,
                                    BlendMode.saturation),
                                child: image),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Colors.black, Colors.transparent],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter)),
                          ),
                        ),
                        Positioned(
                            top: 15,
                            right: 15,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                item['QuizCount'] < 1
                                    ? 'Coming soon...'
                                    : '${item['QuizCount']} Questions',
                                style: TextStyle(
                                    fontSize: fontSize + 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            )),
                        Positioned(bottom: 5, left: 20, child: title),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
