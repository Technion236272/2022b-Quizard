import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers.dart';
import '../consts.dart';

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
  late Countdown _timerView;
  late AnimationController _controller;
  late Timer _timer;
  Color _colorButton = secondaryColor;

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
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection('$firestoreMainPath/custom_games')
        .doc(gameModel.pinCode);
    int i = gameModel.playerIndex;

    return Consumer<GameModel>(builder: (context, gameModel, child) {
      _timer = Timer(const Duration(seconds: timePerScreen), () async {
        if (mounted) {
          // if time out
          if (gameModel.timeOut) {
            gameModel.timeOut = false;
          }
          // if didn't select answer - select demi
          if (gameModel.selectedAnswer.isEmpty &&
              gameModel.players[i]["selected_answer"].isEmpty) {
            gameModel.selectedAnswer = " ";
            gameModel.setDataToPlayer("selected_answer", " ", i);
            await gameRef.update({"player$i": gameModel.players[i]});
          }

          // if correct answer - set to green
          if (widget.isCorrect) {
            setState(() {
              _colorButton = greenColor;
            });
          }
        }
      });

      Future<void> _onSelectingAnswer() async {
        if (gameModel.selectedAnswer.isEmpty) {
          setState(() {
            _colorButton = orangeColor;
          });

          // score of round == time left
          // score is calculated by admin only after everyone selected answer
          // round score view only reflects score of correct answer

          if (widget.isCorrect) {
            gameModel.roundScoreView = _timerView.animation.value; // else 0
          }
          int timeLeft = _timerView.animation.value;
          gameModel.selectedCorrectAnswer = widget.isCorrect;
          gameModel.selectedAnswer = widget.answerText;
          gameModel.setDataToPlayer("selected_answer", widget.answerText, i);
          gameModel.setDataToPlayer("round_score", timeLeft, i);

          await gameRef.update({
            "player$i.round_score": timeLeft,
            "player$i.selected_answer": widget.answerText
          });
        }
      }

      ElevatedButton _answerButton(Color buttonColor) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(primary: buttonColor),
          child: Text(
            widget.answerText,
            style: const TextStyle(color: defaultColor),
          ),
          onPressed: _onSelectingAnswer,
        );
      }

      Stream<bool> _streamAreAllSelectedAnswer() async* {
        final game = gameRef.snapshots();
        await for (final snapshot in game) {
          bool yieldedFalse = false;
          for (int i = 0; i < maxPlayers; i++) {
            if (snapshot["player$i"]["username"] != "") {
              if (snapshot["player$i"]["selected_answer"] == "") {
                yieldedFalse = true;
                yield false;
              }
            }
          }
          if (!yieldedFalse) {
            yield true;
          }
        }
      }

      return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: 400,
          height: 60,
          child: StreamBuilder<bool>(
              stream: _streamAreAllSelectedAnswer(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  bool? areAllSelectedAnswer = snapshot.data;
                  if (areAllSelectedAnswer != null) {
                    if (areAllSelectedAnswer) {
                      if (widget.isCorrect) {
                        return _answerButton(greenColor);
                      } else if (gameModel.selectedAnswer ==
                          widget.answerText) {
                        return _answerButton(redColor);
                      }
                    }
                  }
                }
                return _answerButton(_colorButton);
              }));
    });
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
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
