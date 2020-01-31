import 'dart:math';

import 'package:flutter/material.dart';
import 'package:james_bond/Deck.dart';
import 'package:james_bond/PlayingCard.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  final List<GlobalKey<DeckState>> keys = [];
  List<Deck> decks = [];
  List<PlayingCard> centerCards = [];

  @override
  void initState() {
    super.initState();

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

    // TODO: Randomly give 24 cards to opponent player
    for (int i = 0; i < 24; i++)
      fullDeck.removeAt(Random().nextInt(fullDeck.length));

    // Assign the remaining 4 cards as the cards in the center
    centerCards = fullDeck;
  }

  Widget deckBuilder(int index) {
    return GestureDetector(
      onVerticalDragEnd: (drag) {
        if (drag.primaryVelocity > 0) closeOtherDecks(index);
      },
      child: DragTarget(
        builder: (context, List<PlayingCard> candidateData, rejectedData) {
          return decks[index];
        },
        onWillAccept: (data) {
          return !decks[index].deck.contains(data);
        },
        onAccept: (data) async {
          if (centerCards.contains(data)) {
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
            if (result != null) {
              setState(() {
                centerCards.remove(data);
                centerCards.add(result);
                keys[index].currentState.removeCard(result);
                keys[index].currentState.addCard(data);
              });
            } else
              print('no result');
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

  List<Widget> _generateCenterCards() {
    List<Widget> _result = [];
    for (int i = 0; i < centerCards.length; i++)
      _result.add(centerCards[i].buildCard(true));
    return _result;
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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
                        deckBuilder(0),
                        deckBuilder(1),
                        deckBuilder(2),
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
                        deckBuilder(3),
                        deckBuilder(4),
                        deckBuilder(5),
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
                    child: DragTarget(
                      builder: (context, List<PlayingCard> candidateData,
                          rejectedData) {
                        return SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _generateCenterCards(),
                          ),
                        );
                      },
                      onWillAccept: (data) {
                        return centerCards.length < 4 &&
                            !centerCards.contains(data);
                      },
                      onAccept: (data) {
                        for (int i = 0; i < keys.length; i++) {
                          if (decks[i].deck.contains(data))
                            keys[i].currentState.removeCard(data);
                        }
                        centerCards.add(data);
                      },
                    ),
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
