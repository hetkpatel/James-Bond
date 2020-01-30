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
        onAccept: (data) {
          if (centerCards.contains(data))
            setState(() {
              centerCards.remove(data);
            });
          else
            for (int i = 0; i < keys.length; i++) {
              if (decks[i].deck.contains(data))
                keys[i].currentState.removeCard(data);
            }
          keys[index].currentState.addCard(data);
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
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _generateCenterCards(),
                        );
                      },
                      onWillAccept: (data) {
                        return centerCards.length < 4;
                      },
                      onAccept: (data) {
                        print(data);
                        print((data as PlayingCard).value);
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
