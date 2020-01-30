import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayingCard {
  CardSuit suit;
  String value;

  PlayingCard({this.suit, this.value});

  Widget _generateCard(bool flipped) {
    return SizedBox(
      width: 100.0,
      height: 155.0,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: flipped
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          value.toUpperCase(),
                          style: TextStyle(
                              fontSize: 22.0,
                              color: suit == CardSuit.HEART ||
                                      suit == CardSuit.DIAMOND
                                  ? Colors.red
                                  : Colors.black),
                        ),
                        SizedBox(width: 8.0),
                        _getIcon(_IconSize.SMALL)
                      ],
                    ),
                    _getIcon(_IconSize.LARGE),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _getIcon(_IconSize.SMALL),
                        SizedBox(width: 8.0),
                        Text(
                          value.toUpperCase(),
                          style: TextStyle(
                              fontSize: 22.0,
                              color: suit == CardSuit.HEART ||
                                      suit == CardSuit.DIAMOND
                                  ? Colors.red
                                  : Colors.black),
                        ),
                      ],
                    ),
                  ],
                )
              : ClipRRect(
                  child: Container(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
        ),
      ),
    );
  }

  Widget buildCard(bool flipped) {
    if (flipped)
      return LongPressDraggable<PlayingCard>(
          hapticFeedbackOnStart: true,
          data: this,
          childWhenDragging: Container(
            height: 155.0,
            width: 100.0,
          ),
          feedback: _generateCard(flipped),
          child: _generateCard(flipped));
    else
      return _generateCard(flipped);
  }

  // TODO: Change icons to be more similar
  // TODO: Spade SVG needs to be changed
  SvgPicture _getIcon(_IconSize size) {
    switch (suit) {
      case CardSuit.SPADE:
        return SvgPicture.asset(
          "assets/spade.svg",
          width: size == _IconSize.LARGE ? 52.0 : 12.0,
        );
        break;
      case CardSuit.CLUB:
        return SvgPicture.asset(
          "assets/club.svg",
          width: size == _IconSize.LARGE ? 52.0 : 12.0,
        );
        break;
      case CardSuit.HEART:
        return SvgPicture.asset(
          "assets/heart.svg",
          width: size == _IconSize.LARGE ? 52.0 : 12.0,
        );
        break;
      case CardSuit.DIAMOND:
        return SvgPicture.asset(
          "assets/diamond.svg",
          width: size == _IconSize.LARGE ? 52.0 : 14.0,
        );
        break;
    }
    return null;
  }
}

enum CardSuit { SPADE, HEART, DIAMOND, CLUB }

enum _IconSize { LARGE, SMALL }

class CardData {
  static List<String> values = [
    "A",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "J",
    "Q",
    "K"
  ];
}
