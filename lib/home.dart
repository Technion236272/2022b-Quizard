import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizard/join_game.dart';
import 'package:random_string/random_string.dart';

import 'lobby_admin.dart';
import 'profile.dart';
import 'consts.dart';
import 'providers.dart';

class QuizardAppBar extends StatelessWidget with PreferredSizeWidget {
  QuizardAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: backgroundColor,
            child: Padding(
                padding: const EdgeInsets.all(appbarPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    InkWell(
                      child: Icon(
                        Icons.language,
                        color: defaultColor,
                        size: appbarIconSize,
                      ),
                      onTap: null, // TODO: Go to Change Language screen
                    ),
                    InkWell(
                      child: Icon(
                        Icons.info_outline,
                        color: defaultColor,
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  final profileScreen = Profile();

  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Hide navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    void _onOptionTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }

    Widget _chooseWidget() {
      if (_currentIndex == 1) {
        return const Play();
      }
      if (_currentIndex == 2) {
        return const Leaderboard();
      }
      return profileScreen;
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: QuizardAppBar(),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.gamepad),
                label: 'Play',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.crown),
                label: 'Leaderboard',
              ),
            ],
            currentIndex: _currentIndex,
            backgroundColor: defaultColor,
            selectedItemColor: backgroundColor,
            unselectedItemColor: secondaryColor,
            onTap: _onOptionTapped,
          ),
          body: _chooseWidget());
    });
  }
}

class Play extends StatelessWidget {
  const Play({Key? key}) : super(key: key);

  Future<void> _initializeGame(
      GameModel gameModel, LoginModel loginModel) async {
    gameModel.admin = loginModel.username;
    gameModel.addParticipant(loginModel.username);
    gameModel.pinCode = randomAlphaNumeric(6).toUpperCase();
    var games =
        FirebaseFirestore.instance.collection('versions/v1/custom_games');
    final game = <String, dynamic>{
      "admin": gameModel.admin,
      "participants": gameModel.participants,
      "pin_code": gameModel.pinCode,
      "is_private": gameModel.isPrivate,
      "is_locked": gameModel.isLocked,
      "are_ready": gameModel.areReady,
      "official_categories": gameModel.officialCategories,
      "custom_categories": gameModel.customCategories,
      "questions": [],
      "answers": []
    };
    await games.doc(gameModel.pinCode).set(game);
  }

  @override
  Widget build(BuildContext context) {
    InkWell _playOptionButton(String imgPath) {
      return InkWell(
        splashColor: defaultColor,
        onTap: () {
          // TODO: Support all games!
          final gameModel = Provider.of<GameModel>(context, listen: false);
          final loginModel = Provider.of<LoginModel>(context, listen: false);
          if (imgPath.contains('create_private')) {
            gameModel.resetData();
            gameModel.isPrivate = true;
            _initializeGame(gameModel, loginModel);
            Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) => const LobbyAdmin()));
          }
          if (imgPath.contains('join_existing')) {
            Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (context) => JoinGame()));
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(7),
            child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: playOptionColor,
                  boxShadow: const [
                    BoxShadow(color: defaultColor, spreadRadius: 2),
                  ],
                ),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image(image: AssetImage(imgPath))))),
      );
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Image(image: AssetImage('images/titles/quizard.png')),
              Text(
                'Good luck, ${loginModel.username}!',
                style: const TextStyle(fontSize: 18),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playOptionButton('images/titles/quick_play.png'),
                      _playOptionButton('images/titles/create_public.png'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playOptionButton('images/titles/join_existing.png'),
                      _playOptionButton('images/titles/create_private.png'),
                    ],
                  ),
                ],
              ),
              Container()
            ]),
      );
    });
  }
}

class Leaderboard extends StatelessWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 114;

    return Container(
        color: secondaryBackgroundColor,
        height: screenHeight,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              child: const Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(
                      child: Text(
                    "Coming soon.",
                    style: TextStyle(fontSize: 24, color: defaultColor),
                  ))),
              decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(boxRadiusConst))))
        ]));
  }
}
