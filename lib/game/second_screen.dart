// The second game screen is where we select the right answer (hopefully).
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizard/game/scoreboard.dart';

import '../consts.dart';
import '../providers.dart';
import 'auxiliaries.dart';
import 'first_screen.dart';

class SecondGameScreen extends StatefulWidget {
  const SecondGameScreen({Key? key}) : super(key: key);

  @override
  State<SecondGameScreen> createState() => _SecondGameScreenState();
}

class _SecondGameScreenState extends State<SecondGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Widget> _quizBodyWidgets = [];
  Future<void>? _delayNavigator;
  bool _calculatedFinalScores = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: timePerScreen));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _delayNavigator?.ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection("$strVersion/custom_games")
        .doc(gameModel.pinCode);
    int i = gameModel.playerIndex;

    Stream<List<Map<String, dynamic>>> _streamPlayers() async* {
      final game = gameRef.snapshots();
      await for (final snapshot in game) {
        List<Map<String, dynamic>> players = [];
        for (int i = 0; i < maxPlayers; i++) {
          players.add(snapshot["player$i"]);
        }
        yield players;
      }
    }

    // Question and Answers Widgets
    Consumer<GameModel> _quizBody(List<Map<String, dynamic>> players) {
      List<String> _getFalseAnswers() {
        List<String> falseAnswers = [];
        for (int i = 0; i < maxPlayers; i++) {
          if (players[i]["username"] != "") {
            falseAnswers.add(players[i]["false_answer"]);
          }
        }
        return falseAnswers;
      }

      return Consumer<GameModel>(builder: (context, gameModel, child) {
        // Prepare question and answers widgets
        if (gameModel.currentQuestionIndex < gameModel.gameAnswers.length &&
            _quizBodyWidgets.isEmpty) {
          List<String> falseAnswers = _getFalseAnswers();
          String correctAnswer =
              gameModel.gameAnswers[gameModel.currentQuestionIndex];
          List<String> currentAnswers = [correctAnswer] + falseAnswers;
          if (_quizBodyWidgets.isEmpty) {
            // Add correct answer
            _quizBodyWidgets
                .add(Answer(answerText: currentAnswers[0], isCorrect: true));

            // Add false answers
            for (int i = 1; i < currentAnswers.length; i++) {
              String currentAnswer = currentAnswers[i];
              currentAnswer = currentAnswer.replaceAll(' ', '');
              int j = gameModel.playerIndex;
              String myFalseAnswer = players[j]["false_answer"];
              if (currentAnswer != "" && currentAnswers[i] != myFalseAnswer) {
                _quizBodyWidgets.add(
                    Answer(answerText: currentAnswers[i], isCorrect: false));
              }
            }

            // Shuffle all answers!
            _quizBodyWidgets.shuffle();

            // We add the question to the top
            _quizBodyWidgets.insert(
                0,
                Question(
                    gameModel.gameQuestions[gameModel.currentQuestionIndex],
                    gameModel.currentQuestionIndex + 1));
          }
        }

        return Column(children: _quizBodyWidgets);
      });
    }

    Consumer<GameModel> _secondScreenBody() {
      // used to show time only
      Countdown timerView = Countdown(
          animation: StepTween(
        begin: timePerScreen,
        end: 0,
      ).animate(_controller));

      return Consumer<GameModel>(builder: (context, gameModel, child) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Material(
                        elevation: 2,
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            width: 400,
                            decoration:
                                const BoxDecoration(color: playOptionColor),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Score: ${gameModel.players[i]["score"]}",
                                      style: const TextStyle(fontSize: 24)),
                                  Row(children: [
                                    const Icon(
                                      Icons.timer,
                                      size: 22.0,
                                    ),
                                    timerView
                                  ])
                                ])))),
                StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _streamPlayers(), // INCLUDING EMPTY SLOTS!
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Map<String, dynamic>>? players = snapshot.data;
                        if (players != null) {
                          return _quizBody(players);
                        }
                      }

                      return Container();
                    })
              ]), //Scaffold
            ));
      });
    }

    Consumer<GameModel> _concludeMatchWidget(
        List<Map<String, dynamic>> players) {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        if (!_calculatedFinalScores && i == 0) {
          // only admin calculates final scores for everyone
          List<int> listOfScoresPerSlot = [];
          for (int l = 0; l < maxPlayers; l++) {
            listOfScoresPerSlot.add(players[l]["score"]);
          }

          // calculate false answers rewards
          for (int j = 0; j < maxPlayers; j++) {
            int jReward = 0;
            if (players[j]["username"] != "") {
              for (int k = 0; k < maxPlayers; k++) {
                // add for player j all the false answers scores
                String jFalseAnswer = players[j]["false_answer"];
                String kSelectedAnswer = players[k]["selected_answer"];
                if (jFalseAnswer == kSelectedAnswer && j != k) {
                  int kRoundScore = players[k]["round_score"];
                  jReward += kRoundScore;
                }
              }
            }
            listOfScoresPerSlot[j] += jReward;
          }

          // calculate correct answers rewards
          String correctAnswer =
              gameModel.gameAnswers[gameModel.currentQuestionIndex - 1];
          for (int j = 0; j < maxPlayers; j++) {
            int jReward = 0;
            if (players[j]["username"] != "") {
              String jSelectedAnswer = players[j]["selected_answer"];
              if (jSelectedAnswer == correctAnswer) {
                int jRoundScore = players[j]["round_score"];
                jReward += jRoundScore;
              }
            }
            listOfScoresPerSlot[j] += jReward;
          }

          // update final scores - ASSUMING 5 PLAYERS MAX - CHANGE IT IF NOT!
          gameRef.update({
            "player0.score": listOfScoresPerSlot[0],
            "player1.score": listOfScoresPerSlot[1],
            "player2.score": listOfScoresPerSlot[2],
            "player3.score": listOfScoresPerSlot[3],
            "player4.score": listOfScoresPerSlot[4],
          });

          _calculatedFinalScores = true;
        }

        if (gameModel.roundScoreView > 0) {
          return Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ShowUp(
                  delay: 100,
                  child: Text("+${gameModel.roundScoreView}",
                      style: const TextStyle(
                        fontSize: 24,
                        color: greenColor,
                        fontWeight: FontWeight.bold,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 8.0,
                            color: defaultColor,
                          ),
                        ],
                      ))));
        } else {
          // else show in red color
          return const Padding(
              padding: EdgeInsets.only(top: 30),
              child: ShowUp(
                  delay: 100,
                  child: Text("+0",
                      style: TextStyle(
                        fontSize: 24,
                        color: redColor,
                        fontWeight: FontWeight.bold,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 8.0,
                            color: defaultColor,
                          ),
                        ],
                      ))));
        }
      });
    }

    bool _areAllSelectedAnswer(List<Map<String, dynamic>> players) {
      for (int i = 0; i < maxPlayers; i++) {
        if (players[i]["username"] != "") {
          if (players[i]["selected_answer"] == "") {
            return false;
          }
        }
      }
      return true;
    }

    Consumer<GameModel> _statusMessage() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        bool incremented = false;
        return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _streamPlayers(), // INCLUDING EMPTY SLOTS!
            builder: (context, snapshot) {
              if (!mounted) {
                return Container();
              }
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                List<Map<String, dynamic>>? players = snapshot.data;
                if (players != null) {
                  if (_areAllSelectedAnswer(players)) {
                    // from here, all players pressed an answer
                    if (!incremented) {
                      gameModel.currentQuestionIndex++;

                      if (gameModel.currentQuestionIndex >= roundsPerGame) {
                        _delayNavigator = Future.delayed(
                            const Duration(seconds: delayScoreResult),
                            () => WidgetsBinding.instance.addPostFrameCallback(
                                (_) => Navigator.pushReplacement<void, void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          const ScoreBoard(),
                                    ))));
                      } else {
                        _delayNavigator = Future.delayed(
                            const Duration(seconds: delayScoreResult),
                            () => WidgetsBinding.instance.addPostFrameCallback(
                                (_) => Navigator.pushReplacement<void, void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          const FirstGameScreen(),
                                    ))));
                      }

                      incremented = true;
                    }
                    return _concludeMatchWidget(players);
                  } else if (gameModel.selectedAnswer != "" &&
                      players[i]["selected_answer"] != "") {
                    // if not all selected answers, but i did select!
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            const Text("Waiting for other players...",
                                style: TextStyle(fontSize: 24)),
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

    return Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
            child: Column(children: [_secondScreenBody(), _statusMessage()])));
  }
}