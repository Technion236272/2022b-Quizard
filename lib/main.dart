import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'firebase_options.dart';
import 'colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Show navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(12),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
              Widget>[
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextFormField(
                  cursorColor: defaultColor,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(),
                    hintText: 'Username / Email',
                  ))),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextFormField(
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
          child: const Text('Log in', style: TextStyle(color: defaultColor)),
          onPressed: () {}, //TODO: Login with Email
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
              icon: const FaIcon(FontAwesomeIcons.google, color: defaultColor),
            ),
            ElevatedButton.icon(
              onPressed: () {}, //TODO: Continue with Facebook
              label: const Text('Continue with Facebook',
                  style: TextStyle(color: defaultColor)),
              icon:
                  const FaIcon(FontAwesomeIcons.facebook, color: defaultColor),
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
  }
}
