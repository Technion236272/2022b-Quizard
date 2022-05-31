import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizard/providers.dart';
import 'consts.dart';

int questionIndex = 0;

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
        onPressed: () {
          final gameModel = Provider.of<GameModel>(context, listen: false);
          FirebaseFirestore.instance
              .collection('versions/v1/custom_games')
              .doc(gameModel.pinCode)
              .get()
              .then((game) {
            final selectedAnswers = List<String>.from(game["selected_answers"]);
            if (selectedAnswers[gameModel.userIndex] == "") {
              setState(() {
                if (widget.questionScore < 10) {
                  buttonColor = redColor;
                } else {
                  buttonColor = greenColor;
                }
              });
              selectedAnswers[gameModel.userIndex] = widget.answerText;
              FirebaseFirestore.instance
                  .collection('versions/v1/custom_games')
                  .doc(gameModel.pinCode)
                  .update({"selected_answers": selectedAnswers});
            }
          });
        },
      ),
    );
  }
}

// Should be the score-board class.
class Result extends StatelessWidget {
  final int resultScore;
  final Function resetHandler;

  const Result(
      {Key? key, required this.resultScore, required this.resetHandler})
      : super(key: key);

  //Result(this.resultScore, this.resetHandler);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Score ' '$resultScore',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            child: const Text(
              'Restart Quiz!',
            ), //Text
            onPressed: resetHandler(),
          ),
        ],
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

class _SecondGameScreenState extends State<SecondGameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final game = FirebaseFirestore.instance
        .collection("versions/v1/custom_games")
        .doc(gameModel.pinCode);

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
              const Padding(padding: EdgeInsets.symmetric(vertical: 40)),
              const Text(
                'Time left:',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              const Icon(
                Icons.timer,
                size: 40.0,
              )
            ]), //Scaffold
          ));
    }

    Consumer<GameModel> _bodyBuild() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        return StreamBuilder<DocumentSnapshot>(
            stream: game.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (data != null) {
                  final selectedAnswers =
                      List<String>.from(data["selected_answers"]);
                  if (!selectedAnswers.contains('')) {
                    if (gameModel.currentScreen == 2) {
                      gameModel.currentAnswers = [];
                      final falseAnswers = [];
                      final selectedAnswersPerRound = [];
                      for (int i = 0; i < gameModel.participants.length; i++) {
                        falseAnswers.add('');
                        selectedAnswersPerRound.add('');
                      }
                      game.update({
                        "selected_answers": selectedAnswersPerRound,
                        "false_answers": falseAnswers
                      });
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        gameModel.enableSubmitFalseAnswer = true;
                        gameModel.falseAnswerController.text = '';
                        gameModel.currentQuizOptions = [];
                        gameModel.currentScreen = 1;
                        questionIndex++;
                        Navigator.of(context).pop(true);
                      });
                      return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 150.0),
                          child: Center(child: CircularProgressIndicator()));
                    }
                  }
                }
              }
              if (gameModel.currentScreen == 2) {
                return _secondScreenBody();
              } else {
                return Container();
              }
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
        body: _bodyBuild()); //MaterialApp
  }
}

// The first game screen is where we answer a question wrongly.
// Almost nothing is fully implemented.

class FirstGameScreen extends StatefulWidget {
  const FirstGameScreen({Key? key}) : super(key: key);

  @override
  State<FirstGameScreen> createState() => _FirstGameScreenState();
}

class _FirstGameScreenState extends State<FirstGameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final game = FirebaseFirestore.instance
        .collection("versions/v1/custom_games")
        .doc(gameModel.pinCode);

    Future<void> _submitFalseAnswer() async {
      if (gameModel.falseAnswerController.text != "") {
        var game = FirebaseFirestore.instance
            .collection('versions/v1/custom_games')
            .doc(gameModel.pinCode);
        var falseAnswers = [];
        await game.get().then((value) {
          falseAnswers = value["false_answers"];
        });
        falseAnswers[gameModel.userIndex] =
            gameModel.falseAnswerController.text;
        await game.update({"false_answers": falseAnswers});
        gameModel.enableSubmitFalseAnswer = false;
      }
    }

    Consumer<GameModel> _firstScreenBody() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(children: <Widget>[
              Question(
                  gameModel.gameQuestions[questionIndex], questionIndex + 1),
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
              const Padding(padding: EdgeInsets.symmetric(vertical: 40)),
              const Text(
                'Time left:',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              const Icon(
                Icons.timer,
                size: 40.0,
              )
            ]));
      });
    }

    Consumer<GameModel> _bodyBuild() {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        return StreamBuilder<DocumentSnapshot>(
            stream: game.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (data != null) {
                  final falseAnswers = List<String>.from(data["false_answers"]);
                  if (!falseAnswers.contains('')) {
                    if (gameModel.currentScreen == 1) {
                      gameModel.currentAnswers = [];
                      gameModel.currentAnswers
                          .add(gameModel.gameAnswers[questionIndex]);
                      gameModel.currentAnswers.addAll(falseAnswers);
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        gameModel.currentScreen = 2;
                        Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (context) => const SecondGameScreen()));
                      });
                      return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 150.0),
                          child: Center(child: CircularProgressIndicator()));
                    }
                  }
                }
              }
              if (gameModel.currentScreen == 1) {
                return _firstScreenBody();
              } else {
                return Container();
              }
            });
      });
    }

    Future<bool> _buildQuestions() async {
      var game = FirebaseFirestore.instance
          .collection('versions/v1/custom_games')
          .doc(gameModel.pinCode);

      await game.get().then((game) {
        final gameModel = Provider.of<GameModel>(context, listen: false);
        gameModel.gameQuestions = List<String>.from(game["questions"]);
        gameModel.gameAnswers = List<String>.from(game["answers"]);
      });

      return true;
    }

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
            child: FutureBuilder(
                future: _buildQuestions(),
                builder: (context, questions) {
                  if (questions.hasData) {
                    return _bodyBuild();
                  }
                  return Container();
                })));
  }
}
