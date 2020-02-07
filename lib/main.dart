/*
  Andorid: package="com.hetpatel.james_bond"
  iOS Bundle: com.hetpatel.jamesBond
 */

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:james_bond/game.dart';
import 'package:james_bond/joinRoom.dart';
import 'package:james_bond/newRoom.dart';
import 'package:james_bond/welcome.dart';
import 'package:james_bond/winningScreen.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  runApp(JamesBond());
}

class JamesBond extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityAppWrapper(
      app: MaterialApp(
        title: 'James Bond',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData.dark(),
        home: Welcome(),
//        home: WinningScreen(),
        routes: <String, WidgetBuilder>{
          "/NewRoom": (BuildContext context) => new NewRoom(),
          "/JoinRoom": (BuildContext context) => new JoinRoom(),
          "/Winning": (BuildContext context) => new WinningScreen(),
        },
        // ignore: missing_return
        onGenerateRoute: (settings) {
          if (settings.name == "/Game") {
            final GameArgs args = settings.arguments;

            return MaterialPageRoute(
              builder: (context) {
                return Game(
                  uuid: args.uuid,
                  host: args.host,
                );
              },
            );
          }
        },
      ),
    );
  }
}
