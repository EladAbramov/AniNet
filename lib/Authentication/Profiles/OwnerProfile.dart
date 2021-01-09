import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerProfile extends StatefulWidget {
  @override
  _OwnerProfileState createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  File ownerAvatarFile;
  var ownerAvatarUrl;
  var ownerName;
  var phoneNumber;
  var country;
  final formKey = new GlobalKey<FormState>();
  bool uploaded;
  final picker = ImagePicker();
  bool loading;
  bool isOk = false;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  UploadTask _upload;
  var email = '';
  var password = '';
  bool finished = false;


  ownerProfile(email, password, ownerAvatarUrl, ownerName, phoneNumber,country) async {
    //real device port - 192.168.0.127
    //emu device port - 10.0.2.2
    var url = "http://10.0.2.2:5000/owner/signup/ownerprofile";
    print(url);
    final http.Response response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'ownerAvatarUrl': ownerAvatarUrl,
        'ownerName': ownerName,
        'phoneNumber': phoneNumber,
        'country': country,
      }),
    );

  }

  showCountry(){
    return showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country tempCountry) {
        setState(() {
          country = tempCountry.name;

        });
      },
    );
  }
  Future<void> pickImage(ImageSource image) async {
    final PickedFile selectedImage = await picker.getImage(source: image);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("ownerFinished", false);
    await prefs.setBool("animalFinished", false);

    if (selectedImage == null) {
      return;
    }
    setState(() {
      ownerAvatarFile = File(selectedImage.path);
      uploaded = true;
    });

    await uploadImage(ownerAvatarFile);
  }

  uploadImage(File _ownerAvatarFile)async{
    String filePath = 'owner/images/$ownerName.jpg';
    loading = true;
    setState(() {
      _upload = _storage.ref().child(filePath).putFile(_ownerAvatarFile);
    });

    if(_upload!=null){
      print("good");
      loading=false;
      isOk=true;
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

  getImageUrl()async {
    Reference rfs = _upload.snapshot.ref;
    return Timer(Duration(seconds: 5), () async {
      ownerAvatarUrl = await rfs.getDownloadURL();
      print(ownerAvatarUrl);
    });
  }

  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      print("form saved");
    }
    setState(() => ownerAvatarFile = null);
  }
  void initState() {
    super.initState();
    setState(() {
      uploaded = false;
      ownerName = '';
      phoneNumber = '';
      ownerAvatarUrl = '';
      country = '';
      loading = false;
    });

  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Owner Profile", style: TextStyle(color: Colors.black),), iconTheme: IconThemeData(color: Colors.black),),
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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
            children: [
              buildOwnerAvatar(),
              SizedBox(height: 30),
              buildOwnerNameField(),
              SizedBox(height: 20),
              buildCountry(),
              SizedBox(height: 20),
              buildPhoneNumber(),
              SizedBox(height: 30),
              buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOwnerAvatar(){
    return Container(
      child: GestureDetector(
        onTap: (){
          if(ownerName.toString().length>0){
            pickImage(ImageSource.gallery);
          }
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
                radius: 75.0,
                backgroundColor: Colors.grey[100],
                child: uploaded==false || finished==true?
                Image.asset(
                  'assets/beforeprofile.png',
                  height: 150,
                  fit: BoxFit.cover,
                  width: 150,
                ):Container(
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(65.0),
                  child: Image.file(
                    ownerAvatarFile,
                    fit: BoxFit.cover,
                    height: 150,
                    width: 150,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOwnerNameField(){
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding:
        const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          autocorrect: false,
          onSaved: (String val) {
            ownerName = val;
          },
          validator: (String value) {
            return value.isEmpty ? 'Please fill your name' : 'its good';
          },
          onChanged: (val){
            ownerName = val;
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            contentPadding: new EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            hintText: "Full Name",
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

  Widget buildCountry(){
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              country=='' ? Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text("Choose Country", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w300),),
              ): Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(country, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: (){
                  showCountry();
                },
              ),
            ],
          ),
        ),
      ),
    );

  }
  Widget buildPhoneNumber(){
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding:
        const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        child: TextFormField(
          keyboardType: TextInputType.phone,
          autocorrect: false,
          onSaved: (String val) {
            phoneNumber = val;
          },
          onChanged: (val){
            phoneNumber = val;
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          decoration: InputDecoration(
            contentPadding: new EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            hintText: "Phone Number",
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
            var savedEmail = prefs.getString("email");
            email = savedEmail;
            var savedPass = prefs.getString('password');
            password = savedPass;
            await prefs.setBool("ownerFinished", true);
            if(ownerAvatarUrl!=null){
              await ownerProfile(email, password, ownerAvatarUrl, ownerName, phoneNumber, country);
              _saveForm();
              finished=true;
              Navigator.pushNamed(context, "AnimalProfile");
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