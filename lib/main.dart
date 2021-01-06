import 'package:aninet/Authentication/LoginVet.dart';
import 'package:aninet/Authentication/SignUp.dart';
import 'package:aninet/ChooseAccountScreen.dart';
import 'package:aninet/OnBoarding.dart';
import 'package:aninet/Authentication/Profiles/OwnerProfile.dart';
import 'package:aninet/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'AnimalsList.dart';
import 'Authentication/Login.dart';
import 'Authentication/SignUpVet.dart';
import 'Authentication/Profiles/AnimalProfile.dart';
import 'DetailedAnimal.dart';
import 'OwnersList.dart';
import 'Recognition/RecognitionGuestScreen.dart';
import 'Recognition/RecognitionOwnerScreen.dart';
import 'Recognition/RecognitionVetScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        "RecognitionGuestScreen": (context) => RecognitionGuestScreen(),
        "RecognitionOwnerScreen": (context) => RecognitionOwnerScreen(),
        "RecognitionVetScreen": (context) => RecognitionVetScreen(),
        "AnimalProfile": (context) => AnimalProfile(),
        "OwnerProfile": (context) => OwnerProfile(),
        "AnimalsList": (context) => AnimalsList(),
        "OwnersList": (context) => OwnersList(),
        "DetailedAnimal": (context) => DetailedAnimal(),



      },
    );
  }

  loading() {
    return CircularProgressIndicator();
  }
}

