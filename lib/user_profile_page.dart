import 'package:flutter/material.dart';
import 'package:mexam/database_helper.dart';
import 'package:mexam/main.dart';

void main() {
  runApp(const MaterialApp(
    home: UserProfilePage(),
  ));
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  TextEditingController nameController = TextEditingController();

  Future<void> _saveUserData(String userName, String userPic) async {
    await DatabaseHelper.saveUserInfo(userName, userPic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Let's get started!",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 100,
                ),
                const Stack(children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.person,
                      size: 100,
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.photo_camera_back_outlined,
                        size: 30,
                      ))
                ]),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Enter your name'),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                FilledButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        _saveUserData(
                            nameController.text, 'user Picture not set');
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const MyApp()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please enter your name to start')));
                      }
                    },
                    child: const Text(
                      'Finish',
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
