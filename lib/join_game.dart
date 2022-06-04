import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizard/providers.dart';

import 'consts.dart';
import 'lobby_player.dart';

class JoinGameAppBar extends StatelessWidget with PreferredSizeWidget {
  JoinGameAppBar({Key? key}) : super(key: key);

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
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ))));
  }

  @override
  Size get preferredSize => const Size(0, appbarSize);
}

class JoinGame extends StatelessWidget {
  JoinGame({Key? key}) : super(key: key);

  final pinCodeController = TextEditingController();

  Future<void> _initializeGame(
      GameModel gameModel, LoginModel loginModel) async {
    gameModel.pinCode = pinCodeController.text.toUpperCase();
    int newPlayerIndex = -1;
    var games =
        FirebaseFirestore.instance.collection('$strVersion/custom_games');
    await games.doc(gameModel.pinCode).get().then((game) {
      gameModel.update(game);
      newPlayerIndex = gameModel.addNewPlayer(loginModel.username);
      gameModel.pinCode = pinCodeController.text.toUpperCase();
    });
    final game = <String, dynamic>{
      "player$newPlayerIndex": gameModel.players[newPlayerIndex],
    };
    await games.doc(gameModel.pinCode).update(game);
  }

  Future<void> _goToGameLobby(BuildContext context) async {
    final pinCode = pinCodeController.text.toUpperCase();
    await FirebaseFirestore.instance
        .collection('$strVersion/custom_games')
        .get()
        .then((games) async {
      bool foundGame = false;
      int indexGame = -1;
      for (var game in games.docs) {
        indexGame++;
        if (game.id == pinCode) {
          foundGame = true;
          break;
        }
      }
      if (!foundGame) {
        FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard
        constSnackBar("Invalid PIN Code", context);
      } else {
        var wantedGame = games.docs[indexGame];
        if (wantedGame["is_locked"] == true) {
          FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard
          constSnackBar("Game is locked", context);
        } else {
          if (wantedGame["participants"].length == 5) {
            FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard
            constSnackBar("Game is full", context);
          } else {
            FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard
            final gameModel = Provider.of<GameModel>(context, listen: false);
            final loginModel = Provider.of<LoginModel>(context, listen: false);
            await _initializeGame(gameModel, loginModel);
            pinCodeController.text = '';
            Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) => const LobbyPlayer()));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: JoinGameAppBar(),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(children: [
              const Image(image: AssetImage('images/titles/quizard.png')),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Please enter a PIN Code',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                      enableSuggestions: false,
                      maxLength: 6,
                      controller: pinCodeController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: secondaryColor,
                        border: OutlineInputBorder(),
                        hintText: 'PIN Code',
                      ))),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)), // max width
                    child:
                        const Text('Join Game', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      _goToGameLobby(context);
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(children: const <Widget>[
                    // OR Divider
                    Expanded(child: Divider(color: defaultColor)),
                    Text("  OR  "),
                    Expanded(child: Divider(color: defaultColor)),
                  ])),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)), // max width
                    child: const Text('Find me an open game',
                        style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      constSnackBar("Coming soon", context);
                    },
                  )),
            ])));
  }
}
