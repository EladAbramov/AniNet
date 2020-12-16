import 'package:aninet/Authentication/LoginVet.dart';
import 'package:aninet/Authentication/SignUp.dart';
import 'package:aninet/ChooseAccountScreen.dart';
import 'package:aninet/OnBoarding.dart';
import 'package:aninet/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'Authentication/Login.dart';
import 'Authentication/SignUpVet.dart';
import 'Recognition/RecognitionScreen.dart';
import 'Recognition/RecognitionVetScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  runApp(AniNet());
}

class AniNet extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot){
          if (snapshot.hasError) {
            print("no");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Splash();
          }
          return loading();

        }
      ),
      debugShowCheckedModeBanner: false,
      routes:
      {
        "OnBoarding": (context) => OnBoarding(),
        "ChooseAccountScreen": (context) => ChooseAccountScreen(),
        "Login": (context) => Login(),
        "SignUp": (context) => SignUp(),
        "SignUpVet": (context) => SignUpVet(),
        "LoginVet": (context) => LoginVet(),
        "RecognitionScreen": (context) => RecognitionScreen(),
        "RecognitionVetScreen": (context) => RecognitionVetScreen(),

      },
    );
  }

  loading() {
    return CircularProgressIndicator();
  }
}

