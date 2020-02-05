import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('James Bond'),
      ),
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              'James Bond',
              style: TextStyle(fontSize: 50.0),
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
                            onPressed: () =>
                                Navigator.pushNamed(context, '/NewRoom'),
                          ))
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey,
                  width: 1,
                  height: 300,
                  foregroundDecoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                ),
                Expanded(
                  child: Column(
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
