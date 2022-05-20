import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chips_input/chips_input.dart';

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
  var categoriesList = [
    ['', '', 0]
  ];

  @override
  void initState() {
    super.initState();
  }

  ChipsInput _selectCategoryInput() {
    FirebaseFirestore.instance.collection('users').get().then((users) {
      for (var user in users.docs) {
        final categories = user["categories"].toSet().toList();
        for (int i = 0; i < categories.length; i++) {
          final filteredListByItem =
              user["categories"].where((cat) => cat == categories[i]);
          //String category = "${categories[i]}" " (${user["username"]})";
          categoriesList.add(
              [categories[i], user["username"], filteredListByItem.length]);
        }
      }
    });

    return ChipsInput(
      initialValue: const [],
      decoration: const InputDecoration(
        filled: true,
        fillColor: playOptionColor,
        labelText: "Select Custom Categories",
      ),
      maxChips: 5,
      findSuggestions: (String query) {
        if (query.isNotEmpty) {
          var lowercaseQuery = query.toLowerCase();
          final results = categoriesList.where((cat) {
            return cat[0].toString().toLowerCase().startsWith(lowercaseQuery);
          }).toList(growable: false);
          return results;
        } else {
          return [];
        }
      },
      onChanged: (data) {
        print(data);
      },
      chipBuilder: (context, state, category) {
        final option = category as List;
        final optionText = "${option[0]} (${option[1]})";
        return InputChip(
          backgroundColor: secondaryColor,
          label: Text(optionText),
          onDeleted: () => state.deleteChip(category),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: LobbyAppBar(),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              _selectCategoryInput(),
            ])));
  }
}
