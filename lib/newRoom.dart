import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:james_bond/DatabaseStates.dart';
import 'package:james_bond/Player.dart';
import 'package:james_bond/game.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class NewRoom extends StatefulWidget {
  @override
  _NewRoomState createState() => _NewRoomState();
}

class _NewRoomState extends State<NewRoom> {
  final database = FirebaseDatabase.instance.reference();
  var roomAddState, roomRmvState;
  var code = new List(4);
  var uuid, str, playerName;
  var numberOfPlayers = 0, play = false;
  var destroy = true;

  @override
  void initState() {
    super.initState();
    uuid = Uuid().v4();
    switch (Random().nextInt(3)) {
      case 0:
        str = uuid.substring(9, 13);
        break;
      case 1:
        str = uuid.substring(14, 18);
        break;
      default:
        str = uuid.substring(19, 23);
        break;
    }
    code = str.toUpperCase().split('');

    database.child('rooms').update({'$str': '$uuid'});
    database.child(uuid).update({
      'state': DatabaseStates.WAITING,
      'players': {
        "player1": Player.NAMES[Random().nextInt(Player.NAMES.length)],
      }
    });
    roomAddState =
        database.child("$uuid/players").onChildAdded.listen((Event event) {
      numberOfPlayers++;
      readyToPlay();
    });
    roomRmvState =
        database.child("$uuid/players").onChildRemoved.listen((Event event) {
      numberOfPlayers--;
      readyToPlay();
    });
  }

  void readyToPlay() {
    if (numberOfPlayers == 2)
      setState(() {
        play = true;
      });
    else
      setState(() {
        play = false;
      });
  }

  void startGame() {
    database.child('$uuid/state').set(DatabaseStates.DEAL_CARDS);
    destroy = false;
    Navigator.popUntil(context, ModalRoute.withName("/"));
    Navigator.pushReplacementNamed(context, "/Game",
        arguments: GameArgs(uuid: uuid, host: true));
  }

  @override
  void dispose() {
    super.dispose();
    if (destroy) {
      database.child('rooms').update({'$str': null});
      database.child(uuid).remove();
      roomAddState.cancel();
      roomRmvState.cancel();
    } else {
      database.child('rooms').update({'$str': null});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(play ? 'Ready!' : 'Waiting on friend...')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  Text(
                    code[0],
                    style:
                        TextStyle(fontSize: 100.0, fontFamily: "Special Elite"),
                  ),
                  Text(
                    code[1],
                    style:
                        TextStyle(fontSize: 100.0, fontFamily: "Special Elite"),
                  ),
                  Text(
                    code[2],
                    style:
                        TextStyle(fontSize: 100.0, fontFamily: "Special Elite"),
                  ),
                  Text(
                    code[3],
                    style:
                        TextStyle(fontSize: 100.0, fontFamily: "Special Elite"),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ),
            RaisedButton(
              onPressed: !play ? null : () => startGame(),
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('Play'),
            ),
            Center(
              child: Text(play
                  ? 'The game requires 2 people to play'
                  : 'Press PLAY to begin'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: database.child('$uuid/players').onValue,
                builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                  if (snapshot.hasData) {
                    var players =
                        Map.from(snapshot.data.snapshot.value).values.toList();
                    return new ListView.builder(
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
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }
}
