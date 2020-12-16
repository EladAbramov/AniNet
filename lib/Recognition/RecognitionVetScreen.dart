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

class RecognitionVetScreen extends StatefulWidget {
  RecognitionVetScreen({Key key}) : super(key: key);
  _RecognitionVetScreenState createState() => _RecognitionVetScreenState();
}

class _RecognitionVetScreenState extends State<RecognitionVetScreen> {
  List<CameraDescription> cameras;
  bool live = false;
  List<dynamic> recognitions;
  int imageHeight = 0;
  int imageWidth = 0;
  bool loading = false;
  bool camera;
  File image;
  List outputs;
  String output = "";
  String confidence = "";
  final picker = ImagePicker();
  static AudioCache player1 = AudioCache();
  static AudioCache player2 = AudioCache();


  void playAudio(){
    Timer(Duration(seconds: 7), () {
      player1.play('audio/Whistle.mp3');
      Timer(Duration(seconds: 7), () {
        player2.play('audio/cat.mp3');
      });
    });
  }

  @override
  void initState() {
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
      outputs = res;
      String str = outputs[0]["label"];
      output = str.substring(2);
      confidence = outputs != null ? (outputs[0]["confidence"]*100.0).toString().substring(0, 2) + '%': "";

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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('AniNet Vet', style: TextStyle(color: Colors.black),)),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("vetToken", null);
                Navigator.pushNamed(context, "LoginVet");
              },
              icon: Icon(Icons.exit_to_app, color: Colors.white,),
              label: Text("logout", style: TextStyle(color: Colors.white),)
          ),
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
              width: size.width*1,
              height: size.height*0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  outputs == null ? Container()
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
                    child: image != null ? Image.file(image, width: size.width * 1) : Container(),
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
            size.height,
            size.width,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton.icon(
              label: Text("Choose Image"),
              icon: Icon(Icons.camera),
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
            ),
            RaisedButton.icon(
              label: Text("On Live"),
              icon: Icon(Icons.live_tv),
              onPressed: () {
                setState(() {
                  live = true;
                });
                initializedCamera();
                loadModel();
              },
            )
          ],
        ),
      ),
    );
  }

}
