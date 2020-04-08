import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How to play'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Starting off',
                        style: TextStyle(
                          fontFamily: "Special Elite",
                          fontSize: 40.0,
                        ),
                      ),
                    ),
                    Text(
                      'Both players start of with 6 stacks of cards, each with 4 cards. '
                      'To open the stack, double-tap on it. To move cards between stacks, '
                      'drag the card from the stack it is in to the desired location. You cannot move cards in a closed stack, but you can move cards into a closed stack.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: "Kelly Slab", fontSize: 20.0),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 28.0),
                      child: Text(
                        'How to win',
                        style: TextStyle(
                          fontFamily: "Special Elite",
                          fontSize: 40.0,
                        ),
                      ),
                    ),
                    Text(
                      'The objective of the game is to get all 6 stacks into the same kind. '
                      'Such as all Aces in one stack, 3s in another, and so on.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: "Kelly Slab", fontSize: 20.0),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 28.0),
                      child: Text(
                        'Shared cards',
                        style: TextStyle(
                          fontFamily: "Special Elite",
                          fontSize: 40.0,
                        ),
                      ),
                    ),
                    Text(
                      'The 4 cards on the bottom of the screen are ones that are shared between the two players. '
                      'They are on a first-come-first-serve basis so if you need the card, make sure to get it before your opponent does. In order to use one of these, you need to drag one into a stack and swap with an existing card.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: "Kelly Slab", fontSize: 20.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
