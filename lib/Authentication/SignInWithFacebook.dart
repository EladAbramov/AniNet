/*
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Map<String, dynamic> _userData;
AccessToken _accessToken;
var faceEmail;

Future<void> checkLoginWithFacebook() async {
  final AccessToken accessToken = await FacebookAuth.instance.isLogged;
  if (accessToken != null) {
    final userData = await FacebookAuth.instance.getUserData();
    _accessToken = accessToken;
  }
}

Future loginWithFacebook() async {
  try {
    _accessToken = await FacebookAuth.instance.login(); // by the fault we request the email and the public profile
    final userData = await FacebookAuth.instance.getUserData();
    faceEmail = FacebookAuth.instance.getUserData(fields: faceEmail);
    print("face: " + faceEmail);
    _userData = userData;
  } on FacebookAuthException catch (e) {
    print(e.message); // print the error message in console
    switch (e.errorCode) {
      case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
        print("You have a previous login operation in progress");
        break;
        case FacebookAuthErrorCode.CANCELLED:
          print("login cancelled");
          break;
        case FacebookAuthErrorCode.FAILED:
          print("login failed");
          break;
    }
  } catch (e, s) {
    print(e);
    print(s);
  } finally {}
}

  Future<void> logOutWithFacebook() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
  }
*/
