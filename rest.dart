import 'package:flutter/material.dart';

class Faaltu extends StatefulWidget {
  @override
  _FaaltuState createState() => _FaaltuState();
}

class _FaaltuState extends State<Faaltu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: FlatButton.icon(
            label: Text("back"),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
      ),
    );
  }
}