import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  var email, password;

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
      appBar: AppBar(),
      body: CupertinoPageScaffold(
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
                onPressed: () async {
                  await login(email, password);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String token = prefs.getString("token");
                  if(token!=null){
                    Navigator.pushNamed(context, "RecognitionScreen");
                  }
                },
                icon: Icon(Icons.save),
                label: Text("Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

