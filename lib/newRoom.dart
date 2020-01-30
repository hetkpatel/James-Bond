import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
//    uuid = "3da048d7-57b5-4d96-b069-6d7962909efd";
//    str = "57b5";
    code = str.toUpperCase().split('');

    database.child('rooms').update({'$str': '$uuid'});
//    playerName = Player.makePlayer();
    database.child(uuid).update({
      'state': 'waiting',
      'players': {
        playerName: "player",
        "p2": "player",
        "p3": "player",
        "p4": "player",
        "p5": "player"
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
    if (numberOfPlayers >= 6)
      setState(() {
        play = true;
      });
    else
      setState(() {
        play = false;
      });
  }

  void setUpGame() {
    var mafia = (numberOfPlayers / 3).truncate();
    var doctor = 1, cop = 1;
    var civilian = numberOfPlayers - mafia - 2;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Roles'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Mafioso: '),
                    Flexible(
                      fit: FlexFit.tight,
                      child: TextField(
                          controller:
                              new TextEditingController(text: mafia.toString()),
                          onChanged: (value) {
                            mafia = int.parse(value);
                          },
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: false)),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Doctors: '),
                    Flexible(
                      fit: FlexFit.tight,
                      child: TextField(
                          controller: new TextEditingController(
                              text: doctor.toString()),
                          onChanged: (value) {
                            doctor = int.parse(value);
                          },
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: false)),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Cops: '),
                    Flexible(
                      fit: FlexFit.tight,
                      child: TextField(
                          controller:
                              new TextEditingController(text: cop.toString()),
                          onChanged: (value) {
                            cop = int.parse(value);
                          },
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: false)),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Civilians: '),
                    Flexible(
                      fit: FlexFit.tight,
                      child: TextField(
                          controller: new TextEditingController(
                              text: civilian.toString()),
                          onChanged: (value) {
                            civilian = int.parse(value);
                          },
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: false)),
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Go back'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              child: Text('Start', style: TextStyle(color: Colors.white)),
              onPressed: null,
//              onPressed: () => startGame(mafia, doctor, cop, civilian),
            )
          ],
        );
      },
    );
  }

//  void startGame(maf, doc, cop, civ) {
//    if ((maf + doc + cop + civ) == numberOfPlayers) {
//      Navigator.pop(context);
//      var playerBase = database.child('$uuid/players');
//      playerBase.once().then((players) {
//        var playerList = Map.from(players.value).keys.toList();
//        var newPlayerList = Map<String, dynamic>();
//        while (playerList.isNotEmpty) {
//          var name = playerList.removeAt(Random().nextInt(playerList.length));
//          if (maf != 0) {
//            newPlayerList.addAll({name: Player.MAFIA});
//            maf--;
//          } else if (doc != 0) {
//            newPlayerList.addAll({name: Player.DOCTOR});
//            doc--;
//          } else if (cop != 0) {
//            newPlayerList.addAll({name: Player.COP});
//            cop--;
//          } else if (civ != 0) {
//            newPlayerList.addAll({name: Player.CIVILIAN});
//            civ--;
//          }
//        }
//        playerBase.update(newPlayerList);
//        // TODO: Move to next screen. Change the state of the room to be roleView.
//        database.child('$uuid/state').set('viewRoles');
//        destroy = false;
//        Navigator.popUntil(context, ModalRoute.withName("/"));
//        Navigator.pushReplacementNamed(context, "/ViewRole",
//            arguments: PlayerArgs(uuid, playerName, true));
//      });
//    } else {
//      showDialog<void>(
//        context: context,
//        barrierDismissible: false,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            title: Text('Too many roles'),
//            content: Text(
//                'The roles do not equal the number of players. Please enter valid values in the boxes.'),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('Go back'),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              )
//            ],
//          );
//        },
//      );
//    }
//  }

  @override
  void dispose() {
    super.dispose();
    if (destroy) {
      database.child('rooms').update({'$str': null});
      database.child(uuid).remove();
      roomAddState.cancel();
      roomRmvState.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(play ? 'Ready!' : 'Waiting on friends...')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  code[0],
                  style: TextStyle(fontSize: 100.0),
                ),
                Text(
                  code[1],
                  style: TextStyle(fontSize: 100.0),
                ),
                Text(
                  code[2],
                  style: TextStyle(fontSize: 100.0),
                ),
                Text(
                  code[3],
                  style: TextStyle(fontSize: 100.0),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            RaisedButton(
              onPressed: !play ? null : () => setUpGame(),
              color: Colors.red,
              textColor: Colors.white,
              child: Text('Play'),
            ),
            Center(
              child: Text('The game requires 6 players'),
            ),
            Expanded(
                child: StreamBuilder(
              stream: database.child('$uuid/players').onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                if (snapshot.hasData) {
                  var players =
                      Map.from(snapshot.data.snapshot.value).keys.toList();
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
            ))
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: null, child: Icon(Icons.settings)),
    );
  }
}
