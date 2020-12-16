import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../Live/BoxResults.dart';
import '../Live/CameraLiveScreen.dart';


class RecognitionScreen extends StatefulWidget {
  RecognitionScreen({Key key}) : super(key: key);
  _RecognitionScreenState createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  List<CameraDescription> cameras;
  bool live = false;
  List recognitions;
  int imageHeight = 0;
  int imageWidth = 0;
  bool loading = false;
  bool camera;
  File image;
  String output = "";
  String confidence = "";
  final picker = ImagePicker();
  static AudioCache player1 = AudioCache();
  static AudioCache player2 = AudioCache();
  bool guest;
  Size screenSize;

  void playAudio(){
    Timer(Duration(seconds: 7), () {
      player1.play('audio/Whistle.mp3');
      Timer(Duration(seconds: 7), () {
        player2.play('audio/cat.mp3');
      });
    });
  }
  checkGuest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    guest = prefs.getBool("guest");
  }

  @override
  void initState(){
    super.initState();
    loading = true;
    camera = false;
    loadModel().then((value){
      setState(() {
        loading = false;
      });
    });
  }
  initializedCamera() async{
    try {
      cameras = await availableCameras();
      if(cameras.isNotEmpty){
        camera = true;
        playAudio();
      }
    }
    catch(e){
      print("Error: $e");
    }
  }
  loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model/model_unquant.tflite",
        labels: "assets/model/labels.txt",
      );
      print("Model loaded successfully");
    }catch(e){
      print("Couldn't load the model $e");
    }

  }

  Future getImage() async {
    final imageFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if(imageFile != null){
        loading = true;
        image = File(imageFile.path);
      }
      else{
        Text("Image not selected yet");
      }
    });
    getLabel(image);
  }


  getLabel(File _image) async {
    var res = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 12,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      loading = false;
      recognitions = res;
      String str = recognitions[0]["label"];
      output = str.substring(2);
      confidence = recognitions != null ? (recognitions[0]["confidence"]*100.0).toString().substring(0, 2) + '%': "";
      print(recognitions);
    });
  }

  setRecognitions(_recognitions, _imageHeight, _imageWidth) {
    setState(() {
      recognitions = _recognitions;
      imageHeight = _imageHeight;
      imageWidth = _imageWidth;
    });
  }

  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkGuest();
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('AniNet', style: TextStyle(color: Colors.black),)),
        actions: <Widget>[
          guest!=true?FlatButton.icon(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString("token", null);
              Navigator.pushNamed(context, "Login");
            },
            icon: Icon(Icons.exit_to_app, color: Colors.white,),
            label: Text("logout", style: TextStyle(color: Colors.white),)
          ):Container(),
        ],
      ),
      body: !live ? Center(
        child: ListView(
          children: <Widget>[
            loading ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ):
            Container(
              width: screenSize.width * 1,
              height: screenSize.height * 0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  recognitions == null ? Container()
                  : Container(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "The Dog or Cat name is: ",
                            style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Times New Roman'),
                          ),
                          TextSpan(
                            text: "$output",
                            style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Times New Roman'),
                          ),
                          TextSpan(
                            text: "\n\nConfidence: ",
                            style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Times New Roman'),
                          ),
                          TextSpan(
                            text: "$confidence",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Times New Roman'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: image != null ? Image.file(image, width: screenSize.width * 0.9) : Container(),
                  ),
                ],
              ),
            )
          ],
        ),
      ):
      Stack(
        children: [
          CameraLiveScreen(
            cameras,
            setRecognitions,
          ),
          BoxResults(
            recognitions == null ? [] : recognitions,
            math.max(imageHeight, imageWidth),
            math.min(imageHeight, imageWidth),
            screenSize.height,
            screenSize.width,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180),
              child: RaisedButton.icon(
                icon: Icon(Icons.camera),
                color: Colors.blue[500],
                label: Text(
                  "Choose Image",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                splashColor: Colors.blue,
                onPressed: () {
                  setState(() {
                    live = false;
                  });
                  initializedCamera();
                  print(camera);
                  if(camera == true){
                    getImage();
                  }
                },
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.blue)),
              ),
            ),
            SizedBox(width: 10,),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180),
              child: RaisedButton.icon(
                icon: Icon(Icons.live_tv),
                color: Colors.blue[800],
                label: Text(
                  'On Live',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                splashColor: Colors.blue,
                onPressed: () {
                  setState(() {
                    live = true;
                  });
                  initializedCamera();
                  loadModel();
                },
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
