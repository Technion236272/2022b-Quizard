import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quizard/providers.dart';

import 'consts.dart';
import 'game/lobby/admin.dart';
import 'game/lobby/player.dart';
import 'localization/classes/language_constants.dart';

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
  bool _pressedButton = false; // for both join game and find game

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      final loginModel = Provider.of<LoginModel>(context, listen: false);
      final gamesRef = FirebaseFirestore.instance
          .collection('$firestoreMainPath/${gameModel.gamePath}');

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
          _pressedButton = true;
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
            constSnackBar(translation(context).invalidPin, context);
          } else {
            var wantedGame = games.docs[indexGame];
            if (wantedGame["is_locked"] == true) {
              constSnackBar(translation(context).gameIsLocked, context);
            } else {
              gameModel.update(wantedGame);
              if (gameModel.getNumOfPlayers() == maxPlayers) {
                constSnackBar(translation(context).gameIsFull, context);
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
          _pressedButton = false;
        });
      }

      void _findOpenGame() async {
        setState(() {
          _pressedButton = true;
        });

        await gamesRef.get().then((games) async {
          bool joinedGame = false;
          final shuffledGames = [];
          for (var game in games.docs) {
            shuffledGames.add(game);
          }
          shuffledGames.shuffle();
          for (var game in shuffledGames) {
            if (joinedGame) {
              break;
            }
            if (!game["is_private"] && !game["is_locked"]) {
              gameModel.update(game);
              if (gameModel.getNumOfPlayers() < maxPlayers &&
                  gameModel.getNumOfPlayers() > 0) {
                // atomic read and write with one transaction for join game
                await FirebaseFirestore.instance
                    .runTransaction((transaction) async {
                  final gameDoc = await transaction.get(game.reference);
                  gameModel.playerIndex = -1;
                  // if player already exists
                  for (int i = 0; i < maxPlayers; i++) {
                    if (gameDoc["player$i.username"] == loginModel.username) {
                      gameModel.playerIndex = i;
                      break;
                    }
                  }
                  if (gameModel.playerIndex == -1) {
                    // else player doesn't exists
                    for (int i = 0; i < maxPlayers; i++) {
                      if (gameDoc["player$i.username"] == "") {
                        gameModel.playerIndex = i;
                        break;
                      }
                    }
                  }
                  transaction.update(game.reference, {
                    "player${gameModel.playerIndex}.username":
                        loginModel.username
                  });
                  gameModel.update(gameDoc);
                  gameModel.setDataToPlayer(
                      "username", loginModel.username, gameModel.playerIndex);
                  gameModel.pinCode = gameDoc.id;
                  // Hide navigation buttons
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                      overlays: []);
                  joinedGame = true;
                }).then(
                  (value) async {
                    await gamesRef.doc(gameModel.pinCode).update({
                      "player${gameModel.playerIndex}.username":
                          loginModel.username
                    });
                    debugPrint("DEBUG: gameDoc successfully updated");
                    WidgetsBinding.instance.addPostFrameCallback((_) =>
                        Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (context) => const LobbyPlayer())));
                  },
                  onError: (e) {
                    debugPrint("ERROR: can't update gameDoc. \n$e");
                  },
                );
              }
            }
          }
          if (!joinedGame) {
            constSnackBar(translation(context).noPublicGames, context);
          }
          setState(() {
            _pressedButton = false;
          });
        });
      }

      return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: JoinGameAppBar(),
            body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(children: [
                  const Image(image: AssetImage('images/titles/quizard.png')),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      translation(context).enterPin,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                          enableSuggestions: false,
                          maxLength: 6,
                          controller: pinCodeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: secondaryColor,
                            border: const OutlineInputBorder(),
                            hintText: translation(context).pin,
                          ))),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize:
                                  const Size.fromHeight(50)), // max width
                          child: Text(translation(context).joinGame,
                              style: const TextStyle(fontSize: 18)),
                          onPressed: _pressedButton ? null : _goToGameLobby)),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(children: <Widget>[
                        // OR Divider
                        const Expanded(child: Divider(color: defaultColor)),
                        Text(translation(context).or2),
                        const Expanded(child: Divider(color: defaultColor)),
                      ])),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize:
                                  const Size.fromHeight(50)), // max width
                          child: Text(translation(context).findOpenGame,
                              style: const TextStyle(fontSize: 18)),
                          onPressed: _pressedButton ? null : _findOpenGame)),
                ]))),
        onWillPop: () async {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: []);
          return Future<bool>.value(true);
        },
      );
    });
  }
}
