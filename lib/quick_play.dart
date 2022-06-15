import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quizard/providers.dart';

import 'consts.dart';
import 'game/lobby/admin.dart';
import 'game/lobby/player.dart';
import 'localization/classes/language_constants.dart';

class QuickPlayAppBar extends StatelessWidget with PreferredSizeWidget {
  QuickPlayAppBar({Key? key}) : super(key: key);

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
                      onTap: () {
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                            overlays: []);
                        Navigator.of(context).pop(true);
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
      final gamesRef = FirebaseFirestore.instance
          .collection('$firestoreMainPath/custom_games');

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

      return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: QuickPlayAppBar(),
            body: _waitingScreen()),
        onWillPop: () async {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: []);
          return Future<bool>.value(true);
        },
      );
    });
  }
}
