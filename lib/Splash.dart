import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash>
    with SingleTickerProviderStateMixin {
  var _visible = true;

  AnimationController animationController;
  Animation<double> animation;

  startTime() async {
    var _duration = new Duration(seconds: 5);
    return new Timer(_duration, navigationPage);
  }

  Future navigationPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finished = prefs.getBool("finishBoarding")  ?? false;
    if(finished){
      Navigator.of(context).pushReplacementNamed("ChooseAccountScreen");
    }
    else{
      Navigator.of(context).pushReplacementNamed("OnBoarding");
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 4));
    animation =
    new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
  }
  void dispose() {
    animationController.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff42a5f5),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/splash.png',
                width: animation.value * 300,
                height: animation.value * 300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}