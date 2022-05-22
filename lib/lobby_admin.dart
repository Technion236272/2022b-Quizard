import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chips_input/chips_input.dart';
import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:provider/provider.dart';

import 'providers.dart';
import 'consts.dart';

class LobbyAppBar extends StatelessWidget with PreferredSizeWidget {
  LobbyAppBar({Key? key}) : super(key: key);

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

class LobbyAdmin extends StatefulWidget {
  const LobbyAdmin({Key? key}) : super(key: key);

  @override
  State<LobbyAdmin> createState() => _LobbyAdminState();
}

class _LobbyAdminState extends State<LobbyAdmin> {
  List<String> selectedOfficialCategories = [];
  var selectedCustomCategories = [];
  bool finishedBuildAllCustomCategories = false;
  String lockText = '';

  List<String> officialCategories = [
    'Art',
    'Sports',
    'Politics',
    'Movies',
    'Music',
    'World',
    'Geography',
    'History',
    'Business',
    'Technology',
  ];

  var customCategories = [
    ['', '', 0]
  ];

  @override
  void initState() {
    super.initState();
    lockText = 'UNLOCKED';
  }

  ChipsInput _selectCategoryInput() {
    // Get all categories by all users once
    if (!finishedBuildAllCustomCategories) {
      FirebaseFirestore.instance.collection('users').get().then((users) {
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
      decoration: const InputDecoration(
          filled: true,
          fillColor: secondaryColor,
          hintText: "Type here...",
          hintStyle: TextStyle(color: thirdColor)),
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
        selectedCustomCategories = data;
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

  Flexible _officialCategoriesChips() {
    return Flexible(
        fit: FlexFit.loose,
        child: ChipsChoice<String>.multiple(
          value: selectedOfficialCategories,
          onChanged: (val) => setState(() => selectedOfficialCategories = val),
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
  }

  Card _officialCategories() {
    return Card(
        elevation: 2,
        //margin: const EdgeInsets.all(5),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _categoriesTitle(
                  'Official Categories', 'Scroll right for more categories'),
              _officialCategoriesChips()
            ]));
  }

  Card _customCategories() {
    return Card(
      elevation: 2,
      //margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _categoriesTitle(
              'Custom Categories', 'Type and search any categories by users'),
          _selectCategoryInput(),
        ],
      ),
    );
  }

  TextButton _settingsButton(String text) {
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
            constSnackBar('Copied to clipboard', context);
            break;
          case 'INVITE':
            constSnackBar('Coming soon', context);
            break;
          case 'UNLOCKED':
            setState(() {
              lockText = 'LOCKED';
            });

            break;
          case 'LOCKED':
            setState(() {
              lockText = 'UNLOCKED';
            });
            break;
        }
      },
      child: Text(text),
    );
  }

  Row _gameSettings() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _settingsButton('CHAT'),
      _settingsButton('PIN CODE'),
      _settingsButton('INVITE'),
      _settingsButton(lockText)
    ]);
  }

  Container _lobbyTitle(int numberOfParticipants) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        color: lightBlueColor,
        child: Column(
          children: [
            Text(
              'Private Game ($numberOfParticipants/5 Players)',
              style: const TextStyle(
                  fontSize: 18,
                  color: defaultColor,
                  fontWeight: FontWeight.w500),
            )
          ],
        ));
  }

  GestureDetector _kickIcon(String username) {
    return GestureDetector(
        child: const Icon(Icons.block, color: redColor),
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Kick Player"),
                  content: Text("Are you sure you wish to kick $username?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () async {}, child: const Text("KICK")),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("CANCEL"),
                    ),
                  ],
                );
              });
        });
  }

  Consumer<GameModel> _participant(String username, bool admin) {
    bool? isReady = false; // TODO: Change to find state of isReady of others
    bool matchUsernames = false;

    return Consumer<GameModel>(builder: (context, gameModel, child) {
      final loginModel = Provider.of<LoginModel>(context, listen: false);

      if (username == loginModel.username) {
        matchUsernames = true;
      }

      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
                backgroundImage: loginModel.getUserImage(),
                backgroundColor: thirdColor,
                radius: 25),
            title: Text(
              username,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                admin ? const Icon(null) : _kickIcon(username),
                Transform.translate(
                    offset: const Offset(8, 0),
                    child: Checkbox(
                        activeColor: greenColor,
                        value: matchUsernames ? gameModel.isReady : isReady,
                        onChanged: matchUsernames
                            ? (value) => gameModel.toggleIsReady()
                            : null)),
                const Text("Ready")
              ],
            ),
          ));
    });
  }

  ListView _participants() {
    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          _participant('razash', true),
          _participant('maysam', false),
          _participant('ramzi10', false)
        ]);
  }

  Card _gameLobby() {
    int numberOfParticipants = 3; //TODO: Get value from GameModel
    return Card(
      color: secondaryColor,
      elevation: 2,
      child: Column(
        children: [
          _lobbyTitle(numberOfParticipants),
          _gameSettings(),
          _participants()
        ],
      ),
    );
  }

  Padding _startGameButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: secondaryColor,
              minimumSize: const Size.fromHeight(50)), // max width
          child: const Text('Start Game',
              style: TextStyle(color: defaultColor, fontSize: 18)),
          onPressed: () {},
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: LobbyAppBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(children: [
                  _officialCategories(),
                  _customCategories(),
                  _gameLobby(),
                  _startGameButton()
                ]))));
  }
}
