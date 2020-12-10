import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'BoxResults.dart';
import 'CameraLiveScreen.dart';

class RecognitionScreen extends StatefulWidget {
  RecognitionScreen({Key key}) : super(key: key);
  _RecognitionScreenState createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  List<CameraDescription> cameras;
  bool live = false;
  List<dynamic> recognitions;
  int imageHeight = 0;
  int imageWidth = 0;
  bool loading = false;
  File image;
  List outputs;
  String output = "";
  String confidence = "";
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loading = true;
    loadModel().then((value){
      setState(() {
        loading = false;
      });
    });
  }
  initializedCamera() async{
    try {
      cameras = await availableCameras();
    }
    catch(e){
      print("Error: $e");
    }
  }
  loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
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
      numResults: 3,
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
        title: Center(child: Text('AniNet')),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString("token", null);
              Navigator.pushNamed(context, "Login");
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
              width: size.width*0.8,
              height: size.height*0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: image != null ? Image.file(image, width: size.width * 0.5) : Container(),
                  ),
                  outputs == null ? Container() : Text("$output\nconfidence: $confidence"),
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
            RaisedButton(
              child: Text("Choose Image"),
              onPressed: () {
                setState(() {
                  live = false;
                });
                initializedCamera();
                getImage();
              },
            ),
            RaisedButton(
              child: Text("Live"),
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
