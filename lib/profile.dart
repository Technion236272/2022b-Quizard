import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'consts.dart';
import 'providers.dart';
import 'questions.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  void _onPressedChangeAvatar(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
  }

  void _onPressedChangeEmail(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
  }

  void _onPressedChangeUsername(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
  }

  void _onPressedChangePassword(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
  }

  void _onPressedLogOut(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);
    AuthModel.instance().signOut().then((value) {
      loginModel.logOut();
      // Hide StatusBar, Show navigation buttons
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
      Navigator.of(context).pop();
    });
  }

  Padding _settingsButton(String buttonText, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: secondaryColor,
              minimumSize: const Size.fromHeight(50)), // max width
          child: Text(buttonText, style: const TextStyle(color: defaultColor)),
          onPressed: () {
            switch (buttonText) {
              case 'Change Avatar':
                _onPressedChangeAvatar(context);
                break;
              case 'Change Username':
                _onPressedChangeUsername(context);
                break;
              case 'Change Email':
                _onPressedChangeEmail(context);
                break;
              case 'Change Password':
                _onPressedChangePassword(context);
                break;
              case 'Log Out':
                _onPressedLogOut(context);
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                _settingsButton('Change Avatar', context),
                _settingsButton('Change Username', context),
                _settingsButton('Change Email', context),
                _settingsButton('Change Password', context),
              ]),
              _settingsButton('Log Out', context),
            ]));
  }
}

//ignore: must_be_immutable
class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  int _lastTab = 0;

  void _onTapTab(int index) {
    _lastTab = index;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          body: Container(
              decoration: const BoxDecoration(
                color: secondaryColor,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(boxRadiusConst)),
              ),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                      child: CircleAvatar(
                          backgroundImage: loginModel.getUserImage(),
                          backgroundColor: thirdColor,
                          radius: 35)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                        child: Text(
                          loginModel.username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 26,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Text(
                          loginModel.email,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  )
                ]),
                Expanded(
                    child: DefaultTabController(
                  initialIndex: _lastTab,
                  length: 3,
                  child: Scaffold(
                    backgroundColor: secondaryColor,
                    appBar: AppBar(
                      backgroundColor: thirdColor,
                      automaticallyImplyLeading: false,
                      toolbarHeight: 0,
                      elevation: 0,
                      bottom: TabBar(
                        onTap: _onTapTab,
                        labelColor: defaultColor,
                        indicatorColor: defaultColor,
                        tabs: const [
                          Tab(
                              icon: Icon(Icons.question_mark),
                              text: "QUESTIONS"),
                          Tab(
                            icon: Icon(Icons.tag_faces),
                            text: "FRIENDS",
                          ),
                          Tab(
                            icon: Icon(Icons.settings),
                            text: "SETTINGS",
                          ),
                        ],
                      ),
                    ),
                    body: TabBarView(
                      children: [
                        Container(
                            color: secondaryBackgroundColor,
                            child: const Questions()),
                        Container(
                            color: secondaryBackgroundColor,
                            child: const Center(
                                child: Text(
                              "Coming soon.",
                              style: TextStyle(fontSize: 20),
                            ))),
                        Container(
                            color: secondaryBackgroundColor,
                            child: const Settings()),
                      ],
                    ),
                  ),
                ))
              ])));
    });
  }
}
