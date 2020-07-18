import 'package:flutter/material.dart';
import 'package:raven/pages/home/messaging/rest.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      /*child: new Column(
        children: <Widget>[
          new Flexible(
            child: Container,
            child: new FirebaseAnimatedList(

            )
          )

        ],
      )*/






















      color: Colors.grey[100],
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              radius: 25,
            ),
            title: Text("Team Noobs"),
            subtitle: Text("Priyanshu: App is built! Woohoo!"),
            trailing: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text("13:10"),
                  )
                ],
              ),
            ),
            onLongPress: () {},
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Faaltu()),
              );
            },
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 25,
            ),
            title: Text("Name"),
            subtitle: Text("Recent message"),
            trailing: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text("Yesterday"),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 25,
            ),
            title: Text("Name"),
            subtitle: Text("Recent message"),
            trailing: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text("07/11/2020"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}