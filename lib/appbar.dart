import 'package:flutter/material.dart';

import 'consts.dart';

class QuizardAppBar extends StatelessWidget with PreferredSizeWidget {
  QuizardAppBar({Key? key, required this.inverted}) : super(key: key);

  bool inverted = false;

  @override
  Widget build(BuildContext context) {
    Color barColor = backgroundColor;
    Color iconsColor = defaultColor;

    if (inverted) {
      barColor = defaultColor;
      iconsColor = backgroundColor;
    }

    return Scaffold(
        body: Container(
            color: barColor,
            child: Padding(
                padding: const EdgeInsets.all(appbarPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.language,
                        color: iconsColor,
                        size: appbarIconSize,
                      ),
                      onTap: null, // TODO: Go to Change Language screen
                    ),
                    InkWell(
                      child: Icon(
                        Icons.info_outline,
                        color: iconsColor,
                        size: appbarIconSize,
                      ),
                      onTap: null, // TODO: Go to Rules screen
                    )
                  ],
                ))));
  }

  @override
  Size get preferredSize => const Size(0, appbarSize);
}
