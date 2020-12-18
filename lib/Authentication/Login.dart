import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  var email, password;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
    signInOption: SignInOption.standard,

  );
  Future<void> _handleSignIn() async {
    try {

      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }
  login(email,password) async {
    var url = "http://10.0.2.2:5000/login";
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password
      }),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);
    await prefs.setString('token', parse["token"]);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login User"),),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0, right: 8.0, left: 8.0),
            child: TextFormField(
              onSaved: (String val) {
                email = val;
              },
              onChanged: (value) {
                email = value;
              },
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              decoration: InputDecoration(
                contentPadding: new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'Email',
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0
                    )
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                      color: Colors.blue,
                      width: 1.5
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TextFormField(
                onSaved: (String val) {
                  password = val;
                },
                onChanged: (value) {
                  password = value;
                },
                autocorrect: false,
                obscureText: true,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: InputDecoration(
                  contentPadding: new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Password',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0
                      )
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                        color: Colors.blue,
                        width: 1.5
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40,),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: RaisedButton.icon(
                icon: Icon(FontAwesomeIcons.connectdevelop),
                color: Colors.blue,
                label: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                splashColor: Colors.blue,
                onPressed: () async {
                  await login(email, password);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String token = prefs.getString("token");
                  if(token!=null){
                    Navigator.pushNamed(context, "RecognitionScreen");
                  }
                },
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: RaisedButton.icon(
                icon: FaIcon(FontAwesomeIcons.facebook),
                color: Colors.blue,
                label: Text(
                  'Sign In ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                splashColor: Colors.blue,
                onPressed: () async {
                  await _handleSignIn().whenComplete(() => () {
                    if(_googleSignIn.currentUser.email=="elad1989@gmail.com"){
                      Navigator.pushNamed(context, "RecognitionScreen");
                    }
                    else{
                      print("There is no email");
                    }
                  });
                },
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.blue)),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

