import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'DetailedOwner.dart';

class OwnersList extends StatefulWidget {
  @override
  _OwnersListState createState() => _OwnersListState();
}

class _OwnersListState extends State<OwnersList> {

  List<dynamic> data;

  Future<List> getData() async {
    var url = "http://10.0.2.2:5000/owner";
    final http.Response response = await http.get(
      url,
    );
    Map<String, dynamic> map = json.decode(response.body);
    data = map["owners"];
    return data.toList();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      this.getData();

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: new AppBar(
        title: new Text("Our Owners"),
      ),
      body: new FutureBuilder<List>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? new ItemList(
            list: snapshot.data,
          )
              : new Center(
            child: new CircularProgressIndicator(),
          );
        },
      ),

    );
  }
}

class ItemList extends StatelessWidget {

  final List list;
  ItemList({this.list});

  Widget build(BuildContext context) {
    return new ListView.builder(
        itemCount: list == null ? 0 : list.length,
        itemBuilder: (context, i) {
          return new Container(
            height: 200,
            width: 100,
            padding: const EdgeInsets.only(left: 100.0, right: 100, top: 30),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => new DetailedOwner(
                    list: list,
                    index: i,
                  ),
                ),
              ),
              child: new Card(
                child: Column(
                  children: [
                    Container(
                      width: 210,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff000000),
                            Color(0xffffffff),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          list[i]['ownerName'],
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Times New Roman'
                          ),
                        ),
                      ),
                    ),
                    Image.network(
                      list[i]['ownerAvatarUrl'],
                      fit: BoxFit.cover,
                      height: 134,
                      width: 210,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
