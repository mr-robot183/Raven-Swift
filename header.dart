import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar header(context,
    {bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    //automaticallyImplyLeading: removeBackButton ? false : true,
    actionsIconTheme: IconThemeData(
        size: 30.0,
        color: Colors.white,
        opacity: 1.0
    ),
    leading: IconButton(
      onPressed: () {

      },
      padding: EdgeInsets.only(left: 6),
      icon: Icon(Icons.library_books, color: Colors.white, size: 30),
    ),
    title: Text(
      isAppTitle ? "Raven Swift" : titleText,
      style:
      GoogleFonts.copse(fontStyle: FontStyle.normal, color: Colors.white, fontWeight:  isAppTitle ? FontWeight.bold : FontWeight.normal, fontSize: 30),
      /*TextStyle(
        color: Colors.black,
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),*/
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.redAccent,
    brightness: Brightness.light,
    actions: <Widget>[
      /*IconButton(
        onPressed: () {

        },
        padding: EdgeInsets.only(left: 6),
        icon: Icon(Icons.library_books, color: Colors.black, size: 30),
      ),*/
      IconButton(
          onPressed: () {
            /*Navigator.of(context).push(PageRouteTransition(
                animationType: AnimationType.slide_right,
                builder: (context) => MessagingPage()));*/
          },
          icon: Icon(Icons.message,
              color: Colors.white
          )
      )
    ],
  );
}



AppBar headerNotifications(context,
    {bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    actionsIconTheme: IconThemeData(
        size: 30.0,
        color: Colors.black,
        opacity: 1.0
    ),
    title: Text(
      isAppTitle ? "Raven Swift" : titleText,
      style:
      GoogleFonts.copse(fontStyle: FontStyle.normal, color: Colors.black, fontWeight:  isAppTitle ? FontWeight.bold : FontWeight.normal, fontSize: 30),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    brightness: Brightness.light,

  );
}


