import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quizard/localization/classes/language_constants.dart';
import 'package:quizard/providers.dart';

import 'consts.dart';

class QuickPlayAppBar extends StatelessWidget with PreferredSizeWidget {
  QuickPlayAppBar({Key? key}) : super(key: key);

  bool _canPop = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            color: backgroundColor,
            child: Padding(
                padding: const EdgeInsets.all(appbarPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: const Icon(
                        Icons.arrow_back,
                        color: defaultColor,
                        size: appbarIconSize,
                      ),
                      onTap: () async {
                        final playersRef = FirebaseFirestore.instance
                            .collection("$firestoreMainPath/official_games/"
                                "waiting_room/players");
                        final loginModel =
                            Provider.of<LoginModel>(context, listen: false);
                        final myPlayerDocRef =
                            playersRef.doc(loginModel.userId);
                        await FirebaseFirestore.instance
                            .runTransaction((transaction) async {
                          final doc = await transaction.get(myPlayerDocRef);
                          if (doc.exists) {
                            transaction.delete(myPlayerDocRef);
                            Navigator.of(context).maybePop(_canPop);
                            _canPop = false; // avoid spam click
                          }
                        });
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                            overlays: []);
                      },
                    ),
                  ],
                ))));
  }

  @override
  Size get preferredSize => const Size(0, appbarSize);
}

class QuickPlay extends StatefulWidget {
  const QuickPlay({Key? key}) : super(key: key);

  @override
  State<QuickPlay> createState() => _QuickPlayState();
}

class _QuickPlayState extends State<QuickPlay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      final loginModel = Provider.of<LoginModel>(context, listen: false);
      final playersRef = FirebaseFirestore.instance
          .collection("$firestoreMainPath/official_games/"
              "waiting_room/players");
      final gamesRef = FirebaseFirestore.instance
          .collection("$firestoreMainPath/official_games/");

      SizedBox _waitingScreen(int _numberOfPlayers) {
        return SizedBox.expand(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Image(
                          image: AssetImage('images/titles/quizard.png')),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          translation(context).waitForPlayers,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const Icon(
                        Icons.people_alt,
                        color: defaultColor,
                        size: appbarIconSize,
                      ),
                      Text(
                        "$_numberOfPlayers/5",
                        style: const TextStyle(fontSize: 24),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator()),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          translation(context).gameWillStartSoon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ])));
      }

      int _getNumOfPlayers(DocumentSnapshot game) {
        int numOfPlayers = 0;
        for (int i = 0; i < maxPlayers; i++) {
          if (game["player$i.username"] != "") {
            numOfPlayers++;
          }
        }
        return numOfPlayers;
      }

      return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: QuickPlayAppBar(),
            body: StreamBuilder(
              stream: playersRef.doc(loginModel.userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState != ConnectionState.waiting) {
                  var player = snapshot.data as DocumentSnapshot;
                  if (player.exists && player["pin_code"] != "") {
                    return StreamBuilder(
                        stream: gamesRef.doc(player["pin_code"]).snapshots(),
                        builder: (context, snapshot2) {
                          if (snapshot2.hasData &&
                              snapshot2.data != null &&
                              snapshot2.connectionState !=
                                  ConnectionState.waiting) {
                            var game = snapshot2.data! as DocumentSnapshot;
                            if (game.exists) {
                              return _waitingScreen(_getNumOfPlayers(game));
                            }
                          }
                          return _waitingScreen(1);
                        });
                  }
                }
                return _waitingScreen(1);
              },
            )),
        onWillPop: () async {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: []);
          return Future<bool>.value(true);
        },
      );
    });
  }
}
