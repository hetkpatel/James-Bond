import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:james_bond/PlayingCard.dart';

final key = new GlobalKey<DeckState>();

class Deck extends StatefulWidget {
  List<PlayingCard> deck = [];

  Deck({@required Key key, @required this.deck}) : super(key: key);

  @override
  DeckState createState() => DeckState();
}

class DeckState extends State<Deck> with SingleTickerProviderStateMixin {
  static final double SPACING = 26.0;
  bool flip = false;
  AnimationController _controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    animation = Tween(begin: 0.0, end: SPACING).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
        reverseCurve: Curves.easeInExpo))
      ..addListener(() {
        setState(() {});
      });
  }

  List<Widget> _createStackBlock(List<PlayingCard> stack) {
    List<Widget> result = [];
    if (stack.length == 0)
      result.add(
        DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(7.0),
          strokeWidth: 2.0,
          dashPattern: [6, 3, 2, 3],
          color: Colors.blue,
          child: Container(
            height: 155,
            width: 100,
          ),
        ),
      );
    else
      for (int i = 0; i < stack.length; i++) {
        result.add(
          Positioned(
            top: i == 0 ? null : animation.value * i,
            child: stack[i].buildCard(flip),
          ),
        );
      }
    return result;
  }

  void removeCard(PlayingCard card) {
    setState(() {
      widget.deck.remove(card);
    });
  }

  void addCard(PlayingCard card) {
    setState(() {
      widget.deck.add(card);
    });
  }

  void animateDeck({bool open}) {
    if (open) {
      setState(() {
        flip = true;
      });
      _controller.forward();
    } else {
      setState(() {
        flip = false;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: _createStackBlock(widget.deck),
    );
  }
}
