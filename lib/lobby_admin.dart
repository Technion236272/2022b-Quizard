import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final list = ['a', 'aa', 'aaa', 'ab', 'bbb'];

  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Show navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  ChipsInput _selectCategoryInput() {
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
          final results = list.where((category) {
            return category.toLowerCase().startsWith(lowercaseQuery);
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
        return InputChip(
          backgroundColor: secondaryColor,
          label: Text(category.toString()),
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
                  final option = categories.elementAt(index).toString();
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      key: ObjectKey(option),
                      title: Text(option),
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
