import 'package:flutter/material.dart';
import 'Authentication/Login.dart';
import 'RecognitionScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AniNet());
}

class AniNet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RecognitionScreen(),
      debugShowCheckedModeBanner: false,
      routes:
      {
        "RecognitionScreen": (context) => RecognitionScreen(),
        "Login": (context) => Login(),
      },
    );
  }
}

