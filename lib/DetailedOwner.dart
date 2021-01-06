import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'EditOwner.dart';
import 'OwnersList.dart';


class DetailedOwner extends StatefulWidget {

  List list;
  int index;
  DetailedOwner({this.index,this.list});
  _DetailedOwnerState createState() => _DetailedOwnerState();
}

class _DetailedOwnerState extends State<DetailedOwner> {

  removeRegister(String _id) async {
    String url = "http://10.0.2.2:5000/owner/$_id";
    http.Response res = await http.delete(url);
    if (res.statusCode == 200) {
      print("DELETED");
    } else {
      throw "Can't delete owner.";
    }
  }


  void promptDelete(){
    AlertDialog alertDialog = new AlertDialog(
      content: new Text("Would u really like to delete: '${widget.list[widget.index]['ownerName']}'"),
      actions: <Widget>[
        new RaisedButton(
          child: new Text("OK remove!",style: new TextStyle(color: Colors.black),),
          color: Colors.green,
          onPressed: () async {
            await removeRegister(widget.list[widget.index]['_id'].toString());
            Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => new OwnersList(),
                )
            );
          },
        ),
        new RaisedButton(
          child: new Text("CANCEL",style: new TextStyle(color: Colors.black)),
          color: Colors.red,
          onPressed: ()=> Navigator.pop(context),
        ),
      ],
    );

    showDialog(context: context, child: alertDialog);
  }
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("${widget.list[widget.index]['ownerName']}")),
      body: new Container(
        height: 270.0,
        padding: const EdgeInsets.all(20.0),
        child: new Card(
          child: new Center(
            child: new Column(
              children: <Widget>[
                Padding(padding: const EdgeInsets.only(top: 30.0),),
                Center(child: new Text(widget.list[widget.index]['ownerName'], style: new TextStyle(fontSize: 20.0),)),
                Padding(padding: const EdgeInsets.only(top: 30.0),),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(child: new Text("Email : ${widget.list[widget.index]['email']}", style: new TextStyle(fontSize: 18.0),)),
                ),
                Padding(padding: const EdgeInsets.only(top: 30.0),),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RaisedButton.icon(
                        label: new Text("Edit", style: TextStyle(color: Colors.black),),
                        icon: FaIcon(FontAwesomeIcons.edit, size: 15, color: Colors.black,),
                        color: Colors.blueAccent,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        onPressed: () async{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          var id =  widget.list[widget.index]['_id'].toString();
                          await prefs.setString("newOwnerId",id);
                          Navigator.of(context).push(
                            new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  EditOwner(
                                    list: widget.list, index: widget.index,),
                            ),
                          );
                        }
                    ),
                    VerticalDivider(),
                    RaisedButton.icon(
                      label: new Text("Delete", style: TextStyle(color: Colors.black),),
                      icon: FaIcon(FontAwesomeIcons.trash, size: 15,),
                      color: Colors.redAccent,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      onPressed: ()=> promptDelete(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}