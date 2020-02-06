import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayingCard {
  CardSuit suit;
  String value;

  PlayingCard({this.suit, this.value});

  PlayingCard.fromString(String parsedString) {
    String suit = parsedString.split("|")[0];
    String value = parsedString.split("|")[1];
    switch (suit) {
      case "Spades":
        this.suit = CardSuit.SPADE;
        break;
      case "Hearts":
        this.suit = CardSuit.HEART;
        break;
      case "Diamonds":
        this.suit = CardSuit.DIAMOND;
        break;
      case "Clubs":
        this.suit = CardSuit.CLUB;
        break;

      default:
        break;
    }
    this.value = value;
  }

  Widget _generateCard(bool flipped, bool stackFinished) {
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
                    color: stackFinished ? Colors.green : Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
        ),
      ),
    );
  }

  Widget buildCard(
      {@required bool flipped,
      @required bool stackFinished,
      bool partOfCenter}) {
    if (partOfCenter == null) partOfCenter = false;
    if (flipped)
      return !partOfCenter
          ? LongPressDraggable<PlayingCard>(
              hapticFeedbackOnStart: true,
              data: this,
              feedback: _generateCard(flipped, stackFinished),
              child: _generateCard(flipped, stackFinished))
          : _generateCard(flipped, stackFinished);
    else
      return _generateCard(flipped, stackFinished);
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

  String retriveStringFormat() {
    return CardSuitString.SUITS[this.suit.index] + "|" + this.value;
  }

  static List<String> toDatabase24(List<PlayingCard> stack) {
    List<String> result = [];
    for (int i = 0; i < stack.length; i++)
      result.add(
          CardSuitString.SUITS[stack[i].suit.index] + "|" + stack[i].value);
    return result;
  }

  static Map<String, String> toDatabaseCenter(Map<String, PlayingCard> stack) {
    Map<String, String> result = {};
    for (int i = 0;i<stack.length;i++)
      result["card$i"] = CardSuitString.SUITS[stack["card$i"].suit.index] + "|" + stack["card$i"].value;
    return result;
  }
}

enum CardSuit { SPADE, HEART, DIAMOND, CLUB }

class CardSuitString {
  // ignore: non_constant_identifier_names
  static final List<String> SUITS = ["Spades", "Hearts", "Diamonds", "Clubs"];
}

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
