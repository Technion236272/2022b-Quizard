import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'game.dart';
import 'lobby_appbar.dart';
import 'providers.dart';
import 'consts.dart';

class LobbyPlayer extends StatefulWidget {
  const LobbyPlayer({Key? key}) : super(key: key);

  @override
  State<LobbyPlayer> createState() => _LobbyPlayerState();
}

class _LobbyPlayerState extends State<LobbyPlayer> {
  bool finishedBuildAllCustomCategories = false;
  String lockText = '';

  @override
  void initState() {
    super.initState();
    lockText = 'UNLOCKED';
  }

  Container _categoriesTitle(String title, String subtitle) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        color: lightBlueColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  color: defaultColor,
                  fontWeight: FontWeight.w500),
            ),
            Text(subtitle)
          ],
        ));
  }

  Consumer<GameModel> _selectedCategoriesChips() {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      if (gameModel.selectedCategories.isEmpty) {
        return const Flexible(
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "No categories selected",
                  style: TextStyle(fontSize: 18),
                )));
      } else {
        return Flexible(
            fit: FlexFit.loose,
            child: ChipsChoice<String>.multiple(
              value: gameModel.selectedCategories,
              onChanged: (val) {},
              choiceItems: C2Choice.listFrom<String, String>(
                source: gameModel.selectedCategories,
                value: (i, v) => v,
                label: (i, v) => v,
                tooltip: (i, v) => v,
              ),
              choiceActiveStyle: const C2ChoiceStyle(
                  color: defaultColor,
                  borderColor: defaultColor,
                  backgroundColor: lightBlueColor),
              wrapped: true,
              textDirection: TextDirection.ltr,
              choiceStyle: const C2ChoiceStyle(
                color: defaultColor,
                borderColor: defaultColor,
              ),
            ));
      }
    });
  }

  Card _selectedCategories() {
    return Card(
        elevation: 2,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _categoriesTitle(
                  'Selected Categories', 'Only the admin can set categories'),
              _selectedCategoriesChips()
            ]));
  }

  Consumer<GameModel> _settingsButton(String text) {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      return TextButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: const BorderSide(color: defaultColor))),
            backgroundColor: MaterialStateProperty.all<Color>(lightBlueColor)),
        onPressed: () {
          switch (text) {
            case 'CHAT':
              constSnackBar('Coming soon', context);
              break;
            case 'PIN CODE':
              Clipboard.setData(ClipboardData(text: gameModel.pinCode));
              constSnackBar(
                  'Copied ${gameModel.pinCode} to clipboard', context);
              break;
            case 'INVITE':
              constSnackBar('Coming soon', context);
              break;
            case 'UNLOCKED':
            case 'LOCKED':
              constSnackBar('Only the admin can set lock', context);
              break;
          }
        },
        child: Text(text),
      );
    });
  }

  Row _gameSettings() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _settingsButton('CHAT'),
      _settingsButton('PIN CODE'),
      _settingsButton('INVITE'),
      _settingsButton(lockText)
    ]);
  }

  Consumer<GameModel> _lobbyTitle() {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      String privacy = 'Public';
      final gameModel = Provider.of<GameModel>(context, listen: false);
      if (gameModel.isPrivate) {
        privacy = 'Private';
      }
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          color: lightBlueColor,
          child: Column(
            children: [
              Text(
                '$privacy Game (${gameModel.getNumOfPlayers()}/$maxPlayers Players)',
                style: const TextStyle(
                    fontSize: 18,
                    color: defaultColor,
                    fontWeight: FontWeight.w500),
              )
            ],
          ));
    });
  }

  Consumer<GameModel> _participant(String username, bool admin) {
    bool matchUsernames = false;

    return Consumer<GameModel>(builder: (context, gameModel, child) {
      int playerIndex = gameModel.getPlayerIndexByUsername(username);
      return Consumer<LoginModel>(builder: (context, loginModel, child) {
        if (username == loginModel.username) {
          matchUsernames = true;
        }

        void _toggleIsReady() {
          bool currentReady = gameModel.players[playerIndex]["is_ready"];
          currentReady = !currentReady;
          gameModel.setDataToPlayer("is_ready", currentReady, playerIndex);
          FirebaseFirestore.instance
              .collection('$strVersion/custom_games')
              .doc(gameModel.pinCode)
              .update({"player$playerIndex": gameModel.players[playerIndex]});
        }

        Future<NetworkImage?> _getUserImage() async {
          String userId = '';
          await FirebaseFirestore.instance
              .collection('$strVersion/users')
              .get()
              .then((users) {
            for (var user in users.docs) {
              if (user["username"] == username) {
                userId = user.id;
              }
            }
          });
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: _getAvatarImage(),
              title: Text(
                username,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: greenColor,
                        value: gameModel.players[playerIndex]["is_ready"],
                        onChanged: matchUsernames
                            ? (value) {
                                _toggleIsReady();
                              }
                            : null),
                    const Text("Ready")
                  ])
                ],
              ),
            ));
      });
    });
  }

  Consumer<GameModel> _participants() {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      if (gameModel.getNumOfPlayers() > 0) {
        final participantsList = [
          _participant(gameModel.players[0]["username"], true)
        ];
        for (int i = 1; i < gameModel.getNumOfPlayers(); i++) {
          participantsList
              .add(_participant(gameModel.players[i]["username"], false));
        }
        return ListView(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: participantsList);
      } else {
        return ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: const [ListTile()],
        );
      }
    });
  }

  Card _gameLobby() {
    return Card(
      color: secondaryColor,
      elevation: 2,
      child: Column(
        children: [_lobbyTitle(), _gameSettings(), _participants()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    final loginModel = Provider.of<LoginModel>(context, listen: false);

    void _dialogGameClosed() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Game Closed"),
              content: const Text("The admin closed the game"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CLOSE"),
                ),
              ],
            );
          });
    }

    void _dialogKickedByAdmin() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Game Closed"),
              content:
                  const Text("You have been kicked by the admin from the game"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CLOSE"),
                ),
              ],
            );
          });
    }

    Future<bool> _exitDialog() async {
      final gameModel = Provider.of<GameModel>(context, listen: false);
      return (await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Close Game"),
                  content: const Text("Are you sure you wish to exit from "
                      "this game?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () async {
                          Map<String, dynamic> emptyPlayer = {
                            "username": "",
                            "is_ready": false,
                            "false_answer": "",
                            "selected_answer": ""
                          };
                          int myIndex = gameModel.playerIndex;
                          var games = FirebaseFirestore.instance
                              .collection('$strVersion/custom_games');
                          await games
                              .doc(gameModel.pinCode)
                              .update({"player$myIndex": emptyPlayer});
                          gameModel.resetData();
                          Navigator.of(context).pop(true);
                          Navigator.of(context).pop(true);
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("YES")),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("NO"),
                    ),
                  ],
                );
              })) ??
          false;
    }

    return WillPopScope(
        child: Scaffold(
            appBar: LobbyAppBar(_exitDialog),
            body: SingleChildScrollView(
                child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('$strVersion/custom_games')
                        .doc(gameModel.pinCode)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var game = snapshot.data!;
                        if (!game.exists) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => Navigator.of(context).pop(),
                          );
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _dialogGameClosed(),
                          );
                        } else {
                          gameModel.update(snapshot.data!);
                          if (game["is_locked"]) {
                            lockText = 'LOCKED';
                          } else {
                            lockText = 'UNLOCKED';
                          }
                          if (!gameModel
                              .doesUsernameExist(loginModel.username)) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => Navigator.of(context).pop(),
                            );
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _dialogKickedByAdmin(),
                            );
                          }
                          final questions =
                              List<String>.from(game["questions"]);
                          if (questions.isNotEmpty) {
                            int participantIndex = gameModel
                                .getPlayerIndexByUsername(loginModel.username);
                            gameModel.playerIndex = participantIndex;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FirstGameScreen()));
                            });
                          }
                        }
                      }
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(children: [
                            _selectedCategories(),
                            _gameLobby(),
                          ]));
                    }))),
        onWillPop: _exitDialog);
  }
}
