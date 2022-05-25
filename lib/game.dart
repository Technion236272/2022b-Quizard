import 'dart:async';
import 'package:flutter/material.dart';
import 'consts.dart';


int questionIndex = 0;
final questions = [
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
    'questionText': 'Family Guy storylines are often interrupted by fights between Peter and?',
    'answers': [
      {'text': 'A Giant Chicken', 'score': 10},
      {'text': 'heavy flo', 'score': 0},
      {'text': 'Patrick Pewterschmidt', 'score': 0},
      {'text': 'Glenn Quagmire', 'score': 0},
    ],
  },
];


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
          decoration: BoxDecoration(
            color: secondaryColor,
              ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text( 'Question ' ' $_questionIndex\n',
            style: TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
            ),
            Text( '$_questionText',
              style: TextStyle(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            ]),//Text
          alignment: Alignment.center,
        ),
      Padding(padding: EdgeInsets.symmetric(vertical: 18)),
    ]);}
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
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(  //The background color of an answer-button should change according to our selection.
        (Set<MaterialState> states) {
        if(states.contains(MaterialState.pressed)) {
          if (questionScore > 0) {
            return Colors.green;
          }
          else {
            return Colors.red;
          }}
        else {
          return secondaryColor;
        }})),
        child: Text(answerText,
          style: TextStyle(color: Colors.black),),
        onPressed: () {},
      ), //RaisedButton
    ); //Container
  }
}



class Quiz extends StatelessWidget {
  final Function answerQuestion;

  Quiz({
    required this.answerQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Question(
          questions[questionIndex]['questionText'] as String,
        questionIndex + 1), //Question
        ...(questions[questionIndex]['answers'] as List<Map<String, Object>>)
            .map((answer) {
          return Answer(() => answerQuestion(answer['score']), answer['text'] as String, answer!['score'] as int);
        }).toList(),
      ],
    ); //Column
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
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            child: Text(
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

  SecondGameScreen({Key? key}) : super(key: key);

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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: backgroundColor,
          toolbarOpacity: 0,
          elevation: 0,
        ) ,
        backgroundColor: backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
              children: <Widget>[
                Container(
                    child: questionIndex < questions.length
                        ? Quiz(
                      answerQuestion: _answerQuestion)
                        : Result(_totalScore, _resetQuiz)),
                Padding(padding: EdgeInsets.symmetric(vertical: 40)),
                Text( 'Time left:',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Icon(
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
  const FirstGameScreen({Key? key}) : super(key: key);

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
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              backgroundColor: backgroundColor,
              toolbarOpacity: 0,
              elevation: 0,
            ),
            backgroundColor: backgroundColor,
            body: SingleChildScrollView(
              child:
                Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    Container(
                        child: Question(questions[questionIndex]['questionText'] as String, questionIndex + 1)),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: TextFormField(
                                  controller: _answerController,
                                  decoration: InputDecoration(
                                  filled: true,
                                  fillColor: secondaryColor,
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter a false answer...',
                                ))),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 80),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: defaultColor,
                                  minimumSize:
                                  const Size.fromHeight(50)
                              ), // max width
                              child: const Text('Submit',
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () { Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (context) => SecondGameScreen()));},
                            )),
                        Padding(padding: EdgeInsets.symmetric(vertical: 40)),
                        Text( 'Time left:',
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                        Icon(
                          Icons.timer,
                          size: 40.0,
                        )
                    ])))
        )); //MaterialApp
  }
}
