import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

      SizedBox _waitingScreen() {
        return SizedBox.expand(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
              Image(image: AssetImage('images/titles/quizard.png')),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  "Waiting for more players...",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Icon(
                Icons.people_alt,
                color: defaultColor,
                size: appbarIconSize,
              ),
              Text(
                "1/5",
                style: TextStyle(fontSize: 24),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator()),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  "The game will start soon.",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ]));
      }

      Stream<bool> _foundGame() async* {
        final myPlayerRef = playersRef.doc(loginModel.userId);
        bool _foundGame = false;
        await myPlayerRef.get().then((player) {
          if (player.exists && player["pin_code"] != "") {
            _foundGame = true;
          }
        });
        yield _foundGame;
      }

      return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: QuickPlayAppBar(),
            body: StreamBuilder(
              stream: _foundGame(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data == true) {
                    debugPrint(snapshot.data.toString());
                  }
                }
                return _waitingScreen();
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
