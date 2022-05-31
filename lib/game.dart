import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizard/home.dart';
import 'package:quizard/providers.dart';
import 'package:confetti/confetti.dart';
import 'consts.dart';

List<String> players = [];

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
class ScoreBoard extends StatefulWidget {
  const ScoreBoard(
      {Key? key, required this.pinCode})
      : super(key: key);
  final String pinCode;

  @override
  _ScoreBoardState createState() => _ScoreBoardState();

}

class _ScoreBoardState extends State<ScoreBoard> {
  late ConfettiController _controllerTopCenter;
  @override
  Widget build(BuildContext context) {
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerTopCenter.play();
    Future<List<String>> _buildPlayers() async {
      await FirebaseFirestore.instance
          .collection('versions/v1/custom_games')
          .doc(widget.pinCode)
          .get()
          .then((game) {
        players = List<String>.from(game["participants"]);
      });

      for(var name in players)
      {


      }

      return players;
    }

    return Scaffold(
        body: Container(
            child: Column( children: [
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Image(
                      image:
                      AssetImage('images/titles/winner.png'))),
              FutureBuilder(
                future: _buildPlayers(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  print(snapshot.data);
                  if(snapshot.data == null){
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    return Center(child:
                    Column(children:[
                      ConfettiWidget(
                        confettiController: _controllerTopCenter,
                        blastDirection: 7,
                        shouldLoop: false,
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          height: 400,
                          width: 350,
                          decoration: BoxDecoration(
                            border: Border.all(
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: secondaryColor,
                          ),
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "https://www.google.com/search?q=image&sxsrf=ALiCzsYILxEWE940ni0LAbcujZ3rgC1VDg:1653996309044&tbm=isch&source=iu&ictx=1&vet=1&fir=sp12V8x9gw6KuM%252C4O2GvGuD-Cf09M%252C_%253BgxFxsvFBmxeZ9M%252C0JWe7yDOKrVFAM%252C_%253BDH7p1w2o_fIU8M%252CBa_eiczVaD9-zM%252C_%253BQOZymhPf48LDYM%252CLOSptVP0p_ZwUM%252C_%253Bn5hAWsQ-sgKo_M%252C-UStXW0dQEx4SM%252C_%253B2DNOEjVi-CBaYM%252CAOz9-XMe1ixZJM%252C_%253B0DzWhtJoQ1KWgM%252CcIQ7wXCEtJiOWM%252C_%253Bz4_uU0QB2pe-SM%252C7SySw5zvOgPYAM%252C_%253B2nDXavJs9DoKTM%252CB51x0PBR9KNzvM%252C_%253BsI3XXpFjQg61vM%252C0_HmqFdutkPVdM%252C_%253BMOAYgJU89sFKnM%252CygIoihldBPn-LM%252C_%253BuPicAfWpubBp4M%252C_Hlm4-qqBRN0IM%252C_&usg=AI4_-kRJA4O93E7EcUkikx5uVNLogU3cNA&sa=X&ved=2ahUKEwiF99az0In4AhWE8LsIHXFZBGgQ9QF6BAgCEAE#imgrc=sp12V8x9gw6KuM"
                                  ),
                                ),
                                title: Text(snapshot.data[index]),
                              );
                            },
                          ))]));
                  }
                },
              ),
            ])));
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
                      Future.delayed(const Duration(milliseconds: 2000), () {
                        gameModel.currentAnswers = [];
                        final falseAnswers = [];
                        final selectedAnswersPerRound = [];
                        for (int i = 0;
                            i < gameModel.participants.length;
                            i++) {
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
                          gameModel.currentQuestionIndex++;
                          if (gameModel.currentQuestionIndex < roundsPerGame) {
                            Navigator.of(context).pop(true);
                          } else {
                            gameModel.currentQuestionIndex = 0;
                            Navigator.of(context).push(MaterialPageRoute<void>(
                                builder: (context) => ScoreBoard(pinCode: gameModel.pinCode)));
                          }
                        });
                        return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 150.0),
                            child: Center(child: CircularProgressIndicator()));
                      });
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
                      gameModel.currentAnswers.add(gameModel
                          .gameAnswers[gameModel.currentQuestionIndex]);
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
