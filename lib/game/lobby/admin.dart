import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chips_input/chips_input.dart';
import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../first_screen.dart';
import 'appbar.dart';
import '../../localization/classes/language_constants.dart';
import '../../providers.dart';
import '../../consts.dart';

class LobbyAdmin extends StatefulWidget {
  const LobbyAdmin({Key? key, required this.isPrivate}) : super(key: key);

  final bool isPrivate;

  @override
  State<LobbyAdmin> createState() => _LobbyAdminState();
}

class _LobbyAdminState extends State<LobbyAdmin> {
  bool finishedBuildAllCustomCategories = false;
  String lockText = 'UNLOCKED';

  List<String> officialCategories = [
    'Animal',
    'Geography',
    'History',
    'Movies',
    'Music',
    'Politics',
    'Sports',
    'Technology'
  ];

  // pattern: ['category', 'username', questions_num]
  // all categories are loaded ONCE
  var customCategories = [
    ['', '', 0]
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  ChipsInput _selectCategoryInput() {
    // Get all categories by all users ONCE
    if (!finishedBuildAllCustomCategories) {
      FirebaseFirestore.instance
          .collection('$firestoreMainPath/users')
          .get()
          .then((users) {
        for (var user in users.docs) {
          final categories = user["categories"].toSet().toList();
          for (int i = 0; i < categories.length; i++) {
            final filteredListByItem =
                user["categories"].where((cat) => cat == categories[i]);
            customCategories.add(
                [categories[i], user["username"], filteredListByItem.length]);
          }
        }
      });
      finishedBuildAllCustomCategories = true;
    }

    return ChipsInput(
      initialValue: const [],
      decoration: InputDecoration(
          filled: true,
          fillColor: secondaryColor,
          hintText: translation(context).typeHere,
          hintStyle: const TextStyle(color: thirdColor)),
      maxChips: 5,
      findSuggestions: (String query) {
        if (query.isNotEmpty) {
          var lowercaseQuery = query.toLowerCase();
          final results = customCategories.where((cat) {
            return cat[0].toString().toLowerCase().startsWith(lowercaseQuery);
          }).toList(growable: false);
          results.toSet().toList();
          return results;
        } else {
          return [];
        }
      },
      onChanged: (data) {
        List<String> selectedCustomCategories = [];
        for (int i = 0; i < data.length; i++) {
          var dataToList = data[i]
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(', ');
          List<String> parsedCategory = []; // [category, author]
          parsedCategory.add(dataToList[0]);
          parsedCategory.add(dataToList[1]);
          String selectedCategory = '${dataToList[0]} (${dataToList[1]})';
          selectedCustomCategories.add(selectedCategory);
        }
        final gameModel = Provider.of<GameModel>(context, listen: false);
        gameModel.customCategories = selectedCustomCategories;
        FirebaseFirestore.instance
            .collection('$firestoreMainPath/${gameModel.gamePath}')
            .doc(gameModel.pinCode)
            .update({"custom_categories": selectedCustomCategories});
      },
      chipBuilder: (context, state, category) {
        final option = category as List;
        final optionText = "${option[0]} (${option[1]})";
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: InputChip(
              shape: const StadiumBorder(side: BorderSide(color: defaultColor)),
              labelStyle: const TextStyle(fontSize: 16),
              backgroundColor: lightBlueColor,
              label: Text(optionText),
              onDeleted: () => state.deleteChip(category),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ));
      },
      optionsViewBuilder: (context, onSelected, categories) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = categories.elementAt(index) as List;
                  String optionText;
                  if (option[2] == 1) {
                    optionText =
                        "${option[0]}, by ${option[1]}, ${option[2]} question";
                  } else {
                    optionText =
                        "${option[0]}, by ${option[1]}, ${option[2]} questions";
                  }
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      key: ObjectKey(option),
                      title: Text(optionText),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
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

  Consumer<GameModel> _officialCategoriesChips() {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      return Flexible(
          fit: FlexFit.loose,
          child: ChipsChoice<String>.multiple(
            value: gameModel.officialCategories,
            onChanged: (val) {
              gameModel.officialCategories = val;
              FirebaseFirestore.instance
                  .collection('$firestoreMainPath/${gameModel.gamePath}')
                  .doc(gameModel.pinCode)
                  .update({"official_categories": val});
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: officialCategories,
              value: (i, v) => v,
              label: (i, v) => v,
              tooltip: (i, v) => v,
            ),
            choiceActiveStyle: const C2ChoiceStyle(
                color: defaultColor,
                borderColor: defaultColor,
                backgroundColor: lightBlueColor),
            //wrapped: true,
            textDirection: TextDirection.ltr,
            choiceStyle: const C2ChoiceStyle(
              color: defaultColor,
              borderColor: defaultColor,
            ),
          ));
    });
  }

  Card _officialCategories() {
    return Card(
        elevation: 2,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _categoriesTitle(translation(context).officialCategory,
                  translation(context).message2),
              _officialCategoriesChips()
            ]));
  }

  Card _customCategories() {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _categoriesTitle(translation(context).customCategory,
              translation(context).message1),
          _selectCategoryInput(),
        ],
      ),
    );
  }

  Consumer<GameModel> _settingsButton(String text) {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      return FittedBox(
          child: TextButton(
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
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                    content: Text('Copied ${gameModel.pinCode} to clipboard'),
                    duration: const Duration(days: 365),
                    action: SnackBarAction(
                      label: translation(context).dismiss,
                      onPressed: () {},
                    ),
                  ))
                  .closed
                  .then((value) =>
                      ScaffoldMessenger.of(context).clearSnackBars());
              break;
            case 'INVITE':
              constSnackBar('Coming soon', context);
              break;
            case 'UNLOCKED':
              lockText = 'LOCKED';
              FirebaseFirestore.instance
                  .collection('$firestoreMainPath/${gameModel.gamePath}')
                  .doc(gameModel.pinCode)
                  .update({"is_locked": true});
              gameModel.isLocked = true;
              break;
            case 'LOCKED':
              lockText = 'UNLOCKED';
              FirebaseFirestore.instance
                  .collection('$firestoreMainPath/${gameModel.gamePath}')
                  .doc(gameModel.pinCode)
                  .update({"is_locked": false});
              gameModel.isLocked = false;
              break;
          }
        },
        child: Text(getLocalizedFieldValue(text, context)),
      ));
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
      if (widget.isPrivate) {
        privacy = 'Private';
      }
      int numOfPlayers = gameModel.getNumOfPlayers();
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          color: lightBlueColor,
          child: Column(
            children: [
              Text(
                '$privacy Game ($numOfPlayers/$maxPlayers Players)',
                style: const TextStyle(
                    fontSize: 18,
                    color: defaultColor,
                    fontWeight: FontWeight.w500),
              )
            ],
          ));
    });
  }

  Consumer<GameModel> _kickIcon(String username) {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      return GestureDetector(
          child: const Icon(Icons.block, color: redColor, size: 34),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(translation(context).kickPlayer),
                    content:
                        Text(translation(context).wishToKick + "$username?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () async {
                            int i = gameModel.removeByUsername(username);
                            var game = FirebaseFirestore.instance
                                .collection(
                                    '$firestoreMainPath/${gameModel.gamePath}')
                                .doc(gameModel.pinCode);
                            await game.update({
                              "player$i": gameModel.players[i],
                            });
                            Navigator.of(context).pop(true);
                          },
                          child: Text(translation(context).kick)),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(translation(context).cancel),
                      ),
                    ],
                  );
                });
          });
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
              .collection('$firestoreMainPath/${gameModel.gamePath}')
              .doc(gameModel.pinCode)
              .update({"player$playerIndex": gameModel.players[playerIndex]});
        }

        Future<NetworkImage?> _getUserImage() async {
          String userId = '';
          await FirebaseFirestore.instance
              .collection('$firestoreMainPath/users')
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
                  admin ? const Icon(null) : _kickIcon(username),
                  Row(children: [
                    Transform.scale(
                        scale: 1.5,
                        child: Checkbox(
                            splashRadius: 20,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: greenColor,
                            value: gameModel.players[playerIndex]["is_ready"],
                            onChanged: matchUsernames
                                ? (value) {
                                    _toggleIsReady();
                                  }
                                : null)),
                    Text(translation(context).ready)
                  ])
                ],
              ),
            ));
      });
    });
  }

  Consumer<GameModel> _participants() {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      final participantsList = [
        _participant(gameModel.players[0]["username"], true)
      ];
      for (int i = 1; i < maxPlayers; i++) {
        String currUsername = gameModel.players[i]["username"];
        if (currUsername != "") {
          participantsList
              .add(_participant(gameModel.players[i]["username"], false));
        }
      }
      return ListView(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: participantsList);
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

  Consumer<GameModel> _startGameButton() {
    Future<bool> _buildQuestions() async {
      final allQuestions = [];
      final allAnswers = [];
      final allCategories = [];
      GameModel gameModel = Provider.of<GameModel>(context, listen: false);
      var users =
          FirebaseFirestore.instance.collection('$firestoreMainPath/users');
      var officialQuestions = FirebaseFirestore.instance
          .collection('versions/v1/official_questions');
      for (int i = 0; i < gameModel.selectedCategories.length; i++) {
        final selectedCategory = gameModel.selectedCategories[i];
        if (officialCategories.contains(selectedCategory)) {
          await officialQuestions.doc(selectedCategory).get().then((category) {
            allQuestions.addAll(category["questions"]);
            allAnswers.addAll(category["answers"]);
            for (int j = 0; j < allQuestions.length; j++) {
              allCategories.add(selectedCategory);
            }
          });
        } else {
          final username = selectedCategory.split('(').last.split(')').first;
          final category = selectedCategory.split(' (').first;
          String userId = '';

          await users.get().then((allUsers) {
            for (var user in allUsers.docs) {
              if (user["username"] == username) {
                userId = user.id;
              }
            }
          });

          if (userId != '') {
            await users.doc(userId).get().then((user) {
              final userQuestions = user["questions"];
              final userAnswers = user["answers"];
              final userCategories = user["categories"];
              for (int i = 0; i < userCategories.length; i++) {
                if (userCategories[i].toString() == category) {
                  allQuestions.add(userQuestions[i].toString());
                  allAnswers.add(userAnswers[i].toString());
                  allCategories.add(selectedCategory);
                }
              }
            });
          }
        }
      }

      if (allQuestions.length < roundsPerGame) {
        return false;
      }

      final selectedQuestions = [];
      final selectedAnswers = [];
      final selectedCategories = [];
      List shuffledIndexes = List.generate(allQuestions.length, (i) => i);
      shuffledIndexes.shuffle();
      for (int i = 0; i < roundsPerGame; i++) {
        selectedQuestions.add(allQuestions[shuffledIndexes[i]]);
        selectedAnswers.add(allAnswers[shuffledIndexes[i]]);
        selectedCategories.add(allCategories[shuffledIndexes[i]]);
      }

      final falseAnswers = [];
      final selectedAnswersPerRound = [];
      for (int i = 0; i < gameModel.getNumOfPlayers(); i++) {
        falseAnswers.add('');
        selectedAnswersPerRound.add('');
      }

      await FirebaseFirestore.instance
          .collection('$firestoreMainPath/${gameModel.gamePath}')
          .doc(gameModel.pinCode)
          .update({
        "questions": selectedQuestions,
        "answers": selectedAnswers,
        "categories": selectedCategories,
      });

      gameModel.gameQuestions = List<String>.from(selectedQuestions);
      gameModel.gameAnswers = List<String>.from(selectedAnswers);
      gameModel.gameCategories = List<String>.from(selectedCategories);

      return true;
    }

    Future<void> _startGame() async {
      GameModel gameModel = Provider.of<GameModel>(context, listen: false);
      LoginModel loginModel = Provider.of<LoginModel>(context, listen: false);
      int playerIndex = gameModel.getPlayerIndexByUsername(loginModel.username);
      gameModel.playerIndex = playerIndex;
      bool retVal = await _buildQuestions();
      if (!retVal) {
        constSnackBar(translation(context).snackBar6, context);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        await FirebaseFirestore.instance
            .collection('$firestoreMainPath/${gameModel.gamePath}')
            .doc(gameModel.pinCode)
            .update({"is_locked": true});
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (context) => const FirstGameScreen()));
      }
    }

    return Consumer<GameModel>(
      builder: (context, gameModel, child) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: defaultColor,
                    minimumSize: const Size.fromHeight(50)), // max width
                child: Text(translation(context).startGame,
                    style: const TextStyle(fontSize: 18)),
                // TODO: Make sure that there are at least 2 players
                onPressed: gameModel.areAllReady() ? _startGame : null));
      },
    );
  }

  Future<bool> _exitDialog() async {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    return (await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(translation(context).closeGame),
                content: Text(translation(context).closingAlert),
                actions: <Widget>[
                  TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection(
                                '$firestoreMainPath/${gameModel.gamePath}')
                            .doc(gameModel.pinCode)
                            .delete();
                        Navigator.of(context).pop(true);
                        Navigator.of(context).pop(true);
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                            overlays: []);
                      },
                      child: Text(translation(context).yes)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(translation(context).no),
                  ),
                ],
              );
            })) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);
    return WillPopScope(
        child: Scaffold(
            appBar: LobbyAppBar(_exitDialog),
            body: SingleChildScrollView(
                child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('$firestoreMainPath/${gameModel.gamePath}')
                        .doc(gameModel.pinCode)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var game = snapshot.data!;
                        if (game.exists) {
                          gameModel.update(snapshot.data!);
                        }
                      }
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(children: [
                            _officialCategories(),
                            _customCategories(),
                            _gameLobby(),
                            _startGameButton()
                          ]));
                    }))),
        onWillPop: _exitDialog);
  }
}
