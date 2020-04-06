import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:suits/CenterCards.dart';
import 'package:suits/DatabaseStates.dart';
import 'package:suits/Deck.dart';
import 'package:suits/PlayingCard.dart';
import 'package:suits/winningScreen.dart';

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
  Timer timer;
  StreamSubscription finish;
  Stopwatch watch = Stopwatch();

  GlobalKey<CenterCardsState> centerKey = GlobalKey();
  CenterCards centerCards;

  @override
  void initState() {
    super.initState();
    ref = ref.child(widget.uuid);

    timer = Timer.periodic(
        Duration(milliseconds: 500), (timer) => _checkForWinner());

    if (widget.host) {
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
      ref.child("24Pack").set(PlayingCard.toDatabase24(pack24));

      Map<String, PlayingCard> centerDeck = {};
      for (int i = 0; i < fullDeck.length; i++)
        centerDeck["card$i"] = fullDeck[i];

      // Assign the remaining 4 cards as the cards in the center
      centerCards = CenterCards(
        key: centerKey,
        cards: centerDeck,
        uuid: widget.uuid,
        host: true,
      );
      ref
          .child("centerCards")
          .set(PlayingCard.toDatabaseCenter(centerCards.cards));
    } else {
      // Get centerCards and 24-pack from database
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
        Map<String, PlayingCard> cards = {};
        for (int i = 0; i < stringPack.length; i++)
          cards["card$i"] = PlayingCard.fromString(stringPack["card$i"]);

        setState(() {
          centerCards = CenterCards(
            key: centerKey,
            cards: cards,
            uuid: widget.uuid,
            host: false,
          );
        });
      });
    }

    finish = ref.child('state').onValue.listen((state) {
      if (state.snapshot.value == DatabaseStates.FINISH) {
        timer.cancel();
        Navigator.pushReplacementNamed(context, "/Winning",
            arguments: WinningArgs(playerWon: false, time: watch.elapsed));
      }
    });

    watch.start();
  }

  @override
  void dispose() {
    super.dispose();
    DatabaseReference database = FirebaseDatabase.instance.reference();
    database.child(widget.uuid).remove();
  }

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
          if (centerKey.currentState.tempCard == data) {
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
                centerKey.currentState.removeCard(data);
                centerKey.currentState.addCard(result);
                keys[index].currentState.removeCard(result);
                keys[index].currentState.addCard(data);
              });
            else
              centerKey.currentState.addCard(centerKey.currentState.tempCard);
            centerKey.currentState.tempCard = null;
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
    for (int i = 0; i < keys.length; i++)
      if (i == openingIndex)
        keys[i].currentState.animateDeck(open: true);
      else
        keys[i].currentState.animateDeck(open: false);
  }

  void _checkForWinner() {
    bool winner = true;
    for (int i = 0; i < decks.length; i++)
      if (winner) winner = keys[i].currentState.stackComplete;

    if (winner) {
      ref.child('state').set(DatabaseStates.FINISH);
      timer.cancel();
      finish.cancel();
      Navigator.pushReplacementNamed(context, "/Winning",
          arguments: WinningArgs(playerWon: true, time: watch.elapsed));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Suits'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
//                  height: 240,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
