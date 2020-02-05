import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:james_bond/PlayingCard.dart';

// ignore: must_be_immutable
class CenterCards extends StatefulWidget {
  List<PlayingCard> cards;
  String uuid;

  CenterCards({@required Key key, @required this.cards, @required this.uuid})
      : super(key: key);

  @override
  CenterCardsState createState() => CenterCardsState();
}

class CenterCardsState extends State<CenterCards> {
  DatabaseReference ref = FirebaseDatabase.instance.reference();
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
      for (int i = 0; i < stringPack.length; i++)
        widget.cards.add(PlayingCard.fromString(stringPack[i]));
      setState(() {});
    });
  }

  void removeCard(PlayingCard card) {
    ref.once().then((cards) {
      var stringPack = cards.value;
      List<String> center = [];
      for (int i = 0; i < stringPack.length; i++) center.add(stringPack[i]);

      center.removeAt(center.indexOf(card.retriveStringFormat()));

      ref.set(center);

      setState(() {
        widget.cards.remove(card);
      });
    });
  }

  void addCard(PlayingCard card) {
    ref.once().then((cards) {
      var stringPack = cards.value;
      List<String> center = [];
      for (int i = 0; i < stringPack.length; i++) center.add(stringPack[i]);

      center.add(card.retriveStringFormat());

      ref.set(center);

      setState(() {
        widget.cards.add(card);
      });
    });
  }

  List<Widget> _generateCenterCards() {
    List<Widget> _result = [];
    for (int i = 0; i < widget.cards.length; i++) {
      _result.add(
        Draggable(
//          hapticFeedbackOnStart: true,
          data: widget.cards[i],
          onDragStarted: () {
            tempCard = widget.cards[i];
            removeCard(widget.cards[i]);
          },
          onDraggableCanceled: (vel, off) {
            addCard(tempCard);
            tempCard = null;
          },
          feedback: widget.cards[i].buildCard(
              flipped: true, stackFinished: false, partOfCenter: true),
          child: widget.cards[i].buildCard(
              flipped: true, stackFinished: false, partOfCenter: true),
        ),
      );
    }
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
