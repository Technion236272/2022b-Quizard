import 'package:flutter/material.dart';

// Colors
const backgroundColor = Color.fromRGBO(222, 203, 57, 1);
const defaultColor = Colors.black;
const secondaryColor = Colors.white;
const playOptionColor = Color.fromRGBO(250, 220, 70, 1);
const thirdColor = Color.fromRGBO(191, 216, 235, 1);
const secondaryBackgroundColor = Color.fromRGBO(248, 248, 248, 1);
const redColor = Color.fromRGBO(230, 124, 117, 1);
const greenColor = Color.fromRGBO(124, 220, 117, 1);
const blueColor = Colors.blue;
const orangeColor = Colors.orange;
const lightBlueColor = Color(0xFFECEFF1);

// Numbers
const grabbingHeightConst = 200.0;
const boxRadiusConst = 30.0;
const appbarIconSize = 32.0;
const appbarPadding = 12.0;
const appbarSize = 2 * appbarPadding + appbarIconSize;
const roundsPerGame = 5;
const maxPlayers = 5;
const timePerScreen = 20;

// Strings
const strVersion = "versions/v2";

// SnackBar
void constSnackBar(String text, BuildContext context) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
        content: Text(text),
      ))
      .closed
      .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
}
