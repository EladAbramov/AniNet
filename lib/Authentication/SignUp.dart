import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var email, password;
  final formKey = new GlobalKey<FormState>();

  signUp(email, password) async {
    //real device port - 192.168.0.127
    //emu device port - 10.0.2.2
    var url = "http://10.0.2.2:5000/owner/signup";
    if(email!='' && password !=''){
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
      await prefs.setString('email', parse["emailFromServer"]);
      await prefs.setString('password', parse["password"]);
    }
  }



  _saveForm() {
    final form = formKey.currentState.validate();
    if(!form) {
      return;
    }
    formKey.currentState.save();
    print("form saved");

  }

  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up User", style: TextStyle(color: Colors.black),), iconTheme: IconThemeData(color: Colors.black),),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.9],
            colors: [
              Color(0xff59a3de),
              Color(0xff86a1ef),
            ],
          ),
        ),
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 100),
            children: [
              buildEmailConstraintsBox(),
              SizedBox(height: 10,),
              buildPasswordConstraintBox(),
              SizedBox(height: 10,),
              buildSignUpButton(),
              buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildEmailConstraintsBox(){
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding:
        const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          autocorrect: true,
          onSaved: (String val) {
            email = val;
          },
          onChanged: (val){
            email = val;
          },
          validator: (value) {
            if (value.isEmpty){
              return 'Enter a valid email!';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            contentPadding: new EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            hintText: "Email",
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.5
                ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordConstraintBox() {
    return ConstrainedBox(
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
          validator: (value) {
            if (value.isEmpty) {
              return 'Enter a valid password!';
            }
            return null;
          },
          obscureText: true,
          autocorrect: false,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            contentPadding: new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            hintText: 'Password',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.5
                )
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignUpButton(){
    return Padding(
      padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: RaisedButton.icon(
          icon: Icon(CupertinoIcons.create),
          color: Colors.blueGrey,
          label: Text(
            'Sign Up',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          textColor: Colors.white,
          splashColor: Colors.blue,
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await signUp(email, password);
            String token = prefs.getString("token");
            if(token!=null){
              _saveForm();
              Navigator.pushNamed(context, "OwnerProfile");
            }
          },
          padding: EdgeInsets.only(top: 12, bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(color: Colors.blue)),
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
      child: GestureDetector(
        child: Column(
          children: [
            Center(child: Text("Already have account?", style: TextStyle(fontSize: 16, color: Colors.black87))),
            SizedBox(height: 5),
            Center(child: Text("Log In", style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600))),
          ],
        ),
        onTap: () {
          Navigator.pushReplacementNamed(context, "Login");
        },
      ),
    );
  }
}
