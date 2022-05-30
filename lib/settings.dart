import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

import 'consts.dart';
import 'providers.dart';

class ChangePasswordForm extends StatelessWidget {
  ChangePasswordForm({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  Future<bool> resetPassword(
      String email, String oldPassword, String newPassword) async {
    var message = false;
    await AuthModel.instance()
        .signIn(email, oldPassword)
        .then((value) async => {
              await FirebaseAuth.instance.currentUser!
                  .updatePassword(newPassword)
                  .then(
                    (value) => message = true,
                  )
            });
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              minLines: 1,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (val) {
                if (val == '') {
                  return 'Passwords can\'t be empty';
                }
                if (val != loginModel.password) {
                  return 'Wrong password';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Current Password',
              ),
            ),
            TextFormField(
              controller: _newPasswordController,
              minLines: 1,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (val) {
                if (val == '') {
                  return 'Password can\'t be empty';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
            ),
            TextFormField(
              controller: _repeatPasswordController,
              minLines: 1,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (val) {
                if (val == '') {
                  return 'Password can\'t be empty';
                }
                if (val != _newPasswordController.text) {
                  return 'Password don\'t match';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Repeat New Password',
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                child: ElevatedButton(
                  onPressed: () {
                    final FormState? form = _formKey.currentState;
                    bool? valid = form?.validate();
                    if (valid != null) {
                      if (valid) {
                        resetPassword(
                                loginModel.email,
                                _oldPasswordController.text,
                                _newPasswordController.text)
                            .then((value) {
                          if (value == true) {
                            loginModel.setPassword(_newPasswordController.text);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                  content:
                                      Text('Changed password successfully'),
                                ))
                                .closed
                                .then((value) => ScaffoldMessenger.of(context)
                                    .clearSnackBars());
                            Navigator.of(context).pop(true);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                  content: Text('Something went wrong'),
                                ))
                                .closed
                                .then((value) => ScaffoldMessenger.of(context)
                                    .clearSnackBars());
                          }
                        });
                      }
                    }
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
                            .collection('versions/v1/users')
                            .doc(loginModel.userId)
                            .update({
                          "email": _textController.text,
                        }).then((_) {
                          loginModel.setEmail(_textController.text);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                content: Text('Changed email successfully'),
                              ))
                              .closed
                              .then((value) => ScaffoldMessenger.of(context)
                                  .clearSnackBars());
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
                        .collection('versions/v1/users')
                        .doc(loginModel.userId)
                        .update({
                      "username": _textController.text,
                    }).then((_) {
                      loginModel.setUsername(_textController.text);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                            content: Text('Changed username successfully'),
                          ))
                          .closed
                          .then((value) =>
                              ScaffoldMessenger.of(context).clearSnackBars());
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

  Padding _settingsButton(String buttonText, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: thirdColor,
              minimumSize: const Size.fromHeight(50)), // max width
          child: Text(buttonText, style: const TextStyle(color: defaultColor)),
          onPressed: () async {
            switch (buttonText) {
              case _changeAvatarText:
                final loginModel =
                    Provider.of<LoginModel>(context, listen: false);
                final uid = loginModel.userId;
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(withData: true);
                final ref =
                    FirebaseStorage.instance.ref('images/profiles/$uid.jpg');
                if (result != null) {
                  Uint8List? fileBytes = result.files.first.bytes;
                  await ref.putData(fileBytes!);
                }
                final url = await ref.getDownloadURL();
                loginModel.setUserImageUrl(url);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                      content: Text('Changed avatar successfully'),
                    ))
                    .closed
                    .then((value) =>
                        ScaffoldMessenger.of(context).clearSnackBars());
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
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: const Text(_changePasswordText),
                          content: ChangePasswordForm());
                    });
                break;
            }
          },
        ));
  }

  Padding _logOutButton(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: redColor,
                minimumSize: const Size.fromHeight(50)), // max width
            child: const Text('Log Out', style: TextStyle(color: defaultColor)),
            onPressed: () {
              final loginModel =
                  Provider.of<LoginModel>(context, listen: false);
              AuthModel.instance().signOut().then((value) {
                loginModel.logOut();
                // Hide StatusBar, Show navigation buttons
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: [SystemUiOverlay.bottom]);
                Navigator.of(context).pop();
              });
            }));
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
                      _logOutButton(context),
                    ]))));
  }
}
