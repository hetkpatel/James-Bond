/*
  Andorid: package="com.hetpatel.james_bond"
  iOS Bundle: com.hetpatel.jamesBond
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:james_bond/game.dart';
import 'package:james_bond/joinRoom.dart';
import 'package:james_bond/newRoom.dart';
import 'package:james_bond/welcome.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  runApp(JamesBond());
}

class JamesBond extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'James Bond',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Welcome(),
//      home: Game(),
      routes: <String, WidgetBuilder>{
        "/NewRoom": (BuildContext context) => new NewRoom(),
        "/JoinRoom": (BuildContext context) => new JoinRoom(),
        "/Game": (BuildContext context) => new Game(),
      },
    );
  }
}
