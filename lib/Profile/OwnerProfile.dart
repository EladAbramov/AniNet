import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:country_picker/country_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OwnerProfile extends StatefulWidget {
  @override
  _OwnerProfileState createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  File ownerAvatarFile;
  var ownerAvatarUrl;
  TextEditingController ownerName = new TextEditingController();
  TextEditingController phoneNumber = new TextEditingController();
  var country;
  final formKey = new GlobalKey<FormState>();
  bool uploaded;
  final picker = ImagePicker();

  // TODO: Make route accessiable only for permitted user - "http://10.0.2.2:5000/:id/ownerprofile";
  ownerProfile(ownerAvatarUrl, ownerName, phoneNumber,country) async {
    var url = "http://10.0.2.2:5000/ownerprofile";
    await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ownerAvatarUrl': ownerAvatarUrl,
        'ownerName': ownerName.text,
        'phoneNumber': phoneNumber.text,
        'country': country
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
    if (selectedImage == null) {
      return;
    }
    setState(() {
      ownerAvatarFile = File(selectedImage.path);
      uploaded = true;

    });
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.BOTTOMSLIDE,
        title: '',
        headerAnimationLoop: false,
        desc: '',
        btnOkOnPress: () {}).show();
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
      ownerAvatarUrl = '';
      country = '';
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
              buildPhoneNumber(),
              SizedBox(height: 20),
              buildCountry(),
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
              child: uploaded==true?Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(65.0),
                  child: Image.asset(
                    ownerAvatarFile.path,
                    fit: BoxFit.cover,
                    height: 150,
                    width: 150,
                  ),
                ),
              ): Image.asset(
                'assets/beforeprofile.png',
                height: 150,
                fit: BoxFit.cover,
                width: 150,
              ),
              radius: 75.0,
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
            ownerName.text = val;
          },
          onChanged: (val){
            ownerName.text = val;
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
            phoneNumber.text = val;
          },
          onChanged: (val){
            phoneNumber.text = val;
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
            await ownerProfile(ownerAvatarUrl, ownerName, phoneNumber, country);
            _saveForm();
            Navigator.pushNamed(context, "AnimalProfile");

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