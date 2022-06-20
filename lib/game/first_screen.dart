import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizard/game/second_screen.dart';
import 'package:quizard/localization/classes/language_constants.dart';

import '../consts.dart';
import '../home.dart';
import '../providers.dart';
import 'auxiliaries.dart';

// The first game screen is where we answer a question wrongly.
class FirstGameScreen extends StatefulWidget {
  const FirstGameScreen({Key? key}) : super(key: key);

  @override
  State<FirstGameScreen> createState() => _FirstGameScreenState();
}

class _FirstGameScreenState extends State<FirstGameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Timer _timer;
  bool _enableSubmitAnswer = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: timePerScreen));
    _controller.forward();

    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection("$firestoreMainPath/${gameModel.gamePath}")
        .doc(gameModel.pinCode);
    for (int i = 0; i < maxPlayers; i++) {
      gameRef.update({
        "player$i.round_score": 0,
        "player$i.selected_answer": "",
        "player$i.false_answer": ""
      });
    }
    gameModel.roundScoreView = 0;
    gameModel.resetFalseAnswers();
    gameModel.resetSelectedAnswers();
    gameModel.falseAnswerController.text = '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // went to Background
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const HomePage()));
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap button
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Exited'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const [
                  Text('You were kicked from the game because'
                      ' your app has been paused.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection("$firestoreMainPath/${gameModel.gamePath}")
        .doc(gameModel.pinCode);
    int i = gameModel.playerIndex;

    // someone-is-exited handler
    Future.delayed(Duration(seconds: timePerScreen + 4 + gameModel.playerIndex),
        () {
      if (mounted) {
        gameRef.get().then((game) {
          for (int i = 0; i < maxPlayers; i++) {
            if (game["player$i.false_answer"] == "" &&
                game["player$i.username"] != "") {
              gameRef.update({"player$i.false_answer": " "});
            }
          }
        });
      }
    });

    Future<void> _submitFalseAnswer() async {
      FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard

      // don't proceed if that's the correct answer
      if (gameModel.falseAnswerController.text.toLowerCase() ==
          gameModel.gameAnswers[gameModel.currentQuestionIndex].toLowerCase()) {
        constSnackBar(translation(context).snackBar8, context);
        return;
      }

      // preparation for the next screen
      gameModel.selectedAnswer = "";

      // act only if their is a concrete input, or if time is over
      if (gameModel.falseAnswerController.text.replaceAll(" ", "") != "" ||
          gameModel.timeOut) {
        setState(() {
          _enableSubmitAnswer = false;
        });
        gameModel.selectedCorrectAnswer = false;
        gameModel.timeOut = false;
        String submittedFalseAnswer = gameModel.falseAnswerController.text;
        int currentScore = 0;
        // smoother on dismiss keyboard and submit with this delay
        await Future.delayed(const Duration(milliseconds: 500));
        await gameRef.get().then((game) {
          currentScore = game["player$i"]["score"];
        });
        gameModel.setDataToPlayer("score", currentScore, i);
        gameModel.setDataToPlayer("round_score", 0, i);
        gameModel.setDataToPlayer("selected_answer", "", i);
        gameModel.setDataToPlayer("false_answer", submittedFalseAnswer, i);
        await gameRef.update({"player$i.false_answer": submittedFalseAnswer});
      }
    }

    _timer = Timer(const Duration(seconds: timePerScreen), () {
      // if time out, submit
      if (_enableSubmitAnswer == true) {
        gameModel.timeOut = true;
        gameModel.falseAnswerController.text = " ";
        _submitFalseAnswer();
      }
    });

    var timerView = Countdown(
        animation: StepTween(
      begin: timePerScreen,
      end: 0,
    ).animate(_controller));

    Consumer<GameModel> _firstScreenBody() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        Future<Text> _scoreFuture() async {
          return await gameRef.get().then((game) {
            return Text("Score: ${game["player$i"]["score"]}",
                style: const TextStyle(fontSize: 24));
          });
        }

        FutureBuilder<Text> _score() {
          return FutureBuilder<Text>(
              future: _scoreFuture(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return snapshot.data!;
                  }
                }
                return Text(translation(context).score,
                    style: const TextStyle(fontSize: 24));
              });
        }

        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10),
                  child: Material(
                      elevation: 2,
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          width: 400,
                          decoration:
                              const BoxDecoration(color: playOptionColor),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _score(),
                                Row(children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 22.0,
                                  ),
                                  timerView
                                ])
                              ])))),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Question(gameModel.gameQuestions[gameModel.currentQuestionIndex],
                  gameModel.currentQuestionIndex + 1),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: TextFormField(
                      controller: gameModel.falseAnswerController,
                      decoration: InputDecoration(
                        enabled: _enableSubmitAnswer,
                        filled: true,
                        fillColor: secondaryColor,
                        contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: const OutlineInputBorder(),
                        hintText: translation(context).enterFalseAnswer,
                      ))),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 35, horizontal: 80),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: defaultColor,
                          minimumSize: const Size.fromHeight(50)), // max width
                      child: Text(translation(context).submit,
                          style: const TextStyle(fontSize: 18)),
                      onPressed:
                          _enableSubmitAnswer ? _submitFalseAnswer : null))
            ]));
      });
    }

    Stream<List<String>> _falseAnswers() async* {
      final game = gameRef.snapshots();
      await for (final snapshot in game) {
        List<String> falseAnswers = [];
        for (int i = 0; i < maxPlayers; i++) {
          if (snapshot["player$i"]["username"] != "") {
            falseAnswers.add(snapshot["player$i"]["false_answer"]);
          }
        }
        yield falseAnswers;
      }
    }

    Consumer<GameModel> _waitMessage() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        return StreamBuilder<List<String>>(
            stream: _falseAnswers(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                List<String>? falseAnswers = snapshot.data;
                if (falseAnswers != null) {
                  if (!falseAnswers.contains("")) {
                    // if all submitted
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecondGameScreen(),
                            )));
                  } else if (!_enableSubmitAnswer) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Text(translation(context).waitForOthers,
                                style: const TextStyle(fontSize: 24)),
                            Container(height: 25),
                            const CircularProgressIndicator()
                          ],
                        ));
                  }
                }
              }
              return Container();
            });
      });
    }

    return WillPopScope(
        child: Scaffold(
            backgroundColor: backgroundColor,
            body: SingleChildScrollView(
                reverse: true, // Helps to see the whole form
                child: Column(children: [_firstScreenBody(), _waitMessage()]))),
        // won't let pop
        onWillPop: () => Future<bool>.value(false));
  }
}
