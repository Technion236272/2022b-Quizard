import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quizard/providers.dart';

import 'consts.dart';
import 'lobby_admin.dart';
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

class JoinGame extends StatefulWidget {
  const JoinGame({Key? key}) : super(key: key);

  @override
  State<JoinGame> createState() => _JoinGameState();
}

class _JoinGameState extends State<JoinGame> {
  final pinCodeController = TextEditingController();
  bool _pressedJoinGame = false;

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    final gamesRef = FirebaseFirestore.instance
        .collection('$firestoreMainPath/custom_games');

    Future<int> _initializeGameAndGetPlayerIndex() async {
      gameModel.pinCode = pinCodeController.text.toUpperCase();
      int newPlayerIndex = -1;
      await gamesRef.doc(gameModel.pinCode).get().then((game) async {
        // check if player already exists
        for (int i = 0; i < maxPlayers; i++) {
          if (game["player$i"]["username"] == loginModel.username) {
            newPlayerIndex = i;
            gameModel.playerIndex = i;
          }
        }
        gameModel.update(game);
        print("newPlayerIndex: " + newPlayerIndex.toString());
        // if player doesn't exist then add player to an empty slot
        if (newPlayerIndex == -1) {
          newPlayerIndex = gameModel.addNewPlayer(loginModel.username);
          await gamesRef.doc(gameModel.pinCode).update(
              {"player$newPlayerIndex": gameModel.players[newPlayerIndex]});
        }
      });
      pinCodeController.text = '';
      return newPlayerIndex;
    }

    Future<void> _goToGameLobby() async {
      if (pinCodeController.text == '') {
        return;
      }
      setState(() {
        _pressedJoinGame = true;
      });
      final enteredPinCode = pinCodeController.text.toUpperCase();
      await gamesRef.get().then((games) async {
        bool foundGame = false;
        int indexGame = -1;
        for (var game in games.docs) {
          indexGame++;
          if (game.id == enteredPinCode) {
            foundGame = true;
            break;
          }
        }
        FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard
        if (!foundGame) {
          constSnackBar("Invalid PIN Code", context);
        } else {
          var wantedGame = games.docs[indexGame];
          gameModel.update(wantedGame);
          if (wantedGame["is_locked"] == true) {
            constSnackBar("Game is locked", context);
          } else {
            if (gameModel.getNumOfPlayers() == maxPlayers) {
              constSnackBar("Game is full", context);
            } else {
              int i = await _initializeGameAndGetPlayerIndex();
              if (i == 0) {
                Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) =>
                        LobbyAdmin(isPrivate: wantedGame["is_private"])));
              } else {
                Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => const LobbyPlayer()));
              }
              // Hide navigation buttons
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                  overlays: []);
            }
          }
        }
      });
      setState(() {
        _pressedJoinGame = false;
      });
    }

    return WillPopScope(
      child: Scaffold(
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
                            minimumSize:
                                const Size.fromHeight(50)), // max width
                        child: const Text('Join Game',
                            style: TextStyle(fontSize: 18)),
                        onPressed: _pressedJoinGame ? null : _goToGameLobby)),
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
                        //TODO: Finish this
                        //constSnackBar("Coming soon", context);
                      },
                    )),
              ]))),
      onWillPop: () async {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: []);
        return Future<bool>.value(true);
      },
    );
  }
}
