import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:james_bond/PlayingCard.dart';

// ignore: must_be_immutable
class CenterCards extends StatefulWidget {
  Map<String, PlayingCard> cards;
  String uuid;
  bool host;

  CenterCards({@required Key key, @required this.cards, @required this.uuid, @required this.host})
      : super(key: key);

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
    ref = ref.child('${widget.uuid}/centerCards');

    ref.onChildAdded.listen((event) => _updateCenterCards());
    ref.onChildRemoved.listen((event) => _updateCenterCards());
    ref.onChildChanged.listen((event) => _updateCenterCards());
  }

  void _updateCenterCards() {
    ref.once().then((center) {
      var stringPack = center.value;
      widget.cards.clear();
      for (int i = 0; i < 4; i++)
        if (stringPack["card$i"] != null)
          widget.cards["card$i"] = PlayingCard.fromString(stringPack["card$i"]);
      setState(() {});
    });
  }

  void addCard(PlayingCard card) {
    ref.child(key).set(card.retriveStringFormat());
  }

  void removeCard(PlayingCard card) {
    ref.child(key).remove();
  }

  List<Widget> _generateCenterCards() {
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
                flipped: true, stackFinished: false, partOfCenter: true),
            child: widget.cards["card$i"].buildCard(
                flipped: true, stackFinished: false, partOfCenter: true),
          ),
        );
    return _result;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _generateCenterCards(),
    );
  }
}
