import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  List<Map<String, dynamic>> userInfo = [];
  TextEditingController nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;

  Future<void> _pickAndSaveImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();

      // await _saveUserData('userName', imageBytes);

      setState(() {
        _imageData = imageBytes;
      });
    }
  }

  Future<void> _saveUserData(String userName, Uint8List userPic) async {
    await DatabaseHelper.saveUserInfo(userName, userPic);
  }

  Future<void> _getUserInfo() async {
    // await DatabaseHelper().database;

    userInfo = await DatabaseHelper().getUserInfo();

    setState(() {
      userInfo = userInfo;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
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
                GestureDetector(
                  onTap: _pickAndSaveImage,
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 50,
                      child: _imageData != null
                          ? Image.memory(userInfo.isNotEmpty
                              ? userInfo[0]['UserPicture']
                              : _imageData)
                          : const Icon(
                              Icons.person,
                              size: 100,
                            ),
                    ),
                    const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.photo_camera_back_outlined,
                          size: 30,
                        ))
                  ]),
                ),
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
                      if (nameController.text.isNotEmpty &&
                          _imageData != null) {
                        _saveUserData(nameController.text, _imageData!);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const MyApp()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Please enter a name and a picture to start')));
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
