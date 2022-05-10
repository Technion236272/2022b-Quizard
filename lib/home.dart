import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizard/profile.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'auth_model.dart';
import 'colors.dart';
import 'login_model.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                InkWell(
                  child: Icon(
                    Icons.language,
                    color: defaultColor,
                    size: 32.0,
                  ),
                  onTap: null, // TODO: Go to Change Language screen
                ),
                InkWell(
                  child: Icon(
                    Icons.info_outline,
                    color: defaultColor,
                    size: 32.0,
                  ),
                  onTap: null, // TODO: Go to Rules screen
                )
              ],
            )));
  }

  @override
  Size get preferredSize => const Size(0, 56);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*
  * 0 - Profile
  * 1 - Play
  * 2 - Leaderboard
  */
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Hide navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);

    void _onOptionTapped(int index) {
      setState(() {
        final previousIndex = _selectedIndex;
        final currentIndex = index;

        // Tapped on Profile from anywhere
        if (currentIndex == 0) {
          loginModel.profileSheetController
              .snapToPosition(const SnappingPosition.factor(
            positionFactor: 1, // Sheet goes all the way up to AppBar
            grabbingContentOffset: GrabbingContentOffset.bottom,
          ));
        }

        // Left Profile to somewhere else
        if (currentIndex != 0 && previousIndex == 0) {
          loginModel.profileSheetController
              .snapToPosition(const SnappingPosition.pixels(
            positionPixels: -100,
            grabbingContentOffset: GrabbingContentOffset.top,
          ));
        }

        _selectedIndex = index;
      });
    }

    return Scaffold(
        appBar: const CustomAppBar(),
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
          currentIndex: _selectedIndex,
          backgroundColor: defaultColor,
          selectedItemColor: backgroundColor,
          unselectedItemColor: secondaryColor,
          onTap: _onOptionTapped,
        ),
        body: ProfileSnappingSheet());
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);

    InkWell _playOptionButton(String imgPath) {
      return InkWell(
        splashColor: defaultColor,
        onTap: () {}, // TODO: Support games!
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

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Image(image: AssetImage('images/titles/quizard.png')),
            Text(
              'Welcome, ${loginModel.emailController.text}!',
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
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: secondaryColor,
                      minimumSize: const Size.fromHeight(50)), // max width
                  child: const Text('Log out',
                      style: TextStyle(color: defaultColor)),
                  onPressed: () {
                    AuthModel.instance().signOut().then((value) {
                      loginModel.logOut();
                      // Hide StatusBar, Show navigation buttons
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                          overlays: [SystemUiOverlay.bottom]);
                      Navigator.of(context).pop();
                    });
                  },
                )),
            Container()
          ]),
    );
  }
}
