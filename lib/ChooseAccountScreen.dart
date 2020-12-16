import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseAccountScreen extends StatelessWidget {

  String option="";
  @override
  Widget build(BuildContext context) {
    checkToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token");
      String vetToken = prefs.getString("vetToken");
      if(vetToken!=null && option=="vet"){
          Navigator.pushNamed(context, "RecognitionVetScreen");
      }else if(token!=null && option=="user"){
        Navigator.pushNamed(context, "RecognitionScreen");
      }
    }
    checkToken();
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Your Account", style: TextStyle(color: Colors.black),),
      ),
      backgroundColor: Colors.cyan[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Text("Come As You Are", style: TextStyle(fontSize: 30, fontFamily: 'Times New Roman', color: Colors.black),),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200),
                child: ButtonTheme(
                  minWidth: 200,
                  height: 50,
                  child: RaisedButton.icon(
                      onPressed: () {
                        option = "Vet";
                        Navigator.pushNamed(context, "SignUpVet");
                      },
                      icon: Icon(CupertinoIcons.paw_solid, color: Colors.white),
                      label: Text("Come As Vet", style: TextStyle(fontSize: 20, fontFamily: 'Times New Roman', color: Colors.white))
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.blue)),
                ),

              ),
              SizedBox(height: 30,),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200),
                child: ButtonTheme(
                  minWidth: 200,
                  height: 50,
                  child: RaisedButton.icon(
                      onPressed: (){
                        option="user";
                        Navigator.pushNamed(context, "SignUp");
                      },
                      icon: FaIcon(FontAwesomeIcons.user, color: Colors.white, size: 16),
                      label: Text("Come As User", style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Times New Roman'))
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.blue)),
                ),
              ),
              SizedBox(height: 30,),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200),
                child: ButtonTheme(
                  minWidth: 200,
                  height: 50,
                  child: RaisedButton.icon(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("guest", true);
                        Navigator.pushNamed(context, "RecognitionScreen");
                      },
                      icon: FaIcon(FontAwesomeIcons.search, color: Colors.white, size: 16),
                      label: Text("Come As Guest", style: TextStyle(fontSize: 20, fontFamily: 'Times New Roman', color: Colors.white))
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
