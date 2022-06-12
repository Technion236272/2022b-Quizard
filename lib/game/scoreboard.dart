import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts.dart';
import '../home.dart';
import '../providers.dart';

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
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection("$firestoreMainPath/custom_games")
        .doc(gameModel.pinCode);

    Future<bool> _getUsersIdsOnce() async {
      if (_playersIds.isNotEmpty) {
        return false;
      }
      await FirebaseFirestore.instance
          .collection("$firestoreMainPath/custom_games")
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
        for (int k = 0; k < players.length; k++) {
          for (var user in users.docs) {
            if (user["username"] == players[k] &&
                !_playersIds.contains(user.id)) {
              _playersIds.add(user.id);
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

        return Center(
            child: Column(children: [
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: Image(image: AssetImage('images/titles/winner.png'))),
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
