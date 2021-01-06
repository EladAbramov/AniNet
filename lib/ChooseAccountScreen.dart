import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseAccountScreen extends StatelessWidget {
  String option="";

  Widget build(BuildContext context) {
    checkToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token");
      String vetToken = prefs.getString("vetToken");
      bool isOwnerProfFinished = prefs.getBool("ownerFinished");
      bool isAnimalProfFinished = prefs.getBool("animalFinished");

      if(vetToken!=null && option=="vet"){
          Navigator.pushNamed(context, "RecognitionVetScreen");
      }else
        if(token!=null && isOwnerProfFinished!=false && isAnimalProfFinished!=false && option=="user"){
          Navigator.pushNamed(context, "RecognitionOwnerScreen");
        }else
          if(token == null && option=='guest'){
            Navigator.pushNamed(context, "RecognitionGuestScreen");
          }
    }
    checkToken();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "Choose Your Account",
            style: TextStyle(
                fontSize: 22,
                fontFamily: 'Times New Roman',
                color: Colors.black
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.7, 0.9],
            colors: [
              Color(0xff86a1ef),
              Color(0xff42f5dd),
              Color(0xff17bae3),

            ],
          ),
        ),
        child: Center(
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
                        label: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Text("Come As Vet", style: TextStyle(fontSize: 20, fontFamily: 'Times New Roman', color: Colors.white)),
                        )
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.blue)),
                  ),

                ),
                SizedBox(height: 40,),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: ButtonTheme(
                    minWidth: 200,
                    height: 50,
                    child: RaisedButton.icon(
                        onPressed: ()async{
                          option="user";
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          bool isOwnerProfFinished = prefs.getBool("ownerFinished");
                          bool isAnimalProfFinished = prefs.getBool("animalFinished");
                          prefs.setBool("guest", false);
                          String token = prefs.getString("token");
                         /* if(isOwnerProfFinished!=true || token!=null){
                            Navigator.pushNamed(context, "OwnerProfile");
                          }else*/
                          if(isAnimalProfFinished!=true && isOwnerProfFinished==true && token!=null){
                            Navigator.pushNamed(context, "AnimalProfile");
                          }else {
                            Navigator.pushNamed(context, "SignUp");
                          }
                        },
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: FaIcon(FontAwesomeIcons.user, color: Colors.white, size: 16),
                        ),
                        label: Text("Come As User", style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Times New Roman'))
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.blue)),
                  ),
                ),
                SizedBox(height: 50,),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: ButtonTheme(
                    minWidth: 200,
                    height: 50,
                    child: RaisedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool("guest", true);
                          Navigator.pushNamed(context, "RecognitionGuestScreen");
                        },
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FaIcon(FontAwesomeIcons.search, color: Colors.white, size: 16),
                        ),
                        label: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text("Come As Guest", style: TextStyle(fontSize: 20, fontFamily: 'Times New Roman', color: Colors.white)),
                        )
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.blue)),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
