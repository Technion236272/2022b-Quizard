import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'consts.dart';
import 'providers.dart';

class ChangeUsernameForm extends StatelessWidget {
  ChangeUsernameForm({Key? key}) : super(key: key);

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Form(
        key: UniqueKey(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _textController,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: 'Change Username',
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                child: ElevatedButton(
                  onPressed: () async {},
                  child: const Text('Submit'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ])
          ],
        ),
      );
    });
  }
}

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  static const _changeAvatarText = 'Change Avatar';
  static const _changeUsernameText = 'Change Username';
  static const _changeEmailText = 'Change Email';
  static const _changePasswordText = 'Change Password';
  static const _logOutText = 'Log Out';

  void _onPressedChangeAvatar(BuildContext context) {
    //final loginModel = Provider.of<LoginModel>(context, listen: false);
  }

  void _onPressedChangeEmail(BuildContext context) {
    //final loginModel = Provider.of<LoginModel>(context, listen: false);
  }

  void _onPressedChangeUsername(BuildContext context) {
    //final loginModel = Provider.of<LoginModel>(context, listen: false);
  }

  void _onPressedChangePassword(BuildContext context) {
    //final loginModel = Provider.of<LoginModel>(context, listen: false);
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
              case _changeAvatarText:
                _onPressedChangeAvatar(context);
                break;
              case _changeUsernameText:
                _onPressedChangeUsername(context);
                break;
              case _changeEmailText:
                _onPressedChangeEmail(context);
                break;
              case _changePasswordText:
                _onPressedChangePassword(context);
                break;
              case _logOutText:
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
                _settingsButton(_changeAvatarText, context),
                _settingsButton(_changeUsernameText, context),
                _settingsButton(_changeEmailText, context),
                _settingsButton(_changePasswordText, context),
              ]),
              _settingsButton(_logOutText, context),
            ]));
  }
}
