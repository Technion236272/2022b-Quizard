import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'providers.dart';
import 'consts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final secondPasswordController = TextEditingController();
  bool isInitialized = false; // Used to avoid flicking profile picture

  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Show navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);

    void _openGallery(BuildContext context) async {
      FilePickerResult? result;
      result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null) {
        loginModel.setInitBlocksAvatar(result.files.first.bytes!);
      }
    }

    Future<void> setAvatar() async {
      final userId = loginModel.userId;
      Reference ref =
          FirebaseStorage.instance.ref('images/profiles/$userId.jpg');
      await ref.putData(loginModel.initAvatarBlock);
    }

    Future<void> register() async {
      final uid = await AuthModel.instance()
          .signUp(emailController.text.trim(), passwordController.text.trim());
      final userId = uid!;
      loginModel.setUserId(userId);
      await AuthModel.instance().setUp(
          emailController.text.trim(), userNameController.text.trim(), uid);
    }

    Future<void> _goToHomePage() async {
      final userId = loginModel.userId;
      loginModel.setUserId(userId);
      loginModel.setEmail(emailController.text);
      loginModel.setUsername(userNameController.text);
      loginModel.setWins(0);

      loginModel.setDailyWins(0);
      loginModel.setMonthlyWins(0);

      loginModel.setPassword(passwordController.text);
      //TODO: Support also .png files
      final ref = FirebaseStorage.instance.ref('images/profiles/$userId.jpg');
      final url = await ref.getDownloadURL();
      loginModel.setUserImageUrl(url);
      loginModel.logIn();
      Navigator.of(context).pop();
      Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => const HomePage()));
      loginModel.toggleLogging();
    }

    Future<void> checkAlreadyRegistered() async {
      FirebaseFirestore.instance
          .collection('versions/v1/users')
          .get()
          .then((users) {
        for (var user in users.docs) {
          if (user["email"] == emailController.text.trim() ||
              user["username"] == userNameController.text.trim()) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(
                  content: Text('Email/Username already exists.'),
                ))
                .closed
                .then(
                    (value) => ScaffoldMessenger.of(context).clearSnackBars());
            loginModel.toggleLogging();
            return;
          }
        }
      }).then((value) async {
        await register();
        await setAvatar();
        await _goToHomePage();
      });
    }

    void _trySignUp() {
      loginModel.toggleLogging();
      FocusManager.instance.primaryFocus?.unfocus();
      if (emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty ||
          userNameController.text.trim().isEmpty ||
          secondPasswordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
              content: Text('All fields are required!'),
            ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        loginModel.toggleLogging();
        return;
      }

      if (!RegExp("^[a-zA-Z0-9+_.~]+@[a-zA-Z0-9.-]+.[a-z]")
          .hasMatch(emailController.text.trim())) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
              content: Text('Enter a valid email.'),
            ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        loginModel.toggleLogging();
        return;
      }

      if (passwordController.text != secondPasswordController.text) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
              content: Text('Passwords do not match!'),
            ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        loginModel.toggleLogging();
        return;
      }
      if (passwordController.text.trim().length < 6) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
              content: Text('Password should contain at least 6 characters.'),
            ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        loginModel.toggleLogging();
        return;
      }
      checkAlreadyRegistered();
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          body: SingleChildScrollView(
              reverse: true, // Helps to see the whole form. amazing!
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: <Widget>[
                    Row(
                      children: <Widget>[
                        InkWell(
                            child: const Icon(
                              Icons.arrow_back,
                              size: 32.0,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Image(
                            image:
                                AssetImage('images/titles/almost_there.png'))),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Select your avatar by clicking the photo below',
                        )),
                    Column(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: GestureDetector(
                              onTap: () => _openGallery(context),
                              child: CircleAvatar(
                                  backgroundImage: loginModel.getInitAvatar(),
                                  backgroundColor: thirdColor,
                                  radius: 70)))
                    ]),
                    Column(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: TextFormField(
                              controller: userNameController,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(),
                                hintText: 'Username',
                              ))),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(),
                                hintText: 'Email',
                              ))),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(),
                                hintText: 'Password',
                              ))),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: TextFormField(
                              controller: secondPasswordController,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(),
                                hintText: 'Repeat password',
                              ))),
                    ]),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50)),
                          child: const Text('Finish signing up'),
                          onPressed: loginModel.isLoggingIn ? null : _trySignUp,
                        )),
                  ]))));
    });
  }
}
