import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'consts.dart';
import 'home.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => LoginModel())],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
        colorScheme:
            Theme.of(context).colorScheme.copyWith(primary: defaultColor),
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
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

    void _wrongCerts() {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
            content: Text('Wrong certificates'),
          ))
          .closed
          .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
      loginModel.toggleLogging(); // Enable log in button back
    }

    Future<void> _goToHomePage() async {
      final username = loginModel.username;
      final ref = FirebaseStorage.instance.ref('images/profiles/$username.jpg');
      final url = await ref.getDownloadURL();
      loginModel.setUserImageUrl(url);
      loginModel.logIn();
      Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => const HomePage()));
      loginModel.toggleLogging();
    }

    void _tryLogin() {
      loginModel.toggleLogging();

      FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard

      bool loggedIn = false;

      if (loginModel.emailOrUsernameController.text.isEmpty ||
          loginModel.passwordController.text.isEmpty) {
        _wrongCerts();
        return;
      }

      FirebaseFirestore.instance.collection('users').get().then((users) async {
        for (var user in users.docs) {
          if (user["email"] == loginModel.emailOrUsernameController.text ||
              user["username"] == loginModel.emailOrUsernameController.text) {
            await AuthModel.instance()
                .signIn(user["email"], loginModel.passwordController.text)
                .then((value) {
              if (value == true) {
                loggedIn = true;
                loginModel.setUserId(user.id);
                loginModel.setEmail(user["email"]);
                loginModel.setUsername(user["username"]);
                loginModel.setWins(user["wins"]);
                _goToHomePage();
                return;
              }
            });
          }
        }
      }).then((value) {
        if (!loggedIn) {
          _wrongCerts();
        }
      });
    }

    // Consumer for disabling button while logging in
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      InkWell(
                        child: Icon(
                          Icons.language,
                          size: 32.0,
                        ),
                        onTap: null, // TODO: Go to Change Language screen
                      )
                    ],
                  ),
                  const Image(image: AssetImage('images/titles/quizard.png')),
                  const Text(
                    'Please login to your account',
                    style: TextStyle(fontSize: 18),
                  ),
                  Column(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: TextFormField(
                            controller: loginModel.emailOrUsernameController,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: secondaryColor,
                              border: OutlineInputBorder(),
                              hintText: 'Username / Email',
                            ))),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: TextFormField(
                            controller: loginModel.passwordController,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: secondaryColor,
                              border: OutlineInputBorder(),
                              hintText: 'Password',
                            ))),
                  ]),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: secondaryColor,
                            minimumSize:
                                const Size.fromHeight(50)), // max width
                        child: const Text('Log in',
                            style: TextStyle(color: defaultColor)),
                        onPressed: loginModel.isLoggingIn ? null : _tryLogin,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(children: const <Widget>[
                        // OR Divider
                        Expanded(child: Divider(color: defaultColor)),
                        Text("  OR  "),
                        Expanded(child: Divider(color: defaultColor)),
                      ])),
                  Column(
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: secondaryColor,
                                minimumSize:
                                    const Size.fromHeight(50)), // max width
                            onPressed: () {}, //TODO: Continue with Google
                            label: const Text('Continue with Google',
                                style: TextStyle(color: defaultColor)),
                            icon: const FaIcon(FontAwesomeIcons.google,
                                color: defaultColor),
                          )),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: secondaryColor,
                                minimumSize:
                                    const Size.fromHeight(50)), // max width
                            onPressed: () {}, //TODO: Continue with Facebook
                            label: const Text('Continue with Facebook',
                                style: TextStyle(color: defaultColor)),
                            icon: const FaIcon(FontAwesomeIcons.facebook,
                                color: defaultColor),
                          )),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Text("Don't have an account? "),
                        InkWell(
                          child: Text('Sign Up'),
                          onTap: null, //TODO: Go to Sign Up screen
                        )
                      ])
                ]),
          ));
    });
  }
}
