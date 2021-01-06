import 'dart:async';
import 'dart:convert';

import 'package:aninet/Authentication/SignInWithGMail.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../Live/BoxResults.dart';
import '../Live/CameraLiveScreen.dart';

class RecognitionOwnerScreen extends StatefulWidget {
  RecognitionOwnerScreen({Key key}) : super(key: key);
  _RecognitionOwnerScreenState createState() => _RecognitionOwnerScreenState();
}

class _RecognitionOwnerScreenState extends State<RecognitionOwnerScreen> {
  List<CameraDescription> cameras;
  bool live = false;
  List recognitions;

  int imageHeight = 0;
  int imageWidth = 0;
  bool loading = false;
  bool camera;
  File imageCam;
  File imageGallery;
  String animalOutput = "";
  String typeOutput = "";

  String confidence = "";
  final picker = ImagePicker();
  static AudioCache player1 = AudioCache();
  static AudioCache player2 = AudioCache();
  bool guest;
  Size screenSize;
  LocationData _locationData;
  var longitude, latitude ;
  var animalId = '';
  var emailFromLogin;
  var ownerEmailLog;
  var ownerName;
  var ownerAvatarUrl;
  var animalName;
  var animalType;
  var animalAvatarUrl;
  var ownerIdLog = '';
  var isGMail = false;
  var isFacebook = false;
  var ownerEMailForPhone = '';
  var lostAniOwPhone = '';
  var lostAniOwnerName = '';
  bool isFromCam;

  getOwnerProfile(ownerIdLog) async {
    var url = "http://10.0.2.2:5000/owner/$ownerIdLog";
    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var parse = await jsonDecode(response.body);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(parse["doc"]!=null){
      await prefs.setString('email', parse["doc"]["email"]);
      await prefs.setString('ownerName', parse["doc"]["ownerName"]);
      await prefs.setString('ownerAvatarUrl', parse["doc"]["ownerAvatarUrl"]);
    }
  }
  getAnimalProfile() async {
    var url = "http://10.0.2.2:5000/animals/$ownerEmailLog";
    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = json.decode(response.body);
    if(parse["doc"]!=null){
      await prefs.setString('animalType', parse["doc"]["animalType"]);
      await prefs.setString('animalName', parse["doc"]["animalName"]);
      await prefs.setString('animalAvatarUrl', parse["doc"]["animalAvatarUrl"]);
    }

  }
  getAnimalOwnerEmail(output) async {
    var url = "http://10.0.2.2:5000/animals/found/$output";
    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var parse = json.decode(response.body);
    ownerEMailForPhone = parse["email"];
  }
  getAnimalOwnerPAndN(ownerEMailForPhone) async {
    var url = "http://10.0.2.2:5000/owner/found/phone/$ownerEMailForPhone";
    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var parse = json.decode(response.body);
    lostAniOwPhone = parse["phone"];
    lostAniOwnerName = parse["name"];
    print(lostAniOwnerName);
  }


  Future <void> playAudio()async {
    Timer(Duration(seconds: 3), () {
      player1.play('audio/Whistle.mp3');
      Timer(Duration(seconds: 3), () {
        player2.play('audio/cat.mp3');
      });
    });
  }

  userAccountDrawerHeader(){
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.5, 0.9],
          colors: [
            Color(0xff7676ff),
            Color(0xff3b3bff),
            Color(0xff5959e1),
          ],
        ),
      ),
      accountName: isGMail==false ? ownerName != null ? Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(
          ownerName,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Times New Roman'
          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text("Owner Name"),
      ): name != null ? Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(
          name,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Times New Roman'
          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text("Owner Name"),
      ),
      accountEmail: isGMail == false ? emailFromLogin!=null ? Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(
          emailFromLogin,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Times New Roman'

          ),
        ),
      ): Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text("Email"),
      ):email!=null ? Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(
          email,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Times New Roman'

          ),
        ),
      ): Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text("Email"),
      ),
      currentAccountPicture: CircleAvatar(
        child: isGMail==false?ownerAvatarUrl!=null
            ? Container(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(65.0),
                child: Image.network(
                    ownerAvatarUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover
                ),
            ),
        ):FlutterLogo(size: 30,):imageUrl!=null
            ? Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(65.0),
            child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover
            ),
          ),
        ):FlutterLogo(size: 30,),
      ),
    );
  }
  animalAccountDrawerHeader(){
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.5, 0.9],
          colors: [
            Color(0xff8989ff),
            Color(0xff5959e1),
            Color(0xffb1b1ff),
          ],
        ),
      ),
      accountName: isGMail==false? animalName != null ? Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: Text(
          animalName,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Times New Roman'

          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: Text("Animal Name"),
      ):animalN != null ? Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: Text(
          animalN,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Times New Roman'

          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: Text("Animal Name"),
      ),
      accountEmail: isGMail==false? animalType != null ? Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: Text(
          animalType,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Times New Roman'
          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: Text("Animal Type"),
      ):animalT != null ? Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: Text(
          animalT,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Times New Roman'
          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.only(left: 13.0),
        child: Text("Animal Type"),
      ),
      currentAccountPicture: CircleAvatar(
        child: isGMail==false ?
          animalAvatarUrl != null ?
            Container(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(65.0),
                    child: Image.network(
                        animalAvatarUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover
                    ),
                ),
            ):FlutterLogo(size: 30,):
        animalU != null ?
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(65.0),
            child: Image.network(
                animalU,
                height: 100,
                width: 100,
                fit: BoxFit.cover
            ),
          ),
        ):FlutterLogo(size: 30,),
      ),
    );
  }


  checkGuest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      guest = prefs.getBool("guest");
      ownerIdLog = prefs.getString("ownerIdLog");
      animalId = prefs.getString('animalId');
      emailFromLogin = prefs.getString("email");
      ownerEmailLog = prefs.getString("ownerEmailLog");
      ownerName = prefs.getString("ownerName");
      ownerAvatarUrl = prefs.getString("ownerAvatarUrl");
      animalType = prefs.getString("animalType");
      animalName = prefs.getString("animalName");
      animalAvatarUrl = prefs.getString("animalAvatarUrl");
      isGMail = prefs.getBool("fromGMail");
      isFacebook = prefs.getBool("fromFacebook");
    });

  }


  Future<void> getLocationAndSendSMS() async {
    if(animalOutput!=null){
      await getAnimalOwnerEmail(animalOutput);
      await getAnimalOwnerPAndN(ownerEMailForPhone);
    }
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("could'ent");
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    longitude = _locationData.longitude.toString();
    latitude = _locationData.latitude.toString();
    print( latitude + ' ' + longitude);
    Timer(const Duration(seconds: 5), () {
      print("Sending location to owner "+latitude + ' ' + longitude);
      FlutterOpenWhatsapp.sendSingleMessage(
          "+972" + lostAniOwPhone,
          "Hello" + lostAniOwnerName + "Your dog $animalOutput has found on location:\n"+
          "https://maps.google.com/maps?q=loc:$latitude,$longitude"
      ).whenComplete(() => (){
        print("sanded");
      });
    });
  }

  initializedCamera() async{
    try {
      cameras = await availableCameras();
      if(cameras.isNotEmpty){
        camera = true;
        if(camera == true){
          await playAudio();
        }
      }
    }
    catch(e){
      print("Error: $e");
    }
  }

  loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model/specificAnimalModel.tflite",
        labels: "assets/model/specificAnimalLabels.txt",
      );
      print("Model loaded successfully");
    }catch(e){
      print("Couldn't load the model $e");
    }
  }

  loadModelOfAnimalType() async {
    try {
      await Tflite.loadModel(
        model: "assets/model/dorOrCatModel.tflite",
        labels: "assets/model/dogOrCatLabels.txt",
      );
      print("Model Type loaded successfully");
    }catch(e){
      print("Couldn't load the model $e");
    }
  }

  Future getImage() async {
    final imageFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if(imageFile != null){
        loading = true;
        imageCam = File(imageFile.path);
      }
      else{
        Text("Image not selected yet");
      }
    });
    getLabel(imageCam);
  }

  Future getGalleryImage() async {
    final imageFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {
      if(imageFile != null){
        loading = true;
        imageGallery = File(imageFile.path);
      }
      else{
        Text("Image not selected yet");
      }
    });
    //TODO: fix the second time not working type model
    getLabelOfAnimalType(imageGallery);
  }

  getLabelOfAnimalType(File _image) async {
    loadModelOfAnimalType().then((value){
      setState(() {
        loading = false;
      });
    });
    var res = await Tflite.runModelOnImage(
      path: _image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      loading = false;
      recognitions = res;
      String str = recognitions[0]["label"];
      typeOutput = str.substring(2);
      confidence = recognitions != null ? (recognitions[0]["confidence"]*100.0).toString().substring(0, 2) + '%': "";
      print(typeOutput + " " + confidence);
      int numberConfidence = int.tryParse(confidence.substring(0, 2));
      print(numberConfidence);
      if(numberConfidence>=85){
        getLabel(imageGallery);
      }
      print(recognitions);
    });
  }

  getLabel(File _image) async {
    loadModel().then((value){
      setState(() {
        loading = false;
      });
    });
    var res = await Tflite.runModelOnImage(
      path: _image.path,
      numResults: 12,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      loading = false;
      recognitions = res;
      String str = recognitions[0]["label"];
      animalOutput = str.substring(2);
      confidence = recognitions != null ? (recognitions[0]["confidence"]*100.0).toString().substring(0, 2) + '%': "";
      print(animalOutput + " " + confidence);
      int numberConfidence = int.tryParse(confidence.substring(0, 2));
      print(numberConfidence);
      if(numberConfidence>=85){
        getLocationAndSendSMS();
      }
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

  void initState(){
    super.initState();
    checkGuest();
    setState(() {
      loading = true;
      camera = false;
      longitude = '';
      latitude = '';
      emailFromLogin = '';
      ownerName = '';
      ownerAvatarUrl = '';
      animalName = '';
      animalType = '';
      animalAvatarUrl = '';
    });
    loadModelOfAnimalType().then((value){
      setState(() {
        loading = false;
      });
    });

  }

  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkGuest();
    if(isGMail==false){
      getOwnerProfile(ownerIdLog);
      getAnimalProfile();
    }
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('AniNET', style: TextStyle(color: Colors.white70,)),),
        actions: <Widget>[
          guest != true ? buildLogoutIcon(): Container(),
        ],
      ),
      backgroundColor: Color(0xff42a5f5),
      body: !live ? Container(child: buildPictureRecognitionRes()):
      buildLiveRecognitionRes(),
      drawer: Container(
        width: 250,
        child: Drawer(
          child: drawerItems(),
        ),
      ),
    );
  }

  Widget drawerItems(){
    return ListView(
      children: [
        Container(
          height: 180,
          child: userAccountDrawerHeader(),
        ),
        Container(
          height: 180,
          child: animalAccountDrawerHeader(),
        ),

        Card(
          child: ListTile(
            title: Text(
              'Image from Camera',
              style: TextStyle(fontSize: 16, fontFamily: 'Times New Roman', color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            leading: const FaIcon(FontAwesomeIcons.camera, color: Colors.black,),
            onTap: () {
              isFromCam = true;
              setState(() {
                live = false;
              });
              initializedCamera();
              print(camera);
              if (camera == true) {
                getImage();
              }
            }
          ),
        ),
        Card(
          child: ListTile(
              title: Text(
                'Image from Gallery',
                style: TextStyle(fontSize: 16, fontFamily: 'Times New Roman', color: Colors.black87, fontWeight: FontWeight.w600),
              ),
              leading: const FaIcon(FontAwesomeIcons.image, color: Colors.black,),
              onTap: () {
                isFromCam = false;
                setState(() {
                  live = false;
                });
                initializedCamera();
                print(camera);
                if (camera == true) {
                  getGalleryImage();
                }
              }
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              'LIVE',
              style: TextStyle(fontSize: 16, fontFamily: 'Times New Roman', color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            leading: const FaIcon(FontAwesomeIcons.stream, color: Colors.black,),
            onTap: () {
              setState(() {
                live = true;
              });
              initializedCamera();
              loadModel();
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              'Display All Animals',
              style: TextStyle(fontSize: 16, fontFamily: 'Times New Roman', color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            leading: const FaIcon(FontAwesomeIcons.list, color: Colors.black,),
            onTap: () {
              Navigator.pushReplacementNamed(context, "AnimalsList");
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              'Display All Owners',
              style: TextStyle(fontSize: 16, fontFamily: 'Times New Roman', color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            leading: const FaIcon(FontAwesomeIcons.list, color: Colors.black,),
            onTap: () {
              Navigator.pushReplacementNamed(context, "OwnersList");
            },
          ),
        ),
      ],
    );
  }

  Widget buildLogoutIcon(){
    return FlatButton.icon(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", null);
          isGMail = prefs.getBool("fromGMail");
          isFacebook = prefs.getBool("fromFacebook");
          if(isGMail==true){
            await prefs.setBool("fromGMail", false);
            signOutGoogle();
            Navigator.pushReplacementNamed(context, "Login");
          }else if(isFacebook==true){
            await prefs.setBool("fromFacebook", false);
            //logOutWithFacebook();
            Navigator.pushReplacementNamed(context, "Login");
          }
          Navigator.pushReplacementNamed(context, "Login");
        },
        icon: Column(
          children: [
            SizedBox(height: 10,),
            Icon(Icons.exit_to_app, color: Colors.white70,),
            Text("logout", style: TextStyle(color: Colors.white70)),
          ],
        ),
      label: Text(''),

    );
  }

  Widget buildPictureRecognitionRes(){
    return Container(
      child: Center(
        child: ListView(
          children: <Widget>[
            loading ? Container(
              alignment: Alignment.center,
              child: Center(child: CircularProgressIndicator()),
            ):
            Container(
              width: screenSize.width * 1,
              height: screenSize.height * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    recognitions == null ?
                    Image.asset(
                      'assets/main.png',
                      height: 560,
                      fit: BoxFit.fill,
                    ):
                    Container(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$typeOutput",
                              style: TextStyle(color: Colors.redAccent, fontSize: 20, fontFamily: 'Times New Roman'),
                            ),
                            TextSpan(
                              text: " Found Is: ",
                              style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Times New Roman'),
                            ),
                            TextSpan(
                              text: "$animalOutput",
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Times New Roman'),
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
                      child: isFromCam==true? imageCam !=null ?
                      Card(
                        child: Image.file(
                          imageCam,
                          width: screenSize.width * 0.7,
                          height: screenSize.height*0.7,
                        ),
                      ):Container(): imageGallery != null ?
                        GestureDetector(
                          onTap: (){
                            //TODO: go to shared owner and animal profiles
                            //Navigator.pushReplacementNamed(context, "DetailedAnimal");
                          },
                          child: Container(
                            height: screenSize.width * 0.8,
                            width: screenSize.width * 0.8,
                            child: Card(
                              child: Image.file(
                                imageGallery,
                                width: screenSize.width * 1,
                                height: screenSize.height * 1,
                              ),
                            ),
                          ),
                        ) : Container(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLiveRecognitionRes(){
    return Stack(
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
    );
  }

}
