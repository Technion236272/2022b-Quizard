import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chips_input/chips_input.dart';
import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';

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
  }

  ChipsInput _selectCategoryInput() {
    // Get all categories by all users
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
    final collectCategories =
        FirebaseFirestore.instance.collection('trivia').get().then((cats) {
      final categories = [];
      for (var cat in cats.docs) {
        categories.add(cat.id);
      }
      return categories;
    });

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
          FutureBuilder(
              future: collectCategories,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return _officialCategoriesChips();
                } else {
                  return const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Loading, please wait...",
                        style: TextStyle(fontSize: 16),
                      ));
                }
              }))
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: LobbyAppBar(),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
                children: [_officialCategories(), _customCategories()])));
  }
}
