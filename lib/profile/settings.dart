import 'package:yaml/yaml.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quizard/main.dart';

import '../consts.dart';

import '../localization/classes/language.dart';
import '../localization/classes/language_constants.dart';
import '../providers.dart';

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
              onTap: () {
                // Show navigation buttons
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: [SystemUiOverlay.bottom]);
              },
              controller: _newPasswordController,
              minLines: 1,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (val) {
                if (val == '') {
                  return translation(context).passNotEmpty;
                }
                if (val!.length < 6) {
                  return translation(context).sixCharacters;
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: translation(context).newPass,
              ),
            ),
            TextFormField(
              onTap: () {
                // Show navigation buttons
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: [SystemUiOverlay.bottom]);
              },
              controller: _repeatPasswordController,
              minLines: 1,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (val) {
                if (val == '') {
                  return translation(context).passNotEmpty;
                }
                if (val != _newPasswordController.text) {
                  return translation(context).noMatch;
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: translation(context).repeatNewPass,
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
                                .showSnackBar(SnackBar(
                                  content: Text(
                                      translation(context).passwordChanged),
                                ))
                                .closed
                                .then((value) => ScaffoldMessenger.of(context)
                                    .clearSnackBars());
                            Navigator.of(context).pop(true);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                  content: Text(
                                      translation(context).somethingIsWrong),
                                ))
                                .closed
                                .then((value) => ScaffoldMessenger.of(context)
                                    .clearSnackBars());
                          }
                        });
                      }
                    }
                  },
                  child: Text(translation(context).submit),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(translation(context).cancel2),
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      _textController.text = loginModel.email;

      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onTap: () {
                // Show navigation buttons
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: [SystemUiOverlay.bottom]);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email can't be empty";
                }
                if (!RegExp("^[a-zA-Z0-9+_.~]+@[a-zA-Z0-9.-]+.[a-z]")
                    .hasMatch(value)) {
                  return "Email must be valid";
                }
                return null;
              },
              controller: _textController,
              minLines: 1,
              maxLines: 1,
              decoration: InputDecoration(hintText: translation(context).email),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    // stop if validator failed
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    // first check if email exists
                    final enteredEmail = _textController.text;
                    bool foundUser = false;
                    await FirebaseFirestore.instance
                        .collection('$firestoreMainPath/users')
                        .get()
                        .then((users) {
                      for (var user in users.docs) {
                        if (user["email"] == enteredEmail) {
                          foundUser = true;
                          Navigator.of(context).pop(true);
                          constSnackBar("Email already exists", context);
                        }
                      }
                    });
                    if (foundUser) {
                      return;
                    }

                    // then change email
                    resetEmail(loginModel.email, _textController.text,
                            loginModel.password)
                        .then((value) {
                      if (value == true) {
                        FirebaseFirestore.instance
                            .collection('$firestoreMainPath/users')
                            .doc(loginModel.userId)
                            .update({
                          "email": _textController.text,
                        }).then((_) {
                          loginModel.setEmail(_textController.text);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                content:
                                    Text(translation(context).changedEmail),
                              ))
                              .closed
                              .then((value) => ScaffoldMessenger.of(context)
                                  .clearSnackBars());
                          Navigator.of(context).pop(true);
                        });
                      }
                    });
                  },
                  child: Text(translation(context).submit),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(translation(context).cancel2),
                ),
              ),
            ])
          ],
        ),
      );
    });
  }
}

class ChangeLanguageForm extends StatefulWidget {
  const ChangeLanguageForm({Key? key}) : super(key: key);
  @override
  State<ChangeLanguageForm> createState() => _ChangeLanguageFormState();
}

class _ChangeLanguageFormState extends State<ChangeLanguageForm> {
  Language? value;
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Form(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: darkGreyColor, blurRadius: 1)
                  ]),
              child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    child: Row(children: [
                      Container(
                        width: 100,
                        child: value == null
                            ? Text(Localization.getLocale(context),
                        style: TextStyle(fontSize: 17)) : Text(value!.name,
                            style: TextStyle(fontSize: 17)),),
                      DropdownButton<Language>(
                          icon: Icon(Icons.arrow_drop_down),
                          underline: Container(
                          ),
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          items: Language.languageList()
                              .map(
                                (e) => DropdownMenuItem<Language>(
                                    value: e,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Text(
                                          e.flag,
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                        Text(e.name)
                                      ],
                                    )),
                              )
                              .toList(),
                          onChanged: (Language? language) async {
                            setState(() {
                              value = language!;
                            });
                            if (language != null) {
                              Locale _locale =
                                  await setLocale(language.languageCode);
                              Localization.setLocale(context, _locale);
                            }
                          })
                    ]),
                  )))
        ],
      ));
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
      final _formKey = GlobalKey<FormState>();

      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onTap: () {
                // Show navigation buttons
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: [SystemUiOverlay.bottom]);
              },
              controller: _textController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Username can't be empty";
                }
                bool? hasShtrudel = value.contains("@");
                if (hasShtrudel) {
                  return "Username can't have '@' in it";
                }
                return null;
              },
              minLines: 1,
              maxLines: 1,
              maxLength: 12,
              decoration: InputDecoration(
                hintText: translation(context).username,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    // stop if validator failed
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    final enteredUsername = _textController.text;
                    bool foundUser = false;

                    // first check if username exists
                    await FirebaseFirestore.instance
                        .collection('$firestoreMainPath/users')
                        .get()
                        .then((users) {
                      for (var user in users.docs) {
                        if (user["username"] == enteredUsername) {
                          foundUser = true;
                          constSnackBar(
                              translation(context).usernameExists, context);
                        }
                      }
                    });
                    if (!foundUser) {
                      // username not exists -> then update
                      await FirebaseFirestore.instance
                          .collection('$firestoreMainPath/users')
                          .doc(loginModel.userId)
                          .update({
                        "username": enteredUsername,
                      }).then((_) {
                        loginModel.setUsername(enteredUsername);
                        constSnackBar(
                            translation(context).changedUsernameSucc, context);
                      });
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: Text(translation(context).submit),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(translation(context).cancel2),
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

  static const _changeLanguageText = 'Change Language';
  static const _changeAvatarText = 'Change Avatar';
  static const _changeUsernameText = 'Change Username';
  static const _changeEmailText = 'Change Email';
  static const _changePasswordText = 'Change Password';
  static const _aboutDialogText = 'About';

  Padding _settingsButton(String buttonText, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: thirdColor,
              minimumSize: const Size.fromHeight(50)), // max width
          child: Text(getLocalizedFieldValue(buttonText, context),
              style: const TextStyle(color: defaultColor)),
          onPressed: () async {
            switch (buttonText) {
              case _changeLanguageText:
                showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text(translation(context).changeLanguage),
                              content: const ChangeLanguageForm());
                        })
                    .then((value) => SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.manual,
                        overlays: []));
                break;
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
                    .showSnackBar(SnackBar(
                      content: Text(translation(context).changedAvatar),
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
                              title: Text(translation(context).changeUsername),
                              content: ChangeUsernameForm());
                        })
                    .then((value) => SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.manual,
                        overlays: []));
                break;
              case _changeEmailText:
                showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text(translation(context).changeEmail),
                              content: ChangeEmailForm());
                        })
                    .then((value) => SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.manual,
                        overlays: []));
                break;
              case _changePasswordText:
                showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text(translation(context).changePassword),
                              content: ChangePasswordForm());
                        })
                    .then((value) => SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.manual,
                        overlays: []));
                break;
              case _aboutDialogText:
                final pubspecData = await rootBundle.loadString('pubspec.yaml');
                final pubspecMap = loadYaml(pubspecData);
                String version = pubspecMap["version"];
                showAboutDialog(
                    context: context,
                    applicationIcon: Image.asset("images/AboutDialogIcon.png", width: 50,),
                    applicationName: 'Quizard',
                    applicationVersion: version.split('+')[0],
                    applicationLegalese:
                        'Created by Raz Ashkenazi, Maysam Haj Yahia, '
                        'and Ramzi Rwashdeh\n\n'
                        '© 2022 Quizard');
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
            child: Text(translation(context).logOut,
                style: const TextStyle(color: defaultColor)),
            onPressed: () {
              final loginModel =
                  Provider.of<LoginModel>(context, listen: false);
              AuthModel.instance().signOut().then((value) {
                loginModel.logOut();
                // Hide StatusBar, Show navigation buttons
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: [SystemUiOverlay.bottom]);
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                    builder: (context) => const WelcomePage()));
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
                        _settingsButton(_changeLanguageText, context),
                        _settingsButton(_changeAvatarText, context),
                        _settingsButton(_changeUsernameText, context),
                        _settingsButton(_changeEmailText, context),
                        _settingsButton(_changePasswordText, context),
                        _settingsButton(_aboutDialogText, context),
                      ]),
                      _logOutButton(context),
                    ]))));
  }
}
