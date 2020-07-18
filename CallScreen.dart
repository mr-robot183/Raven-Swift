import 'package:flutter/material.dart';
import 'package:raven/pages/home/messaging/rest.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[100],
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                radius: 25,
              ),
              title: Text("Arpit, Priyanshu"),
              subtitle: Text("Yesterday, 22:03"),
              trailing: IconButton(
                icon: Icon(Icons.phone, color: Colors.deepPurple[600]),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Faaltu()),
                  );
                },
              ),
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
              subtitle: Text("11 July, 04:24"),
              trailing: IconButton(
                icon: Icon(Icons.phone, color: Colors.deepPurple[600],),
                onPressed: () {},
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 25,
              ),
              title: Text("Name"),
              subtitle: Text("Recent message"),
              trailing: IconButton(
                icon: Icon(Icons.videocam, color: Colors.deepPurple[600],),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}