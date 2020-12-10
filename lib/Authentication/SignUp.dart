import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatelessWidget {
  var email, password;

  signUp(email,password) async {
    var url = "http://10.0.2.2:5000/signup";
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
    checkToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token");
      if(token!=null){
        Navigator.pushNamed(context, "RecognitionScreen");
      }
    }
    checkToken();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(
                  placeholder: "Email",
                  keyboardType: TextInputType.emailAddress,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  autocorrect: false,
                  onChanged: (value) {
                    email = value;
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(
                  clearButtonMode: OverlayVisibilityMode.editing,
                  placeholder: "Password",
                  obscureText: true,
                  autocorrect: false,
                  onChanged: (value) {
                    password = value;
                  }
              ),
            ),
            FlatButton.icon(
              icon: Icon(Icons.save),
              label: Text("Sign Up"),
              onPressed: () async {
                await signUp(email, password);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String token = prefs.getString("token");
                if(token!=null){
                  Navigator.pushNamed(context, "RecognitionScreen");
                }
              },
            ),
            FlatButton(
              onPressed: () {
                Navigator.pushNamed(context, "Login");
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

