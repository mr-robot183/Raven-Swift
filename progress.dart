import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


Container circularProgressMain() {
  return Container(
    color: Colors.white,
    child: Center(
      child: SpinKitChasingDots(
        color: Colors.deepPurpleAccent,
        size: 50.0,
      ),
    ),
  );
}

Container circularProgressSecond() {
  return Container(
    color: Colors.white,
    child: Center(
      child: SpinKitDualRing(
        color: Colors.deepPurpleAccent,
        size: 20.0,

      ),
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}
