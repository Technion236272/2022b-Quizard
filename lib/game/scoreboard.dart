import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../consts.dart';
import '../home.dart';
import '../localization/classes/language.dart';
import '../providers.dart';
import 'package:quizard/localization/classes/language_constants.dart';


class ScoreBoard extends StatefulWidget {
  const ScoreBoard({Key? key}) : super(key: key);

  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  late ConfettiController _controllerTopCenter;
  final List<String> _playersIds = [];

  @override
  Widget build(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection("$firestoreMainPath/${gameModel.gamePath}")
        .doc(gameModel.pinCode);

    Future<bool> _getUsersIdsOnce() async {
      if (_playersIds.isNotEmpty) {
        return false;
      }
      await FirebaseFirestore.instance
          .collection("$firestoreMainPath/${gameModel.gamePath}")
          .doc(gameModel.pinCode)
          .get()
          .then((game) {
        for (int k = 0; k < maxPlayers; k++) {
          gameModel.setDataToPlayer("score", game["player$k.score"], k);
        }
      });
      await FirebaseFirestore.instance
          .collection('$firestoreMainPath/users')
          .get()
          .then((users) async {
        List players = gameModel.getPlayersSortedByScore(false);
        int topScore = 0;
        if (gameModel.isOfficial) {
          for (int k = 0; k < maxPlayers; k++) {
            if (gameModel.players[k]["username"] != "" &&
                topScore < gameModel.players[k]["score"]) {
              topScore = gameModel.players[k]["score"];
            }
          }
        }
        for (int k = 0; k < players.length; k++) {
          for (var user in users.docs) {
            if (user["username"] == players[k] &&
                !_playersIds.contains(user.id)) {
              _playersIds.add(user.id);
              if (topScore > 0 &&
                  players[k] == loginModel.username &&
                  topScore == gameModel.getScoreByUsername(players[k])) {
                int totalWins = user["wins"];
                int monthlyWins = user["MonthlyWins"];
                int dailyWins = user["DailyWins"];
                user.reference.update({
                  "wins": totalWins + 1,
                  "MonthlyWins": monthlyWins + 1,
                  "DailyWins": dailyWins + 1
                });
              }
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
        Stream<Text> _streamScore(int i) async* {
          yield await gameRef.get().then((game) async {
            return Text("${game["player$i"]["score"]}",
                style: const TextStyle(fontSize: 18));
          });
        }

        StreamBuilder<Text> _score(int i) {
          return StreamBuilder<Text>(
              stream: _streamScore(i),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return snapshot.data!;
                }
                return const Text("");
              });
        }

        Padding _player(String username, String userId, int j) {
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
                  if (snapshot.hasData &&
                      snapshot.connectionState != ConnectionState.waiting) {
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
                trailing: _score(j),
              ));
        }

        ListView _players() {
          List<Widget> players = [];
          final usernames = gameModel.getPlayersSortedByScore(false);
          final indexes = gameModel.getPlayersSortedByScore(true);
          for (int i = 0; i < usernames.length; i++) {
            players.add(_player(usernames[i], _playersIds[i], indexes[i]));
          }
          return ListView(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: players);
        }

        var local = Localization.getLocale(context);
        String assetImage = 'images/titles/winner.png';
        if(local == "עברית")
        {
          assetImage = 'images/titles/winner_he.png';
        }
        if(local == "العربية")
        {
          assetImage = 'images/titles/winner_ar.png';
        }

        return Center(
            child: Column(children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Image(image: AssetImage(assetImage))),
          FutureBuilder(
              future: _getUsersIdsOnce(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.connectionState != ConnectionState.waiting) {
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
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Container(
                          child: _players(),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            border: Border.all(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: defaultColor,
                            minimumSize:
                                const Size.fromHeight(50)), // max width
                        child: Text(translation(context).endGame,
                            style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          gameModel.resetData();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
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

    return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: backgroundColor,
            body: SingleChildScrollView(child: _bodyBuild())),
        // won't let pop
        onWillPop: () => Future<bool>.value(false)); //MaterialApp
  }
}
