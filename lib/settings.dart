import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'consts.dart';
import 'providers.dart';

class ChangeEmailForm extends StatelessWidget {
  ChangeEmailForm({Key? key}) : super(key: key);

  final _textController = TextEditingController();

  Future<bool> resetEmail(
      String oldEmail, String newEmail, String password) async {
    var message = false;
    await AuthModel.instance()
        .signIn(oldEmail, password)
        .then((value) async => {
              await FirebaseAuth.instance.currentUser!
                  .updateEmail(newEmail)
                  .then(
                    (value) => message = true,
                  )
                  .catchError((onError) => print(onError))
            });
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      _textController.text = loginModel.email;

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
                hintText: 'Username',
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                child: ElevatedButton(
                  onPressed: () {
                    resetEmail(loginModel.email, _textController.text,
                            loginModel.password)
                        .then((value) {
                      if (value == true) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(loginModel.userId)
                            .update({
                          "email": _textController.text,
                        }).then((_) {
                          loginModel.setEmail(_textController.text);
                          Navigator.of(context).pop(true);
                        });
                      }
                    });
                  },
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

class ChangeUsernameForm extends StatelessWidget {
  ChangeUsernameForm({Key? key}) : super(key: key);

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      _textController.text = loginModel.username;

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
                hintText: 'Username',
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(loginModel.userId)
                        .update({
                      "username": _textController.text,
                    }).then((_) {
                      loginModel.setUsername(_textController.text);
                      Navigator.of(context).pop(true);
                    });
                  },
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
                break;
              case _changeUsernameText:
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: const Text(_changeUsernameText),
                          content: ChangeUsernameForm());
                    });
                break;
              case _changeEmailText:
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: const Text(_changeEmailText),
                          content: ChangeEmailForm());
                    });
                break;
              case _changePasswordText:
                break;
              case _logOutText:
                final loginModel =
                    Provider.of<LoginModel>(context, listen: false);
                AuthModel.instance().signOut().then((value) {
                  loginModel.logOut();
                  // Hide StatusBar, Show navigation buttons
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                      overlays: [SystemUiOverlay.bottom]);
                  Navigator.of(context).pop();
                });
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: secondaryBackgroundColor,
        body: SingleChildScrollView(
            child: Padding(
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
                    ]))));
  }
}
