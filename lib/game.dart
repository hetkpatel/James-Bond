import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:james_bond/CenterCards.dart';
import 'package:james_bond/DatabaseStates.dart';
import 'package:james_bond/Deck.dart';
import 'package:james_bond/PlayingCard.dart';
import 'package:james_bond/winningScreen.dart';

class Game extends StatefulWidget {
  final String uuid;
  final bool host;

  Game({Key key, @required this.uuid, @required this.host}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  final List<GlobalKey<DeckState>> keys = [];
  DatabaseReference ref = FirebaseDatabase.instance.reference();
  List<Deck> decks = [];

//  List<PlayingCard> centerCards = [];
  GlobalKey<CenterCardsState> centerKey = GlobalKey();
  CenterCards centerCards;

  @override
  void initState() {
    super.initState();
    ref = ref.child(widget.uuid);

    if (widget.host) {
      // TODO: Perform a better way to divide the cards and make it more even and random
      // Create a full 52 deck
      List<PlayingCard> fullDeck = [];
      for (int i = 0; i < CardData.values.length; i++)
        for (int j = 0; j < CardSuit.values.length; j++)
          fullDeck.add(
              PlayingCard(suit: CardSuit.values[j], value: CardData.values[i]));

      // Randomly give 24 cards to this player
      for (int i = 0; i < 6; i++) {
        List<PlayingCard> deck = [];
        for (int j = 0; j < 4; j++)
          deck.add(fullDeck.removeAt(Random().nextInt(fullDeck.length)));

        keys.add(GlobalKey<DeckState>());
        decks.add(Deck(
          key: keys[i],
          deck: deck,
        ));
      }

      // Give 24 cards to opponent player
      List<PlayingCard> pack24 = [];
      for (int i = 0; i < 24; i++)
        pack24.add(fullDeck.removeAt(Random().nextInt(fullDeck.length)));
      ref.child("24Pack").set(PlayingCard.toDatabase(pack24));

      // Assign the remaining 4 cards as the cards in the center
      centerCards = CenterCards(
        key: centerKey,
        cards: fullDeck,
        uuid: widget.uuid,
      );
      ref.child("centerCards").set(PlayingCard.toDatabase(centerCards.cards));
    } else {
      // TODO: get centerCards and 24-pack from database
      ref.child("24Pack").once().then((pack) {
        var stringPack = pack.value;
        List<PlayingCard> deck24 = [];
        for (int i = 0; i < stringPack.length; i++)
          deck24.add(PlayingCard.fromString(stringPack[i]));

        for (int i = 0; i < 6; i++) {
          List<PlayingCard> deck = [];
          for (int j = 0; j < 4; j++)
            deck.add(deck24.removeAt(Random().nextInt(deck24.length)));

          keys.add(GlobalKey<DeckState>());
          decks.add(Deck(
            key: keys[i],
            deck: deck,
          ));
        }
        setState(() {});
      });

      ref.child("centerCards").once().then((center) {
        var stringPack = center.value;
        List<PlayingCard> cards = [];
        for (int i = 0; i < stringPack.length; i++)
          cards.add(PlayingCard.fromString(stringPack[i]));
        setState(() {
          centerCards = CenterCards(
            key: centerKey,
            cards: cards,
            uuid: widget.uuid,
          );
        });
      });
    }

    ref.child('state').onChildChanged.listen((state) {
      if (state.snapshot.value == DatabaseStates.FINISH) {
        Navigator.popUntil(context, ModalRoute.withName("/"));
        Navigator.pushReplacementNamed(context, "/Winning",
            arguments: WinningArgs(playerWon: false));
      }
    });
  }

//  @override
//  void dispose() {
//    super.dispose();
//    DatabaseReference database = FirebaseDatabase.instance.reference();
//    database.child(widget.uuid).remove();
//  }

  Widget _deckBuilder(int index) {
    return GestureDetector(
//      onVerticalDragEnd: (drag) {
//        if (drag.primaryVelocity > 0) closeOtherDecks(index);
//      },
      onDoubleTap: () => closeOtherDecks(index),
      child: DragTarget(
        builder: (context, List<PlayingCard> candidateData, rejectedData) {
          return decks[index];
        },
        onWillAccept: (data) {
          return !decks[index].deck.contains(data);
        },
        onAccept: (data) async {
          if (centerCards.cards.length != 4) {
            var result = await showDialog<PlayingCard>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Select card to swap'),
                    children: _generateDialogOptions(
                        keys[index].currentState.widget.deck, index),
                  );
                });
            if (result != null)
              setState(() {
//                centerCards.remove(data);
//                centerCards.add(result);
                centerKey.currentState.removeCard(data);
                centerKey.currentState.addCard(result);
                keys[index].currentState.removeCard(result);
                keys[index].currentState.addCard(data);
//                ref
//                    .child("centerCards")
//                    .set(PlayingCard.toDatabase(centerCards));
              });
            else {
              centerKey.currentState.addCard(centerKey.currentState.tempCard);
              centerKey.currentState.tempCard = null;
            }
          } else {
            for (int i = 0; i < keys.length; i++) {
              if (decks[i].deck.contains(data))
                keys[i].currentState.removeCard(data);
            }
            keys[index].currentState.addCard(data);
          }
        },
      ),
    );
  }

  List<Widget> _generateDialogOptions(List<PlayingCard> deck, int deckIndex) {
    List<Widget> result = [];
    for (int i = 0; i < deck.length; i++) {
      result.add(
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, keys[deckIndex].currentState.widget.deck[i]);
          },
          child: Text('${keys[deckIndex].currentState.widget.deck[i].value} of ' +
              '${CardSuitString.SUITS[keys[deckIndex].currentState.widget.deck[i].suit.index]}'),
        ),
      );
    }
    return result;
  }

  void closeOtherDecks(int openingIndex) {
    _checkForWinner();
    for (int i = 0; i < keys.length; i++)
      if (i == openingIndex)
        keys[i].currentState.animateDeck(open: true);
      else
        keys[i].currentState.animateDeck(open: false);
  }

  void _checkForWinner() {
    bool winner = true;
    for (int i = 0; i < decks.length; i++) {
      if (winner) winner = keys[i].currentState.stackComplete;
    }

    print(winner);

//    if (winner) {
//      ref.child('state').set(DatabaseStates.FINISH);
//      Navigator.popUntil(context, ModalRoute.withName("/"));
//      Navigator.pushReplacementNamed(context, "/Winning",
//          arguments: WinningArgs(playerWon: true));
//    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
//    if (keys.length != 0) _checkForWinner();

    return Scaffold(
      appBar: AppBar(
        title: Text('James Bond'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 240,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _deckBuilder(0),
                        _deckBuilder(1),
                        _deckBuilder(2),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 240,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _deckBuilder(3),
                        _deckBuilder(4),
                        _deckBuilder(5),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: size.width,
                height: 210,
                color: Colors.lightBlue,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: centerCards,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameArgs {
  final String uuid;
  final bool host;

  GameArgs({this.uuid, this.host});
}
