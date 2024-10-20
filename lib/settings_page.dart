import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mexam/database_helper.dart';
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
    await DatabaseHelper.updateUserInfo(userName, userPic);
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    // await DatabaseHelper().database;

    userInfo = await DatabaseHelper().getUserInfo();

    setState(() {
      userInfo = userInfo;
    });
  }

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

  _showPickDialog() {
    nameController.text = userInfo[0]['UserName'];
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text(_imageData == null
                    ? 'Create your profile'
                    : 'Update your profile'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // _pickAndSaveImage();
                        final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final imageBytes = await pickedFile.readAsBytes();

                          // await _saveUserData('userName', imageBytes);

                          setState(() {
                            _imageData = imageBytes;
                          });
                        }
                      },
                      child: SizedBox(
                          width: 100,
                          height: 100,
                          child: _imageData != null
                              ? Image.memory(_imageData!)
                              : userInfo[0]['UserPicture'] != null
                                  ? Image.memory(userInfo[0]['UserPicture'])
                                  : Icon(Icons.person)),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        label: const Text('Enter your name'),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isNotEmpty &&
                                  _imageData != null) {
                                _saveUserData(nameController.text, _imageData!);
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Please enter your name')));
                              }
                            },
                            child: Text(_imageData != null ? 'Update' : '')),
                        _imageData == null
                            ? IconButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.delete))
                            : const Icon(null),
                      ],
                    )
                  ],
                ),
              );
            }));
  }

  @override
  void initState() {
    super.initState();
    _loadThemePrefs();
    _loadFontSizePrefs();
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
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
            ),
            Divider(),
            ListTile(
              onTap: _showPickDialog,
              leading: CircleAvatar(
                child: userInfo.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.memory(userInfo[0]['UserPicture']))
                    : Icon(Icons.person),
              ),
              title: Text(
                userInfo.isNotEmpty ? userInfo[0]['UserName'] : 'Loading...',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                'Tap to change',
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
