import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'auth_model.dart';
import 'colors.dart';
import 'login_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Hide navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    final loginModel = Provider.of<LoginModel>(context, listen: false);

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
                ),
                InkWell(
                  child: Icon(
                    Icons.info_outline,
                    color: defaultColor,
                    size: 32.0,
                  ),
                  onTap: null, // TODO: Go to Rules screen
                )
              ],
            ),
            const Image(image: AssetImage('images/titles/quizard.png')),
            Text(
              'Welcome, ${loginModel.emailController.text}!',
              style: const TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              child:
                  const Text('Log out', style: TextStyle(color: defaultColor)),
              onPressed: () async {
                await AuthModel.instance().signOut();
                loginModel.logOut();
                // Hide StatusBar, Show navigation buttons
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: [SystemUiOverlay.bottom]);
                Navigator.of(context).pop();
              },
            ),
            Container()
          ]),
    ));
  }
}
