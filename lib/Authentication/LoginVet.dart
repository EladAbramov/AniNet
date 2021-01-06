import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginVet extends StatelessWidget {
  var email, password, name;

  loginVet(name, email, password) async {
    //real device port - 192.168.0.127
    //emu device port - 10.0.2.2
    var url = "http://10.0.2.2:5000/vet/loginvet";
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password
      }),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);
    await prefs.setString("vetToken", parse["vetToken"]);
    }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Vet"),),
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                    child: TextFormField(
                      onSaved: (String val) {
                        name = val;
                      },
                      onChanged: (value) {
                        name = value;
                      },
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Name',
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
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Padding(
                    padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                    child: TextFormField(
                      onSaved: (String val) {
                        email = val;
                      },
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      onChanged: (value) {
                        email = value;
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Email',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.0)),
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
                      obscureText: true,
                      autocorrect: false,
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

                SizedBox(height: 40.0,),
                Padding(
                  padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: RaisedButton.icon(
                      icon: Icon(Icons.save),
                      color: Colors.blue,
                      label: Text(
                        'Login',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      textColor: Colors.white,
                      splashColor: Colors.blue,
                      onPressed: () async {
                        await loginVet(name, email, password);
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String vetToken = prefs.getString("vetToken");
                        print(vetToken);
                        if(vetToken!=null){
                          Navigator.pushNamed(context, "RecognitionVetScreen");
                        }
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
          ),
        ),
      ),
    );
  }
}

