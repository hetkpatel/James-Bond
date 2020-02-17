import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              child: Image.asset(
                'assets/james_bond_logo.png',
                height: 200,
                fit: BoxFit.fitWidth,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Create a new game',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: "Special Elite"),
                        ),
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
                            onPressed: () =>
                                Navigator.pushNamed(context, '/NewRoom'),
                          ))
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey,
                  width: 1,
                  height: 200,
                  foregroundDecoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Join a game',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: "Special Elite"),
                        ),
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
                            onPressed: () =>
                                Navigator.pushNamed(context, '/JoinRoom'),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
