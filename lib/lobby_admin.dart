import 'package:flutter/material.dart';

import 'consts.dart';

class LobbyAppBar extends StatelessWidget with PreferredSizeWidget {
  LobbyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: LobbyAppBar());
  }
}
