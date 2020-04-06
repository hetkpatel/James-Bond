/*
  Andorid: package="com.hetpatel.suits"
  iOS Bundle: com.hetpatel.suits
 */

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:suits/game.dart';
import 'package:suits/help.dart';
import 'package:suits/joinRoom.dart';
import 'package:suits/newRoom.dart';
import 'package:suits/welcome.dart';
import 'package:suits/winningScreen.dart';

void main() => runApp(Suits());

class Suits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityAppWrapper(
      app: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Suits',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Welcome(),
        routes: <String, WidgetBuilder>{
          "/NewRoom": (BuildContext context) => new NewRoom(),
          "/JoinRoom": (BuildContext context) => new JoinRoom(),
          "/Help": (BuildContext context) => new Help(),
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
