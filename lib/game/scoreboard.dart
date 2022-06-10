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

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final gameRef = FirebaseFirestore.instance
        .collection("$strVersion/custom_games")
        .doc(gameModel.pinCode);

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
        Future<Text> _scoreFuture(int i) async {
          return await gameRef.get().then((game) {
            return Text("${game["player$i"]["score"]}",
                style: const TextStyle(fontSize: 18));
          });
        }

        FutureBuilder<Text> _score(int i) {
          return FutureBuilder<Text>(
              future: _scoreFuture(i),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return snapshot.data!;
                  }
                }
                return const Text("");
              });
        }

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
                trailing: _score(i),
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
                          /*
                          if (gameModel.playerIndex == 0) {
                            FirebaseFirestore.instance
                                .collection("$strVersion/custom_games")
                                .doc(gameModel.pinCode)
                                .delete();
                          }
                           */
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
