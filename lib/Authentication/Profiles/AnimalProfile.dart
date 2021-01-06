import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class AnimalProfile extends StatefulWidget {
  @override
  _AnimalProfileState createState() => _AnimalProfileState();
}

class _AnimalProfileState extends State<AnimalProfile> {
  File animalAvatarFile;
  var animalAvatarUrl;
  var animalName;
  var animalAge;
  final formKey = new GlobalKey<FormState>();
  bool uploaded;
  final imagePicker = ImagePicker();
  bool loadingImage;
  bool loadingVideo;
  bool isOkImage = false;
  bool isOkVideo = false;
  final FirebaseStorage _imageStorage = FirebaseStorage.instance;
  UploadTask _imageUpload;
  var animalVideoUrl;
  var animalType;
  AnimalType selectedType;
  final videoInfo = FlutterVideoInfo();
  int videoSeconds = 0;
  File animalVideoFile;
  final videoPicker = ImagePicker();
  bool finished = false;
  var ownerEmail;
  final FirebaseStorage _videoStorage = FirebaseStorage.instance;
  UploadTask _videoUpload;

  List<AnimalType> types = <AnimalType>[
    const AnimalType('Dog',FaIcon(FontAwesomeIcons.dog, color:  const Color(0xFF167F67),)),
    const AnimalType('Cat',FaIcon(FontAwesomeIcons.cat, color:  const Color(0xFF167F67),)),
  ];


  animalProfile(animalAvatarUrl, animalName, animalAge, animalType, animalVideoUrl, ownerEmail) async {
    //real device port - 192.168.0.127
    //emu device port - 10.0.2.2
    var url = "http://10.0.2.2:5000/animals/animalprofile";
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'animalAvatarUrl': animalAvatarUrl,
        'animalName': animalName,
        'animalAge': animalAge,
        'animalType': animalType,
        'animalVideoUrl': animalVideoUrl,
        'ownerEmail': ownerEmail,
      }),

    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);
    print("parsing : " + parse["animalId"]);
    await prefs.setString('animalId', parse["animalId"]);
  }


  Future<void> pickImage(ImageSource image) async {
    final PickedFile selectedImage = await imagePicker.getImage(source: image);
    if (selectedImage == null) {
      return;
    }
    setState(() {
      animalAvatarFile = File(selectedImage.path);
      uploaded = true;
    });

    await uploadImage(animalAvatarFile);
  }

  uploadImage(File _animalAvatarFile)async{
    String filePath = 'animal/images/$animalName.jpg';
    loadingImage = true;
    setState(() {
      _imageUpload = _imageStorage.ref().child(filePath).putFile(_animalAvatarFile);
    });

    if(_imageUpload!=null){
      print("good image");
      loadingImage=false;
      isOkImage=true;

      return AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Thanks For The Image :)',
          headerAnimationLoop: false,
          desc: '',
          btnOkOnPress: () {
            getImageUrl();
          }
      ).show();
    }
  }
  getImageUrl()async{
    Reference rfs = _imageUpload.snapshot.ref;
    return Timer(Duration(seconds: 5), () async {
      animalAvatarUrl = await rfs.getDownloadURL();
    });
  }

  Future<void> pickVideo(ImageSource video) async {
    VideoPlayerController fileVideoController;
    final PickedFile selectedVideo = await videoPicker.getVideo(source: video);
    if (selectedVideo == null) {
      return;
    }
    setState(() {
      animalVideoFile = File(selectedVideo.path);

    });
    fileVideoController = new VideoPlayerController.file(animalVideoFile)
      ..initialize().then((_) {
        videoSeconds = fileVideoController.value.duration.inSeconds;
        print("Seconds: "+ fileVideoController.value.duration.toString());
      });
    if(videoSeconds<0){
      return AwesomeDialog(
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Video length:',
          headerAnimationLoop: false,
          desc: 'The uploaded video is less then 50 seconds',
          btnOkOnPress: () {
            pickVideo(ImageSource.gallery);
          }
      ).show();
    }else{
      await uploadVideo(animalVideoFile);
    }
  }

  uploadVideo(File _animalVideoFile)async {
    String filePath = 'animal/videos/$animalName.mp4';
    loadingVideo=true;
    setState(() {
      _videoUpload = _videoStorage.ref().child(filePath).putFile(_animalVideoFile);
    });

    if(_videoUpload!=null){
      print("good video");
      loadingVideo=false;
      isOkVideo = true;
      return AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Thanks For The Video :)',
          headerAnimationLoop: false,
          desc: '',
          btnOkOnPress: () {
            getVideoUrl();
          }
      ).show();


    }
  }

  getVideoUrl(){
    Reference rfs = _videoUpload.snapshot.ref;
    return Timer(Duration(seconds: 5), () async {
      animalVideoUrl = await rfs.getDownloadURL();
    });
  }

  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      print("form saved");
    }
    setState(() => animalVideoFile = null);
    setState(() => animalAvatarFile = null);
  }

  void initState() {
    super.initState();
    setState(() {
      uploaded = false;
      animalName = '';
      animalAge = '';
      animalType = '';
      animalAvatarUrl = '';
      loadingImage = false;
      loadingVideo = false;
      animalVideoUrl = '';
      ownerEmail = '';

    });

  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text("Animal Profile", style: TextStyle(color: Colors.black),), iconTheme: IconThemeData(color: Colors.black),),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.6],
            colors: [
              Color(0xff59a3de),
              Color(0xff86a1ef),
            ],
          ),
        ),
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
            children: [
              buildAnimalAvatar(),
              SizedBox(height: 20),
              buildAnimalNameField(),
              SizedBox(height: 20),
              buildAnimalTypeDropDown(),
              SizedBox(height: 20),
              buildAnimalAge(),
              SizedBox(height: 20),
              buildVideoUpload(),
              loadingVideo==true?Container(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 1, backgroundColor: CupertinoColors.activeBlue, value: 5.4),
              )):Container(),
              SizedBox(height: 20),
              buildSaveButton(),
              SizedBox(height: 50),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildAnimalAvatar(){
    return Container(
      child: GestureDetector(
        onTap: (){
          pickImage(ImageSource.gallery);
        },
        child: AvatarGlow(
          glowColor: Colors.blue,
          endRadius: 75.0,
          duration: Duration(milliseconds: 2000),
          repeat: true,
          showTwoGlows: true,
          repeatPauseDuration: Duration(milliseconds: 100),
          child: Material(
            elevation: 8.0,
            shape: CircleBorder(),
            child: CircleAvatar(
              backgroundColor: Colors.grey[100],
              radius: 75.0,
              child: uploaded==false || finished==true ?
              Image.asset(
                'assets/beforeprofile.png',
                height: 150,
                fit: BoxFit.cover,
                width: 150,
              ):Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(65.0),
                    child: Image.file(
                      animalAvatarFile,
                      fit: BoxFit.cover,
                      height: 150,
                      width: 150,
                    ),
                  ),
              ) ,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAnimalNameField(){
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding:
        const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          autocorrect: false,
          onSaved: (String val) {
            animalName = val;
          },
          validator: (String value) {
            return value.isEmpty ? 'Please fill your name' : 'its good';
          },
          onChanged: (val){
            animalName = val;
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            contentPadding: new EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            hintText: "Name",
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
  Widget buildAnimalAge(){
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding:
        const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          autocorrect: false,
          onSaved: (String val) {
            animalAge = val;
          },
          onChanged: (val){
            animalAge = val;
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            contentPadding: new EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            hintText: "Age",
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
  Widget buildAnimalTypeDropDown() {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.blue,
                width: 2
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: DropdownButton<AnimalType>(
            isExpanded: true,
            underline: Container(),
            hint:  Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Choose your animal type"),
            ),
            value: selectedType,
            onChanged: (AnimalType value) {
              setState(() {
                selectedType = value;
                animalType = selectedType.name;
                print(animalType);
              });
            },
            items: types.map((AnimalType typeOfAnimal) {
              return  DropdownMenuItem<AnimalType>(
                value: typeOfAnimal,
                child: Row(
                  children: <Widget>[
                    typeOfAnimal.icon,
                    SizedBox(width: 20,),
                    Text(
                      typeOfAnimal.name,
                      style:  TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  Widget buildVideoUpload(){
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.blue,
                width: 2
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Upload Animal Video', style: TextStyle(fontSize: 16, color: Colors.blueGrey[800])),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 130),
                  child: IconButton(
                      color: Colors.white,
                      icon: isOkVideo==false?Icon(Icons.video_library, color: Colors.blueGrey): Icon(Icons.beenhere, color: Colors.green,),
                      onPressed: () {
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.INFO,
                            animType: AnimType.SCALE,
                            title: 'Video length:',
                            headerAnimationLoop: false,
                            desc: 'Please upload video of 60 seconds or more..',
                            btnOkOnPress: () {
                              pickVideo(ImageSource.gallery);
                            }
                        ).show();
                      }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton(){
    return Padding(
      padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: RaisedButton.icon(
          icon: Icon(CupertinoIcons.create),
          label: Text(
            'Save',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          color: Colors.blueGrey,
          textColor: Colors.white,
          splashColor: Colors.blue,
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var oMail = prefs.getString('email');
            ownerEmail = oMail;
            var token = prefs.getString("token");
            if(animalAvatarUrl!=null){
              await animalProfile(animalAvatarUrl, animalName, animalAge, animalType, animalVideoUrl, ownerEmail);
              finished = true;
              await prefs.setBool("animalFinished", true);
              if(token!=null){
                _saveForm();
                Navigator.pushNamed(context, "RecognitionOwnerScreen");
              }
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
}


class AnimalType {
  const AnimalType(this.name, this.icon);
  final String name;
  final FaIcon icon;
}

