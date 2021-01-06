import 'package:aninet/ChooseAccountScreen.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shape_of_view/shape/triangle.dart';
import 'package:shape_of_view/shape_of_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}
//TODO: add two more permissions
class _OnBoardingState extends State<OnBoarding> {
  final introKey = GlobalKey<IntroductionScreenState>();
  List<Permission> _permission = [Permission.camera, Permission.microphone];
  List<PermissionStatus> _permissionStatus = [PermissionStatus.undetermined, PermissionStatus.undetermined];
  int page;

  void _listenForPermissionStatus() async {
    final firstStatus = await _permission[0].status;
    final secondStatus = await _permission[1].status;
    setState(() {
      _permissionStatus[0] = firstStatus;
      _permissionStatus[1] = secondStatus;

    });
  }

  Color getPermissionColor() {
    switch (_permissionStatus[0]) {
      case PermissionStatus.undetermined:
        return Colors.yellowAccent;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  Future<void> requestPermission(Permission firstPermission, Permission secondPermission) async {
    try{
      final firstStatus = await firstPermission.request();
      final secondStatus = await secondPermission.request();
      setState(() {
        _permissionStatus[0] = firstStatus;
        _permissionStatus[1] = secondStatus;
      });
    }catch(e){
      print(e);
    }
  }
  //Fix from splash to choose screen
  Future<void> _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var f = await prefs.setBool("finish", true);
    print(f);
    if(_permissionStatus[0].toString().substring(17).replaceFirst('g', 'G') == "Granted" && _permissionStatus[1].toString().substring(17).replaceFirst('g', 'G') == "Granted"){
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChooseAccountScreen()),
      );
    }
  }
  _onCheckPage(int page){
    if(page==3){
      requestPermission(_permission[0], _permission[1]);
    }
    return page;
  }

  void initState() {
    super.initState();
    _listenForPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    PageDecoration pageDecOne = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
      boxDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.5, 0.9],
          colors: [
            Color(0xff0c80df),
            Color(0xff128ef2),
            Color(0xff42d2f5),
          ],
        ),
      ),
    );
    PageDecoration pageDecTwo = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
      boxDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.3, 0.7],
          colors: [
            Color(0xff4296f5),
            Color(0xff128ef2),
            Color(0xff42d2f5),
          ],
        ),
      ),
    );
    PageDecoration pageDecThree = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
      boxDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.4, 0.6, 0.9],
          colors: [
            Color(0xff0b75ca),
            Color(0xff59a3de),
            Color(0xff86a1ef),
          ],
        ),
      ),
    );
    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Fractional shares",
          body:
          "Instead of having to buy an entire share, invest any amount you want.",
          image: _buildImage('img1'),
          decoration: pageDecOne,
        ),
        PageViewModel(
          title: "Learn as you go",
          body:
          "Download the Stockpile app and master the market with our mini-lesson.",
          image: _buildImageTwo('img2'),
          decoration: pageDecTwo,
        ),
        PageViewModel(
          title: "Kids and teens",
          body:
          "Kids and teens can track their stocks 24/7 and place trades that you approve.",
          image: _buildImageThree('img3'),
          decoration: pageDecThree,
        ),
        PageViewModel(
          title: "Another title page",
          body: "Another beautiful body text for this example onboarding",
          image: _buildImageFour('img2'),
          bodyWidget: _onCheckPage(page),
          decoration: pageDecTwo,
        ),
        PageViewModel(
          title: "Title of last page",
          bodyWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Click on ", style: bodyStyle),
              Icon(Icons.edit),
              Text(" to edit a post", style: bodyStyle),
            ],
          ),
          image: _buildImage('img1'),
          decoration: pageDecThree,
        ),
      ],
      onChange: _onCheckPage,
      onDone: () => _onIntroEnd(context),
      onSkip: (){
        requestPermission(_permission[0], _permission[1]);
        _onIntroEnd(context);
      },
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
  Widget _buildImage(String assetName) {
    return Align(
      child: ColoredBox(
          color: Color(0xff197dcc),
          child: Image.network('https://www.kindacode.com/wp-content/uploads/2020/12/dog-png.png', width: 250.0, height: 250.0,)
      ),
    );
    //child: Image.asset('assets/$assetName.jpg'),
  }
  Widget _buildImageTwo(String assetName) {
    return Align(
      child: ColoredBox(
          color: Color(0xff197dcc),
          child: CircleAvatar(
              radius: 125,
              backgroundColor: Color(0xff19aacc),
              child: Image.network(
                'https://www.kindacode.com/wp-content/uploads/2020/12/dog-png.png',
                width: 250.0,
                height: 250.0
              ),
          ),
      ),
    );
  }
  Widget _buildImageThree(String assetName) {
    return Align(
      child: ShapeOfView(
        width: 350,
        height: 350,
        shape: TriangleShape(
          percentBottom: 0.29,
          percentLeft: 0.1,
          percentRight: 0.35,
        ),
        child: CircleAvatar(
          backgroundColor: Color(0xff2b7bba),
          child: Image.network(
              'https://www.kindacode.com/wp-content/uploads/2020/12/dog-png.png',
              width: 250.0,
              height: 250.0
          ),
        ),
      ),
    );
  }

  Widget _buildImageFour(String assetName) {
    return Align(
        child: ColoredBox(
        color: Color(0xff5e7dc9),
        child: ShapeOfView(
          width: 250,
          height: 250,
          child: Image.network(
            'https://www.kindacode.com/wp-content/uploads/2020/12/dog-png.png',
          ),
          shape: TriangleShape(
            percentBottom: 0.29,
            percentLeft: 0.2,
            percentRight: 0.35,
          ),
        ),
      ),
    );
  }

}
