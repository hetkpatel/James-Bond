import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:james_bond/DatabaseStates.dart';
import 'package:james_bond/Player.dart';
import 'package:james_bond/game.dart';

class JoinRoom extends StatefulWidget {
  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  FocusNode _fn1 = new FocusNode(),
      _fn2 = new FocusNode(),
      _fn3 = new FocusNode(),
      _fn4 = new FocusNode();
  final database = FirebaseDatabase.instance.reference();
  var code = new List(4), uuid = "";
  var joinedRoom = false, playerName = "";
  var destroy = true;

  void onTypingCode(character, currentCurPos) {
    code[currentCurPos] = character;
    switch (currentCurPos) {
      case 0:
        if (character != "") FocusScope.of(context).requestFocus(_fn2);
        break;
      case 1:
        if (character != "")
          FocusScope.of(context).requestFocus(_fn3);
        else
          FocusScope.of(context).requestFocus(_fn1);
        break;
      case 2:
        if (character != "")
          FocusScope.of(context).requestFocus(_fn4);
        else
          FocusScope.of(context).requestFocus(_fn2);
        break;
      case 3:
        if (character != "")
          joinRoom();
        else
          FocusScope.of(context).requestFocus(_fn3);
    }
  }

  void joinRoom() {
    var passCode = "";
    for (var i = 0; i < code.length; i++) passCode += code[i];

    if (passCode.length == 4) {
      passCode = passCode.toLowerCase();
      database.child('rooms/$passCode').once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          setState(() {
            joinedRoom = true;
            uuid = snapshot.value;
            database
                .child('$uuid/players')
                .once()
                .then((DataSnapshot playersSS) {
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
  }

  void listenRoomState() {
    database.child("$uuid/state").onValue.listen((Event event) {
      if (event.snapshot.value == DatabaseStates.DEAL_CARDS) {
        destroy = false;
        Navigator.popUntil(context, ModalRoute.withName("/"));
        Navigator.pushReplacementNamed(context, "/Game", arguments: GameArgs(uuid: uuid, host: false));
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
            new Row(
              children: <Widget>[
                new Flexible(
                  child: new TextField(
                    autocorrect: false,
                    autofocus: true,
                    enabled: !joinedRoom,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 100),
                    focusNode: _fn1,
                    onChanged: (String str) => onTypingCode(str, 0),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [LengthLimitingTextInputFormatter(1)],
                  ),
                ),
                Container(width: 5),
                new Flexible(
                  child: new TextField(
                    autocorrect: false,
                    enabled: !joinedRoom,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 100),
                    focusNode: _fn2,
                    onChanged: (String str) => onTypingCode(str, 1),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [LengthLimitingTextInputFormatter(1)],
                  ),
                ),
                Container(width: 5),
                new Flexible(
                  child: new TextField(
                    autocorrect: false,
                    enabled: !joinedRoom,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 100),
                    focusNode: _fn3,
                    onChanged: (String str) => onTypingCode(str, 2),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [LengthLimitingTextInputFormatter(1)],
                  ),
                ),
                Container(width: 5),
                new Flexible(
                    child: new TextField(
                  autocorrect: false,
                  enabled: !joinedRoom,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 100),
                  focusNode: _fn4,
                  onChanged: (String str) => onTypingCode(str, 3),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                ))
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            RaisedButton(
              // FIXME: join room
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
