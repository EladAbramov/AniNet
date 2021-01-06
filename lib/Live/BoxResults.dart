import 'package:flutter/material.dart';

class BoxResults extends StatelessWidget {

  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  BoxResults(this.results, this.previewH, this.previewW, this.screenH, this.screenW);



  @override
  Widget build(BuildContext context) {
    List<Widget> _renderStrings() {
      double offset = -10;
      var per;
      double val;
      return results.map((re) {
        per = "${(re["confidence"] * 100).toStringAsFixed(0)}";
        val = double.parse(per);
        offset = offset + 14;
        return Positioned(
          left: 10,
          top: offset,
          width: screenW,
          height: screenH,
          child: Center(
            child: Text(
              val > 90.0 ? "${re["label"].toString().substring(2)} ${(re["confidence"] * 100).toStringAsFixed(0)}%" : "unknown",
              style: TextStyle(
                color: Colors.red,
                fontSize: 54.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }
    return Stack(
      children: _renderStrings(),
    );
  }
}