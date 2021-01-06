import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String name;
String email;
String imageUrl;
var tempON, tempOAU;
String animalN;
String animalT;
String animalU;
var tempAN,tempAT, tempAU;

getOwnerProfileGMail() async {
  print(email);
  var url = "http://10.0.2.2:5000/owner/gmail/$email";
  final http.Response response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  var parse = await jsonDecode(response.body);
  if(parse["doc"]!=null) {
    tempON = parse["doc"]["ownerName"];
    tempOAU = parse["doc"]["ownerAvatarUrl"];
  }

}


getAnimalProfileGMail() async {
  var url = "http://10.0.2.2:5000/animals/gmail/$email";
  print(url);
  final http.Response response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  var parse = await jsonDecode(response.body);
  if(parse["doc"]!=null) {
    tempAN = parse["doc"]["animalName"];
    tempAT = parse["doc"]["animalType"];
    tempAU = parse["doc"]["animalAvatarUrl"];
  }

}
Future<String> signInWithGoogle() async {
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
  await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    email = googleSignIn.currentUser.email;
    if(prefs.getBool("fromGMail")==true){
      await getOwnerProfileGMail();
      name = tempON;
      imageUrl = tempOAU;
      await getAnimalProfileGMail();
      animalN = tempAN;
      animalT = tempAT;
      animalU = tempAU;
    }
    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: $user');

    return '$user';
  }

  return null;
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Signed Out");
}