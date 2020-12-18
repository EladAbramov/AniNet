import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var animalType, email, password;
  var videoUrl;
  TextEditingController ownerName = new TextEditingController();
  TextEditingController animalName = new TextEditingController();
  String hintOwnerName = "Owner Name";
  String hintAnimalName = "Animal Name";
  TextInputType textInput = TextInputType.text;

  List<AnimalType> types = <AnimalType>[
    const AnimalType('Dog',FaIcon(FontAwesomeIcons.dog, color:  const Color(0xFF167F67),)),
    const AnimalType('Cat',FaIcon(FontAwesomeIcons.cat, color:  const Color(0xFF167F67),)),
  ];

  AnimalType selectedType;
  final videoInfo = FlutterVideoInfo();
  int videoSeconds = 0;
  File videoFile;
  final picker = ImagePicker();
  final formKey = new GlobalKey<FormState>();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  UploadTask _upload;
  bool loading;
  bool isOk = false;


  signUp(ownerName, animalName, animalType, videoUrl, email, password) async {
    var url = "http://10.0.2.2:5000/signup";
    print(ownerName.text + ' ' + animalName.text + ' ' + animalType + ' ' + videoUrl);
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ownerName': ownerName.text,
        'animalName': animalName.text,
        'animalType': animalType,
        'videoUrl': videoUrl,
        'email': email,
        'password': password
      }),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);
    await prefs.setString('token', parse["token"]);
  }

  Future<void> _pickVideo(ImageSource _videoFile) async {
    VideoPlayerController fileVideoController;
    final PickedFile selectedVideo = await picker.getVideo(source: _videoFile);
    if (selectedVideo == null) {
      return;
    }
    setState(() {
      videoFile = File(selectedVideo.path);

    });
    fileVideoController = new VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        videoSeconds = fileVideoController.value.duration.inSeconds;
        print("Seconds: "+ fileVideoController.value.duration.toString());
      });
    if(videoSeconds>0){
      return AwesomeDialog(
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Video length:',
          headerAnimationLoop: false,
          desc: 'The uploaded video is less then 60 seconds',
          btnOkOnPress: () {
            _pickVideo(ImageSource.gallery);
          }
      ).show();
    }else{
      await uploader(videoFile);

    }

  }

  uploader(File _video)async {
    String owner = ownerName.text;
    String animal = animalName.text;
    String filePath = 'videos/$owner&&$animal.mp4';
    loading=true;

    setState(() {
      _upload = _storage.ref().child(filePath).putFile(_video);
    });

    if(_upload!=null){
      print("good");
      loading=false;
      isOk=true;
      Reference rfs = _upload.snapshot.ref;

      Timer(Duration(seconds: 1), () async {
        videoUrl = await rfs.getDownloadURL();
      });
      return AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Thanks For The Video :)',
          headerAnimationLoop: false,
          desc: '',
          btnOkOnPress: () {

          }
      ).show();


    }
  }

  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      print("form saved");
    }
    setState(() => videoFile = null);
  }

  void initState() {
    super.initState();
    animalType = '';
    videoUrl = '';
    loading = false;
  }

  Widget build(BuildContext context) {
    checkToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token");
      if(token!=null){
        Navigator.pushNamed(context, "RecognitionScreen");
      }
    }
    checkToken();
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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
            children: [
              Center(child: Text('Welcome To AniNet', style: TextStyle(fontSize: 24, color: Colors.white70),)),
              SizedBox(height: 20,),
              buildTextConstraintsBox(ownerName, hintOwnerName, textInput),
              SizedBox(height: 10,),
              buildTextConstraintsBox(animalName,hintAnimalName, textInput),
              SizedBox(height: 10,),
              buildAnimalTypeDropDown(),
              SizedBox(height: 10,),
              buildVideoUpload(),
              SizedBox(height: 10,),
              loading==true?Container(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 1, backgroundColor: CupertinoColors.activeBlue, value: 5.4),
              )):Container(),
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

  Widget buildTextConstraintsBox(TextEditingController field, String hintText, TextInputType type){
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding:
        const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: TextFormField(
          controller: field,
          keyboardType: type,
          autocorrect: false,
          onSaved: (String val) {
            field.text = val;
          },
          validator: (String value) {
            return value.isEmpty ? 'Please fill your name' : 'its good';
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            contentPadding: new EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            hintText: hintText,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.5)),
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
                      icon: isOk==false?Icon(Icons.video_library, color: Colors.blueGrey): Icon(Icons.beenhere, color: Colors.green,),
                      onPressed: () {
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.INFO,
                            animType: AnimType.SCALE,
                            title: 'Video length:',
                            headerAnimationLoop: false,
                            desc: 'Please upload video of 60 seconds or more..',
                            btnOkOnPress: () {
                              _pickVideo(ImageSource.gallery);
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

  Widget buildEmailConstraintsBox(){
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding:
        const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          autocorrect: false,
          onSaved: (String val) {
            email = val;
          },
          onChanged: (val){
            email = val;
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
          obscureText: true,
          autocorrect: false,
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
            await signUp(ownerName, animalName, animalType, videoUrl, email, password);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String token = prefs.getString("token");
            print(token);
            _saveForm();
            if(token!=null){
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: RaisedButton.icon(
          color: Colors.blue,
          label: Text(
            'Login',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          icon: Icon(CupertinoIcons.create),
          textColor: Colors.white,
          splashColor: Colors.blue,
          onPressed: () {
            Navigator.pushReplacementNamed(context, "Login");
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

