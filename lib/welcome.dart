import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mafia'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Create a new game'),
                ),
                Container(
                    width: 100.0,
                    height: 100.0,
                    child: new RawMaterialButton(
                      shape: new CircleBorder(),
                      elevation: 3.0,
                      fillColor: Colors.blue,
                      child: new Icon(
                        Icons.add,
                        size: 50.0,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/NewRoom'),
                    ))
              ],
            ),
            Container(
              color: Colors.grey,
              width: 1,
              height: 300,
              foregroundDecoration:
              BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Join a game'),
                ),
                Container(
                    width: 100.0,
                    height: 100.0,
                    child: new RawMaterialButton(
                      shape: new CircleBorder(),
                      elevation: 3.0,
                      fillColor: Colors.blue,
                      child: new Icon(
                        Icons.play_arrow,
                        size: 50.0,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/JoinRoom'),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
