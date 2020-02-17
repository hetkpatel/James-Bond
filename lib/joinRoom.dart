import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:james_bond/DatabaseStates.dart';
import 'package:james_bond/Player.dart';
import 'package:james_bond/game.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class JoinRoom extends StatefulWidget {
  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final database = FirebaseDatabase.instance.reference();
  var uuid = "";
  var joinedRoom = false, playerName = "";
  var destroy = true;
  TextEditingController controller = TextEditingController();

  void joinRoom(passCode) {
    passCode = passCode.toLowerCase();
    database.child('rooms/$passCode').once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        setState(() {
          joinedRoom = true;
          uuid = snapshot.value;
          database.child('$uuid/players').once().then((DataSnapshot playersSS) {
            var listOfPlayers = Map.from(playersSS.value);
            listOfPlayers.addAll({
              "player2": Player.NAMES[Random().nextInt(Player.NAMES.length)]
            });
            database.child(uuid).update({'players': listOfPlayers});
            listenRoomState();
          });
        });
      }
    });
  }

  void listenRoomState() {
    database.child("$uuid/state").onValue.listen((Event event) {
      if (event.snapshot.value == DatabaseStates.DEAL_CARDS) {
        destroy = false;
        Navigator.popUntil(context, ModalRoute.withName("/"));
        Navigator.pushReplacementNamed(context, "/Game",
            arguments: GameArgs(uuid: uuid, host: false));
      } else if (event.snapshot.value == null) {
        Navigator.popUntil(context, ModalRoute.withName("/"));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (destroy) database.child('$uuid/players/player2').remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Join Room')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            PinCodeTextField(
              length: 4,
              shape: PinCodeFieldShape.underline,
              animationType: AnimationType.slide,
              fieldWidth: 50,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              backgroundColor: Color.fromRGBO(0, 0, 0, 0.01),
              autoFocus: true,
              textStyle: TextStyle(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 35.0,
                  fontFamily: "Special Elite"),
              onChanged: (value) {
                if (value.length == 4) {
                  joinRoom(value);
                }
              },
              enabled: !joinedRoom,
            ),
            RaisedButton(
              onPressed: joinedRoom ? null : () => print('join room'),
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('Join'),
            ),
            Expanded(
                child: !joinedRoom
                    ? Center(
                        child: Text('Please enter code above to join a room'))
                    : StreamBuilder(
                        stream: database.child('$uuid/players').onValue,
                        builder: (BuildContext context,
                            AsyncSnapshot<Event> snapshot) {
                          if (snapshot.hasData) {
                            var players = Map.from(snapshot.data.snapshot.value)
                                .values
                                .toList();
                            return ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(players[index]),
                                  ),
                                );
                              },
                              itemCount: players.length,
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.all(8.0),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ))
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }
}
