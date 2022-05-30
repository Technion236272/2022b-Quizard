import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'consts.dart';

int questionIndex = 0;
List<Map<String, dynamic>> questions = [];

/*
Example of questions:

List<Map<String, dynamic>> questions = [
  {
    'questionText': 'Who was killed in south park?',
    'answers': [
      {'text': 'Eric', 'score': 0},
      {'text': 'Kyle', 'score': 0},
      {'text': 'Kenny', 'score': 10},
      {'text': 'Stan', 'score': 0},
    ],
  },
  {
    'questionText':
        'Family Guy storylines are often interrupted by fights between Peter and?',
    'answers': [
      {'text': 'A Giant Chicken', 'score': 10},
      {'text': 'heavy flo', 'score': 0},
      {'text': 'Patrick Pewterschmidt', 'score': 0},
      {'text': 'Glenn Quagmire', 'score': 0},
    ],
  },
];
*/

class Question extends StatelessWidget {
  final String _questionText;
  final int _questionIndex;

  Question(this._questionText, this._questionIndex);

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

class Answer extends StatelessWidget {
  final Function selectHandler;
  final String answerText;
  final int questionScore;

  Answer(this.selectHandler, this.answerText, this.questionScore);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: 400,
      height: 60,
      child: ElevatedButton(
        style: ButtonStyle(
            enableFeedback: true,
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                //The background color of an answer-button should change according to our selection.
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                if (questionScore > 0) {
                  return greenColor;
                } else {
                  return redColor;
                }
              } else {
                return secondaryColor;
              }
            })),
        child: Text(
          answerText,
          style: const TextStyle(color: defaultColor),
        ),
        onPressed: () {},
      ),
    );
  }
}

class Quiz extends StatefulWidget {
  const Quiz({Key? key, required this.pinCode, required this.answerQuestion})
      : super(key: key);
  final String pinCode;
  final Function answerQuestion;

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Question(questions[questionIndex]['questionText'] as String,
            questionIndex + 1),
        ...(questions[questionIndex]['answers'] as List<Map<String, dynamic>>)
            .map((answer) {
          return Answer(() => widget.answerQuestion(answer['score']),
              answer['text'] as String, answer['score'] as int);
        }).toList(),
      ],
    );
  }
}

// Should be the score-board class.
class Result extends StatelessWidget {
  final int resultScore;
  final Function resetHandler;

  Result(this.resultScore, this.resetHandler);

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
  const SecondGameScreen(
      {Key? key, required this.pinCode, required this.userIndex})
      : super(key: key);
  final String pinCode;
  final int userIndex;

  @override
  State<SecondGameScreen> createState() => _SecondGameScreenState();
}

class _SecondGameScreenState extends State<SecondGameScreen> {
  var _totalScore = 0;

  @override
  void initState() {
    super.initState();
  }

  void _answerQuestion(int score) {
    _totalScore += score;
    questionIndex = questionIndex + 1;
  }

  void _resetQuiz() {
    questionIndex = 0;
    _totalScore = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                    child: questionIndex < questions.length
                        ? Quiz(
                            pinCode: widget.pinCode,
                            answerQuestion: _answerQuestion)
                        : Result(_totalScore, _resetQuiz)),
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
            ))); //MaterialApp
  }
}

// The first game screen is where we answer a question wrongly.
// Almost nothing is fully implemented.

class FirstGameScreen extends StatefulWidget {
  const FirstGameScreen(
      {Key? key, required this.pinCode, required this.userIndex})
      : super(key: key);
  final String pinCode;
  final int userIndex;

  @override
  State<FirstGameScreen> createState() => _FirstGameScreenState();
}

class _FirstGameScreenState extends State<FirstGameScreen> {
  // Timer? _countDownTimer;
  // Duration _timeDuration = Duration(seconds: 30);
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  /*  Timer Functions
  void _setCountDown() {
    setState(() {
      final seconds = _timeDuration.inSeconds - 1;
      if (seconds < 0) {
        _countDownTimer!.cancel();
      } else {
        _timeDuration = Duration(seconds: seconds);
      }
    });
  }

  void _startTimer() {
    _countDownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => _setCountDown());
  }

  void _stopTimer() {
    setState(() => _countDownTimer!.cancel());
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _timeDuration = Duration(seconds: 10));
  }

   */

  @override
  Widget build(BuildContext context) {
    final game = FirebaseFirestore.instance
        .collection("versions/v1/custom_games")
        .doc(widget.pinCode);

    StreamBuilder<DocumentSnapshot<Object?>> _bodyBuild() {
      return StreamBuilder<DocumentSnapshot>(
          stream: game.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (data != null) {
                final falseAnswers = List<String>.from(data["false_answers"]);
                if (!falseAnswers.contains('')) {
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (context) => SecondGameScreen(
                            pinCode: widget.pinCode,
                            userIndex: widget.userIndex)));
                  });
                }
              }
            }
            return Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(children: <Widget>[
                  Question(questions[questionIndex]['questionText'] as String,
                      questionIndex + 1),
                  Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: TextFormField(
                          controller: _answerController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: secondaryColor,
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(),
                            hintText: 'Enter a false answer...',
                          ))),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 60, horizontal: 80),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: defaultColor,
                              minimumSize:
                                  const Size.fromHeight(50)), // max width
                          child: const Text('Submit',
                              style: TextStyle(fontSize: 18)),
                          onPressed: () async {
                            var game = FirebaseFirestore.instance
                                .collection('versions/v1/custom_games')
                                .doc(widget.pinCode);
                            var falseAnswers = [];
                            await game.get().then((value) {
                              falseAnswers = value["false_answers"];
                            });
                            falseAnswers[widget.userIndex] =
                                _answerController.text;
                            await game.update({"false_answers": falseAnswers});
                          })),
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

    Future<bool> _buildQuestions() async {
      await FirebaseFirestore.instance
          .collection('versions/v1/custom_games')
          .doc(widget.pinCode)
          .get()
          .then((game) {
        for (int i = 0; i < roundsPerGame; i++) {
          Map<String, dynamic> rightAnswer = {'text': '', 'score': 10};
          rightAnswer["text"] = game["answers"][i];
          Map<String, dynamic> question = {'questionText': '', 'answers': []};
          question["questionText"] = game["questions"][i];
          question["answers"] = [rightAnswer];
          questions.add(question);
        }
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
