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

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LoginModel()),
    ChangeNotifierProvider(create: (context) => NavModel())
  ], child: const MyApp()));
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
      loginModel.getUserImage(); // Cache it
      loginModel.logIn();
      loginModel.toggleLogging();
      Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => const HomePage()));
    }

    void _tryLogin() {
      loginModel.toggleLogging();
      FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard

      if (loginModel.emailOrUsernameController.text.isEmpty ||
          loginModel.passwordController.text.isEmpty) {
        _wrongCerts();
        return;
      }

      // Tyring to log in as it's an email
      AuthModel.instance()
          .signIn(loginModel.emailOrUsernameController.text,
              loginModel.passwordController.text)
          .then((result) {
        if (result == true) {
          // it's a valid email! Gathering data and logging in...
          FirebaseFirestore fireStore = FirebaseFirestore.instance;
          fireStore.collection('users').get().then((users) {
            for (var user in users.docs) {
              if (user["email"] == loginModel.emailOrUsernameController.text) {
                loginModel.setEmail(loginModel.emailOrUsernameController.text);
                loginModel.setUsername(user.id);
                loginModel.setWins(user["wins"]);
                _goToHomePage();
              }
            }
          });
        } else {
          // Might be a user name? trying to get email by username...
          FirebaseFirestore fireStore = FirebaseFirestore.instance;
          fireStore
              .collection('users')
              .doc(loginModel.emailOrUsernameController.text)
              .get()
              .then((snapshot) {
            if (snapshot.data() != null) {
              // User found! trying to log in with
              // corresponding email and entered password
              AuthModel.instance()
                  .signIn(snapshot.data()?["email"],
                      loginModel.passwordController.text)
                  .then((result) {
                if (result == true) {
                  // It was a valid username and found the right email.
                  // logging in...
                  loginModel
                      .setUsername(loginModel.emailOrUsernameController.text);
                  loginModel.setEmail(snapshot.data()?["email"]);
                  loginModel.setWins(snapshot.data()?["wins"]);
                  _goToHomePage();
                } else {
                  // It was a valid username but wasn't a valid password
                  _wrongCerts();
                }
              });
            } else {
              // Else it wasn't a valid username / email,
              // Or it was a valid email but wrong password
              _wrongCerts();
            }
          });
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
