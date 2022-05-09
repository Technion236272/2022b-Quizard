import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'auth_model.dart';
import 'firebase_options.dart';
import 'colors.dart';
import 'home.dart';
import 'login_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LoginModel()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
          colorScheme:
              Theme.of(context).colorScheme.copyWith(primary: Colors.white),
          scaffoldBackgroundColor: backgroundColor),
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
    void _loginNow() {
      // Tyring to log in as it's an email
      loginModel.toggleLogging();
      AuthModel.instance()
          .signIn(loginModel.emailController.text,
              loginModel.passwordController.text)
          .then((result) async {
        if (result == true) {
          // it's a valid email! logging in...
          loginModel.logIn();
          loginModel.toggleLogging();
          Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) => const HomePage()));
        } else {
          // Might be a user name? trying to get email by username...
          FirebaseFirestore fireStore = FirebaseFirestore.instance;
          fireStore
              .collection('users')
              .doc(loginModel.emailController.text)
              .get()
              .then((snapshot) {
            if (snapshot.data() != null) {
              // User found! trying to log in with
              // corresponding email and entered password
              AuthModel.instance()
                  .signIn(snapshot.data()?["email"],
                      loginModel.passwordController.text)
                  .then((result) async {
                if (result == true) {
                  // It was a valid username and found the right email.
                  // logging in...
                  loginModel.logIn();
                  loginModel.toggleLogging();
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (context) => const HomePage()));
                } else {
                  // Else it wasn't a valid password
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                        content: Text('Wrong password'),
                      ))
                      .closed
                      .then((value) =>
                          ScaffoldMessenger.of(context).clearSnackBars());
                  loginModel.toggleLogging();
                }
              });
            } else {
              // Else it wasn't a valid username / email
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(
                    content: Text('Wrong Email / Username'),
                  ))
                  .closed
                  .then((value) =>
                      ScaffoldMessenger.of(context).clearSnackBars());
              loginModel.toggleLogging();
            }
          });
        }
      });
    }

    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
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
                      color: defaultColor,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: TextFormField(
                        controller: loginModel.emailController,
                        cursorColor: defaultColor,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: textFieldBackgroundColor,
                          border: OutlineInputBorder(),
                          hintText: 'Username / Email',
                        ))),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: TextFormField(
                        controller: loginModel.passwordController,
                        cursorColor: defaultColor,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: textFieldBackgroundColor,
                          border: OutlineInputBorder(),
                          hintText: 'Password',
                        ))),
              ]),
              ElevatedButton(
                child:
                    const Text('Log in', style: TextStyle(color: defaultColor)),
                onPressed: loginModel.isLoggingIn
                    ? null
                    : _loginNow, //TODO: Login with Email
              ),
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
                  ElevatedButton.icon(
                    onPressed: () {}, //TODO: Continue with Google
                    label: const Text('Continue with Google',
                        style: TextStyle(color: defaultColor)),
                    icon: const FaIcon(FontAwesomeIcons.google,
                        color: defaultColor),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {}, //TODO: Continue with Facebook
                    label: const Text('Continue with Facebook',
                        style: TextStyle(color: defaultColor)),
                    icon: const FaIcon(FontAwesomeIcons.facebook,
                        color: defaultColor),
                  ),
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
