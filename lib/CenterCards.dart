import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:james_bond/PlayingCard.dart';
import 'package:vibrate/vibrate.dart';

// ignore: must_be_immutable
class CenterCards extends StatefulWidget {
  Map<String, PlayingCard> cards;
  String uuid;
  bool host;

  CenterCards({
    @required Key key,
    @required this.cards,
    @required this.uuid,
    @required this.host,
  }) : super(key: key);

  @override
  CenterCardsState createState() => CenterCardsState();
}

class CenterCardsState extends State<CenterCards> {
  DatabaseReference ref = FirebaseDatabase.instance.reference();
  String key;
  PlayingCard tempCard;

  @override
  void initState() {
    super.initState();
    ref = ref.child(widget.uuid);

    ref
        .child('centerCards')
        .onChildAdded
        .listen((event) => _updateCenterCards());
    ref
        .child('centerCards')
        .onChildRemoved
        .listen((event) => _updateCenterCards());
    ref
        .child('centerCards')
        .onChildChanged
        .listen((event) => _updateCenterCards());

    ref
        .child('players/${widget.host ? 'player2' : 'player1'}')
        .onValue
        .listen((card) {
      if (card.snapshot.value != "nullCard" && tempCard != null) {
        if (card.snapshot.value == tempCard.retriveStringFormat()) {
          if (widget.host) if (Random().nextBool()) {
            key = null;
            tempCard = null;
            ref.child('players/player1').set('removeCard');
            vibrateDev();
          } else
            ref.child('players/player2').set('removeCard');
        }
      }
    });

    ref
        .child('players/${widget.host ? 'player1' : 'player2'}')
        .onValue
        .listen((myCard) {
      if (myCard.snapshot.value == 'removeCard') {
        key = null;
        tempCard = null;
        ref
            .child('players/${widget.host ? 'player1' : 'player2'}')
            .set('nullCard');
        vibrateDev();
      }
    });
  }

  void vibrateDev() async {
    if (await Vibrate.canVibrate) {
      Vibrate.vibrate();
    }
  }

  void _updateCenterCards() {
    ref.child('centerCards').once().then((center) {
      var stringPack = center.value;
      widget.cards.clear();
      for (int i = 0; i < 4; i++)
        if (stringPack["card$i"] != null)
          widget.cards["card$i"] = PlayingCard.fromString(stringPack["card$i"]);
      setState(() {});
    });
  }

  void addCard(PlayingCard card) {
    ref.child('centerCards').child(key).set(card.retriveStringFormat());
    ref.child('players/${widget.host ? 'player1' : 'player2'}').set('nullCard');
  }

  void removeCard(PlayingCard card) {
    ref.child('centerCards').child(key).remove();
    ref
        .child('players/${widget.host ? 'player1' : 'player2'}')
        .set(card.retriveStringFormat());
  }

  List<Widget> _generateCenterCards(var context) {
    List<Widget> _result = [];
    for (int i = 0; i < 4; i++)
      if (widget.cards["card$i"] != null)
        _result.add(
          Draggable(
            data: widget.cards["card$i"],
            onDragStarted: () {
              tempCard = widget.cards["card$i"];
              key = "card$i";
              removeCard(widget.cards["card$i"]);
            },
            onDraggableCanceled: (vel, off) {
              addCard(tempCard);
              key = null;
              tempCard = null;
            },
            feedback: widget.cards["card$i"].buildCard(
              context: context,
              flipped: true,
              stackFinished: false,
              partOfCenter: true,
            ),
            child: widget.cards["card$i"].buildCard(
              context: context,
              flipped: true,
              stackFinished: false,
              partOfCenter: true,
            ),
          ),
        );
    return _result;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _generateCenterCards(context),
    );
  }
}
