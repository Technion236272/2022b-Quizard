import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import 'home.dart';
import 'providers.dart';
import 'consts.dart';

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({Key? key}) : super(key: key);

  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  late ConfettiController _controllerTopCenter;

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    Future<bool> _getUsersIds() async {
      await FirebaseFirestore.instance
          .collection('$strVersion/users')
          .get()
          .then((users) async {
        List players = gameModel.getListOfUsernames();
        for (int k = 0; k < players.length; k++) {
          for (var user in users.docs) {
            if (user["username"] == players[k]) {
              String id = user.id;
              gameModel.playersIds.add(id);
              break;
            }
          }
        }
      });
      return true;
    }

    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 60));
    _controllerTopCenter.play();

    Consumer<GameModel> _bodyBuild() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        Padding _player(String username, String userId, int i) {
          Future<NetworkImage?> _getUserImage() async {
            final ref =
                FirebaseStorage.instance.ref('images/profiles/$userId.jpg');
            final url = await ref.getDownloadURL();
            return NetworkImage(url);
          }

          FutureBuilder<NetworkImage?> _getAvatarImage() {
            return FutureBuilder<NetworkImage?>(
                future: _getUserImage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CircleAvatar(
                        backgroundImage: snapshot.data,
                        backgroundColor: thirdColor,
                        radius: 25);
                  }
                  return const CircleAvatar(
                      backgroundImage: AssetImage('images/avatar.png'),
                      backgroundColor: thirdColor,
                      radius: 25);
                });
          }

          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: _getAvatarImage(),
                title: Text(username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18)),
                trailing: Text("${gameModel.players[i]["score"]}",
                    style: const TextStyle(fontSize: 18)),
              ));
        }

        ListView _players() {
          List<Widget> players = [];
          final usernames = gameModel.getListOfUsernames();
          final indexes = gameModel.getListOfIndexes();
          final ids = gameModel.playersIds;
          for (int i = 0; i < usernames.length; i++) {
            players.add(_player(usernames[i], ids[i], indexes[i]));
          }
          return ListView(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: players);
        }

        return Center(
            child: Column(children: [
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: Image(image: AssetImage('images/titles/winner.png'))),
          FutureBuilder(
              future: _getUsersIds(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data != null) {
                  return Center(
                      child: Column(children: [
                    ConfettiWidget(
                      confettiController: _controllerTopCenter,
                      blastDirection: 180,
                      numberOfParticles: 20,
                      emissionFrequency: 0.002,
                      shouldLoop: false,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          child: _players(),
                          width: 300,
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            border: Border.all(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(100),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: defaultColor,
                            minimumSize:
                                const Size.fromHeight(50)), // max width
                        child: const Text('End Game',
                            style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          if (gameModel.playerIndex == 0) {
                            FirebaseFirestore.instance
                                .collection("$strVersion/custom_games")
                                .doc(gameModel.pinCode)
                                .delete();
                          }
                          gameModel.resetData();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                  builder: (context) => const HomePage()));
                        },
                      ),
                    )
                  ]));
                }
                return Container();
              })
        ]));
      });
    }

    return Scaffold(
        backgroundColor: backgroundColor, body: _bodyBuild()); //MaterialApp
  }
}

class Countdown extends AnimatedWidget {
  const Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);

  final Animation<int> animation;

  @override
  build(BuildContext context) {
    final clockTimer = Duration(seconds: animation.value);

    String timerText = '${clockTimer.inMinutes.remainder(60).toString()}:'
        '${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      timerText,
      style: const TextStyle(
        fontSize: 22,
        color: defaultColor,
      ),
    );
  }
}

class Question extends StatelessWidget {
  final String _questionText;
  final int _questionIndex;

  const Question(this._questionText, this._questionIndex, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    String strCategory =
        gameModel.gameCategories[gameModel.currentQuestionIndex];
    return Column(children: [
      Material(
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 400,
            decoration: const BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Text(
                strCategory + '\n',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Text(
                'Question $_questionIndex\n',
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              Text(
                _questionText,
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ]), //Text
            alignment: Alignment.center,
          )),
      const Padding(padding: EdgeInsets.symmetric(vertical: 18)),
    ]);
  }
}

class Answer extends StatefulWidget {
  const Answer({Key? key, required this.answerText, required this.isCorrect})
      : super(key: key);
  final String answerText;
  final bool isCorrect;

  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> with TickerProviderStateMixin {
  Color buttonColor = secondaryColor;
  late Countdown _timerView;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: timePerScreen));
    _controller.forward();
    _timerView = Countdown(
        animation: StepTween(
      begin: timePerScreen,
      end: 0,
    ).animate(_controller));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameDoc = FirebaseFirestore.instance
        .collection('$strVersion/custom_games')
        .doc(gameModel.pinCode);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: 400,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: buttonColor),
        child: Text(
          widget.answerText,
          style: const TextStyle(color: defaultColor),
        ),
        onPressed: () async {
          await gameDoc.get().then((game) async {
            int i = gameModel.playerIndex;
            String selectedAnswer = game["player$i"]["selected_answer"];
            // allow press only if pressed an answer for the first time
            if (selectedAnswer == "" && buttonColor == secondaryColor) {
              final currentRoundScore =
                  correctAnswerScore + _timerView.animation.value;
              gameModel.setDataToPlayer("round_score", currentRoundScore, i);
              if (widget.isCorrect) {
                gameModel.selectedCorrectAnswer = true;
                setState(() {
                  buttonColor = greenColor;
                });
                final updatedScore =
                    gameModel.players[i]["score"] + currentRoundScore;
                gameModel.setDataToPlayer("score", updatedScore, i);
              } else {
                gameModel.selectedCorrectAnswer = false;
                setState(() {
                  buttonColor = redColor;
                });
              }
              // then update data in both game model and firebase
              gameModel.setDataToPlayer(
                  "selected_answer", widget.answerText, i);
              await Future.delayed(const Duration(seconds: 2));
              await gameDoc.update({"player$i": gameModel.players[i]});
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (context) => const Game()));
            }
          });
        },
      ),
    );
  }
}

// For showing earned score with this show-up effect
class ShowUp extends StatefulWidget {
  final Widget child;
  final int delay;

  const ShowUp({Key? key, required this.child, required this.delay})
      : super(key: key);

  @override
  _ShowUpState createState() => _ShowUpState();
}

class _ShowUpState extends State<ShowUp> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    final curve =
        CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero)
            .animate(curve);

    Timer(Duration(milliseconds: widget.delay), () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
      opacity: _animController,
    );
  }
}

// The second game screen is where we select the right answer (hopefully).
class SecondGameScreen extends StatefulWidget {
  const SecondGameScreen({Key? key}) : super(key: key);

  @override
  State<SecondGameScreen> createState() => _SecondGameScreenState();
}

class _SecondGameScreenState extends State<SecondGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  bool selectedCorrect = false;
  late NavigatorState _navigator;

  @override
  void didChangeDependencies() {
    _navigator = Navigator.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: timePerScreen));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final game = FirebaseFirestore.instance
        .collection("$strVersion/custom_games")
        .doc(gameModel.pinCode);

    Consumer<GameModel> _quizBody() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        int i = gameModel.playerIndex;
        int currentQuestionIndex1 = gameModel.currentQuestionIndex;
        int currentPhase1 = gameModel.currentPhase;

        _timer = Timer(const Duration(seconds: timePerScreen), () {
          int currentQuestionIndex2 = gameModel.currentQuestionIndex;
          int currentPhase2 = gameModel.currentPhase;
          // if the screen is relevant
          if (currentPhase1 == currentPhase2 &&
              currentQuestionIndex1 == currentQuestionIndex2 &&
              gameModel.players[i]["selected_answer"] == "") {
            gameModel.setDataToPlayer("selected_answer", " ", i);
            game.update({"player$i": gameModel.players[i]});
            _navigator.pushReplacement(
                MaterialPageRoute<void>(builder: (context) => const Game()));
          }
        });

        // Prepare question and answers widgets
        if (gameModel.currentQuestionIndex < gameModel.gameAnswers.length) {
          List<String> falseAnswers = gameModel.getFalseAnswers();
          String correctAnswer =
              gameModel.gameAnswers[gameModel.currentQuestionIndex];
          List<String> currentAnswers = [correctAnswer] + falseAnswers;
          if (gameModel.currentQuizOptions.isEmpty) {
            // Add correct answer
            gameModel.currentQuizOptions
                .add(Answer(answerText: currentAnswers[0], isCorrect: true));

            // Add false answers
            for (int i = 1; i < currentAnswers.length; i++) {
              String currentAnswer = currentAnswers[i];
              currentAnswer = currentAnswer.replaceAll(' ', '');
              int j = gameModel.playerIndex;
              String myFalseAnswer = gameModel.players[j]["false_answer"];
              if (currentAnswer != "" && currentAnswers[i] != myFalseAnswer) {
                gameModel.currentQuizOptions.add(
                    Answer(answerText: currentAnswers[i], isCorrect: false));
              }
            }

            // Shuffle all answers!
            gameModel.currentQuizOptions.shuffle();

            // We add the question to the top
            gameModel.currentQuizOptions.insert(
                0,
                Question(
                    gameModel.gameQuestions[gameModel.currentQuestionIndex],
                    gameModel.currentQuestionIndex + 1));
          }
        }

        final currentRoundScore = gameModel.players[i]["round_score"];
        return Column(
          children: gameModel.currentQuizOptions +
              [
                Visibility(
                    visible: gameModel.selectedCorrectAnswer,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: ShowUp(
                            delay: 100,
                            child: Text("+$currentRoundScore",
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
                                )))))
              ],
        );
      });
    }

    Consumer<GameModel> _secondScreenBody() {
      Countdown timerView = Countdown(
          animation: StepTween(
        begin: timePerScreen,
        end: 0,
      ).animate(_controller));

      return Consumer<GameModel>(builder: (context, gameModel, child) {
        int i = gameModel.playerIndex;
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
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  Row(children: [
                                    const Icon(
                                      Icons.timer,
                                      size: 22.0,
                                    ),
                                    timerView
                                  ])
                                ])))),
                _quizBody()
              ]), //Scaffold
            ));
      });
    }

    return Scaffold(
        backgroundColor: backgroundColor,
        body: _secondScreenBody()); //MaterialApp
  }
}

// The first game screen is where we answer a question wrongly.
class FirstGameScreen extends StatefulWidget {
  const FirstGameScreen({Key? key}) : super(key: key);

  @override
  State<FirstGameScreen> createState() => _FirstGameScreenState();
}

class _FirstGameScreenState extends State<FirstGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: timePerScreen));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection("$strVersion/custom_games")
        .doc(gameModel.pinCode);
    int i = gameModel.playerIndex;

    Future<void> _submitFalseAnswer() async {
      gameModel.selectedCorrectAnswer = false;
      gameModel.setDataToPlayer("round_score", 0, i);
      if (gameModel.falseAnswerController.text != "") {
        String submittedFalseAnswer = gameModel.falseAnswerController.text;
        gameModel.setDataToPlayer("false_answer", submittedFalseAnswer, i);
        await gameRef.update({"player$i": gameModel.players[i]});
        gameModel.enableSubmitFalseAnswer = false;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const Game()));
      }
    }

    _timer = Timer(const Duration(seconds: timePerScreen), () {
      if (gameModel.enableSubmitFalseAnswer == true) {
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
                                Text(
                                  "Score: ${gameModel.players[i]["score"]}",
                                  style: const TextStyle(fontSize: 24),
                                ),
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
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: secondaryColor,
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                        hintText: 'Enter a false answer...',
                      ))),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 35, horizontal: 80),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: defaultColor,
                          minimumSize: const Size.fromHeight(50)), // max width
                      child:
                          const Text('Submit', style: TextStyle(fontSize: 18)),
                      onPressed: gameModel.enableSubmitFalseAnswer
                          ? _submitFalseAnswer
                          : null))
            ]));
      });
    }

    return Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(child: _firstScreenBody()));
  }
}

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    Stack _resultText(String strResult, Color clrResult) {
      return Stack(
        children: [
          // The text border
          Text(
            strResult,
            style: TextStyle(
              fontSize: 30,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = defaultColor,
            ),
          ),
          // The text inside
          Text(
            strResult,
            style: TextStyle(
              fontSize: 30,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
              color: clrResult,
            ),
          ),
        ],
      );
    }

    Consumer<GameModel> _bodyBuild() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        final gameRef = FirebaseFirestore.instance
            .collection("$strVersion/custom_games")
            .doc(gameModel.pinCode);
        return StreamBuilder<DocumentSnapshot>(
            stream: gameRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (data != null) {
                  gameModel.update(data);
                }
              }

              final falseAnswers = gameModel.getFalseAnswers();
              final selectedAnswers = gameModel.getSelectedAnswers();

              // Advance to the next screen is necessary
              if (!falseAnswers.contains('') && gameModel.currentPhase == 1) {
                gameRef.update({
                  "game_phase": 2,
                });
                gameModel.currentPhase = 2;
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondGameScreen(),
                    ),
                  ),
                );
                return Container();
              } else if (!selectedAnswers.contains('') &&
                  gameModel.currentPhase == 2) {
                /*
                int i = gameModel.playerIndex;
                var updatedScore = gameModel.players[i]["score"];
                String myFalseAnswer = gameModel.players[i]["false_answer"];
                if (myFalseAnswer.replaceAll(" ", "") != "") {
                  for (int j = 0; j < maxPlayers; j++) {
                    if (myFalseAnswer ==
                        gameModel.players[j]["selected_answer"]) {
                      updatedScore += gameModel.players[j]["round_score"];
                      //gameModel.setDataToPlayer("score", updatedScore, i);
                    }
                  }
                }
                */

                gameModel.resetFalseAnswers();
                gameModel.resetSelectedAnswers();
                for (int i = 0; i < maxPlayers; i++) {
                  gameRef.update({"player$i": gameModel.players[i]});
                }
                gameModel.currentPhase = 1;
                gameModel.currentQuestionIndex++;
                gameRef.update({
                  "game_phase": 1,
                  "question_index": gameModel.currentQuestionIndex
                });
                gameModel.enableSubmitFalseAnswer = true;
                gameModel.falseAnswerController.text = '';
                gameModel.currentQuizOptions = [];
                if (gameModel.currentQuestionIndex < roundsPerGame) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FirstGameScreen(),
                      ),
                    ),
                  );
                } else {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScoreBoard(),
                      ),
                    ),
                  );
                }
                return Container();
              }

              // Wait for all false answers
              if (gameModel.currentPhase == 1) {
                String result = "";
                int i = gameModel.playerIndex;
                String falseAnswer = gameModel.players[i]["false_answer"];

                if (falseAnswer != "") {
                  result = "False answer submitted";
                }

                return Column(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100.0),
                      child: Center(
                          child: Text(
                        result,
                        style: const TextStyle(fontSize: 24),
                      ))),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Column(
                        children: [
                          const Text("Waiting for other players...",
                              style: TextStyle(fontSize: 24)),
                          Container(height: 25),
                          const CircularProgressIndicator()
                        ],
                      ))
                ]);
              }

              // Wait for all players to select answers
              if (gameModel.currentPhase == 2) {
                var result = Stack(children: const [Text("")]);
                int i = gameModel.playerIndex;
                String selectedAnswer = gameModel.players[i]["selected_answer"];
                int j = gameModel.currentQuestionIndex;
                String correctAnswer = gameModel.gameAnswers[j];
                if (selectedAnswer == correctAnswer) {
                  result = _resultText("Correct Answer", greenColor);
                } else if (selectedAnswer != "" && selectedAnswer != " ") {
                  result = _resultText("Wrong Answer", redColor);
                }
                return Column(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100.0),
                      child: Center(child: result)),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Column(
                        children: [
                          const Text("Waiting for other players...",
                              style: TextStyle(fontSize: 24)),
                          Container(height: 25),
                          const CircularProgressIndicator()
                        ],
                      ))
                ]);
              }

              return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 150.0),
                  child: Center(child: CircularProgressIndicator()));
            });
      });
    }

    return Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(child: _bodyBuild()));
  }
}
