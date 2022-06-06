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
        Padding _player(String username, String userId) {
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
                trailing: const Text("100", style: TextStyle(fontSize: 18)),
              ));
        }

        ListView _players() {
          List<Widget> players = [];
          final usernames = gameModel.getListOfUsernames();
          final ids = gameModel.playersIds;
          for (int i = 0; i < usernames.length; i++) {
            players.add(_player(usernames[i], ids[i]));
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
                      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                      child: ElevatedButton(
                        child: const Text(
                          'End Game',
                        ),
                        onPressed: () {
                          final gameModel =
                              Provider.of<GameModel>(context, listen: false);
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
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText = '${clockTimer.inMinutes.remainder(60).toString()}:'
        '${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      timerText,
      style: const TextStyle(
        fontSize: 32,
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
    return Column(children: [
      Container(
        width: 400,
        height: 250,
        decoration: const BoxDecoration(
          color: secondaryColor,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Question' ' $_questionIndex\n',
            style: const TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          Text(
            _questionText,
            style: const TextStyle(fontSize: 28),
            textAlign: TextAlign.center,
          ),
        ]), //Text
        alignment: Alignment.center,
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 18)),
    ]);
  }
}

class Answer extends StatefulWidget {
  const Answer(
      {Key? key, required this.answerText, required this.questionScore})
      : super(key: key);
  final String answerText;
  final int questionScore;

  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  Color buttonColor = secondaryColor;

  @override
  Widget build(BuildContext context) {
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
          final gameModel = Provider.of<GameModel>(context, listen: false);
          await FirebaseFirestore.instance
              .collection('$strVersion/custom_games')
              .doc(gameModel.pinCode)
              .get()
              .then((game) async {
            int i = gameModel.playerIndex;
            String selectedAnswer = game["player$i"]["selected_answer"];
            if (selectedAnswer == "") {
              setState(() {
                if (widget.questionScore < 10) {
                  buttonColor = redColor;
                } else {
                  buttonColor = greenColor;
                }
              });
              gameModel.setDataToPlayer(
                  "selected_answer", widget.answerText, i);
              await FirebaseFirestore.instance
                  .collection('$strVersion/custom_games')
                  .doc(gameModel.pinCode)
                  .update({"player$i": gameModel.players[i]});
            }
            Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (context) => const Game()));
          });
        },
      ),
    );
  }
}

// The second game screen is where we select the right answer (hopefully).
// The list of questions is here only temporarily.
// Almost nothing is fully implemented.

class SecondGameScreen extends StatefulWidget {
  const SecondGameScreen({Key? key}) : super(key: key);

  @override
  State<SecondGameScreen> createState() => _SecondGameScreenState();
}

class _SecondGameScreenState extends State<SecondGameScreen>
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
    final game = FirebaseFirestore.instance
        .collection("$strVersion/custom_games")
        .doc(gameModel.pinCode);

    _timer = Timer(const Duration(seconds: timePerScreen), () {
      int i = gameModel.playerIndex;
      gameModel.setDataToPlayer("selected_answer", " ", i);
      game.update({"player$i": gameModel.players[i]});
      Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const Game()));
    });

    Consumer<GameModel> _quizBody() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        gameModel.quizOptionsUpdate();
        return Column(
          children: gameModel.currentQuizOptions,
        );
      });
    }

    Padding _secondScreenBody() {
      game.get().then((value) {});
      return Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              _quizBody(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 45)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(
                  Icons.timer,
                  size: 40.0,
                ),
                Countdown(
                    animation: StepTween(
                  begin: timePerScreen,
                  end: 0,
                ).animate(_controller))
              ])
            ]), //Scaffold
          ));
    }

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        body: _secondScreenBody()); //MaterialApp
  }
}

// The first game screen is where we answer a question wrongly.
// Almost nothing is fully implemented.

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

    Future<void> _submitFalseAnswer() async {
      if (gameModel.falseAnswerController.text != "") {
        int i = gameModel.playerIndex;
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

    Consumer<GameModel> _firstScreenBody() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(children: <Widget>[
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
                      const EdgeInsets.symmetric(vertical: 60, horizontal: 80),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: defaultColor,
                          minimumSize: const Size.fromHeight(50)), // max width
                      child:
                          const Text('Submit', style: TextStyle(fontSize: 18)),
                      onPressed: gameModel.enableSubmitFalseAnswer
                          ? _submitFalseAnswer
                          : null)),
              const Padding(padding: EdgeInsets.symmetric(vertical: 45)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(
                  Icons.timer,
                  size: 40.0,
                ),
                Countdown(
                    animation: StepTween(
                  begin: timePerScreen,
                  end: 0,
                ).animate(_controller))
              ])
            ]));
      });
    }

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
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
                  result = Stack(
                    children: [
                      // The text border
                      Text(
                        'Correct Answer!',
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
                      const Text(
                        'Correct Answer!',
                        style: TextStyle(
                          fontSize: 30,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                    ],
                  );
                } else if (selectedAnswer != "" && selectedAnswer != " ") {
                  result = Stack(
                    children: [
                      // The text border
                      Text(
                        'Wrong Answer',
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
                      const Text(
                        'Wrong Answer',
                        style: TextStyle(
                          fontSize: 30,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                          color: redColor,
                        ),
                      ),
                    ],
                  );
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
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(child: _bodyBuild()));
  }
}
