import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(SplashApp());
}

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [Icon(Icons.thirty_fps_select), Text('MeXam')],
          ),
        ),
      ),
    );
  }
}
