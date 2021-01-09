import 'dart:convert';
import 'package:aninet/Recognition/RecognitionOwnerScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'SignInWithFacebook.dart';
import 'SignInWithGMail.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var email, password;
  var host = '';


  login(email,password) async {
    //real device port - http://192.168.0.127:5000
    //emu device port - 10.0.2.2
    var url = "http://10.0.2.2:5000/owner/login";
    if(email != '' && password != ''){
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
      await prefs.setString('ownerIdLog', parse["id"]);
      await prefs.setString('ownerEmailLog', parse["email"]);

    }

  }

  Widget build(BuildContext context) {
    checkToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token");
      prefs.getBool("fromGMail");
      if(token!=null){
        Navigator.pushNamed(context, "RecognitionOwnerScreen");
      }
    }
    checkToken();
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true, title: Text("Login User", style: TextStyle(color: Colors.black),), iconTheme: IconThemeData(color: Colors.black),),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.6, 0.8],
            colors: [
              Color(0xff17bae3),
              Color(0xff42f5dd),
              Color(0xff86a1ef),

            ],
          ),
        ),
        child: ListView(
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
            SizedBox(height: 10,),
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
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton.icon(
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Icon(FontAwesomeIcons.connectdevelop),
                  ),
                  color: Colors.blueGrey,
                  label: Padding(
                    padding: const EdgeInsets.only(right: 9.0),
                    child: Text(
                      'Log In',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  textColor: Colors.white,
                  splashColor: Colors.blueGrey,
                  onPressed: () async {
                    await login(email, password);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String token = prefs.getString("token");
                    await prefs.setBool("fromGMail", false);
                    await prefs.setBool("fromFacebook", false);
                    if(token!=null){
                      Navigator.pushNamed(context, "RecognitionOwnerScreen");
                    }
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.blueGrey)),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton.icon(
                  icon: Image.asset("assets/gmail.png", height: 25, width: 25),
                  color: Colors.blue,
                  label: Text(
                    'GMail',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  splashColor: Colors.blue,
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("fromGMail", true);
                    signInWithGoogle().then((result) {
                      if (result != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return RecognitionOwnerScreen();
                            },
                          ),
                        );
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
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.facebook),
                  color: Colors.blue[900],
                  label: Text(
                    'Facebook',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  splashColor: Colors.blue[900],
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("fromFacebook", true);
                    /*loginWithFacebook().then((result) {
                      print(result);
                      if (result != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return RecognitionOwnerScreen();
                            },
                          ),
                        );
                      }
                    });*/
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.blue[900])),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Center(
              child: GestureDetector(
                child: Text(
                  "Sign Up ?",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, "SignUp");

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

