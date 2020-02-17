import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class WinningScreen extends StatefulWidget {
  @override
  _WinningScreenState createState() => _WinningScreenState();
}

class _WinningScreenState extends State<WinningScreen> {
  ConfettiController controller =
      ConfettiController(duration: Duration(seconds: 5));
  final List<Color> colors = [
    Color.fromRGBO(168, 100, 253, 1.0),
    Color.fromRGBO(41, 205, 255, 1.0),
    Color.fromRGBO(120, 255, 68, 1.0),
    Color.fromRGBO(255, 113, 141, 1.0),
    Color.fromRGBO(253, 255, 106, 1.0)
  ];

  @override
  void initState() {
    super.initState();
    controller.play();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  Widget win(Size size, Duration time) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirection: pi / 4,
            shouldLoop: true,
            colors: colors,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirection: 3 * pi / 4,
            shouldLoop: true,
            colors: colors,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: size.height * .70,
            width: size.width * .75,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You won!',
                      style: TextStyle(
                          fontFamily: "Special Elite", fontSize: 60.0),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'You finished in\n${format(time)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Special Elite", fontSize: 24.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget lose(Size size) {
    return SizedBox(
      height: size.height * .70,
      width: size.width * .75,
      child: Card(
        child: Center(
          child: Text(
            'Next time loser!',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Special Elite", fontSize: 60.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WinningArgs args = ModalRoute.of(context).settings.arguments;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: args.playerWon ? Text('Congratulations!') : Text('Oops!'),
      ),
      body: Center(
        child: args.playerWon ? win(size, args.time) : lose(size),
      ),
    );
  }
}

class WinningArgs {
  final bool playerWon;
  final Duration time;

  WinningArgs({@required this.playerWon, this.time});
}
