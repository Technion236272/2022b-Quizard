import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

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
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(12),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
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
        const Text(
          'Logged in successfully!',
          style: TextStyle(fontSize: 18),
        ),
        ElevatedButton(
          child: const Text('Go back', style: TextStyle(color: defaultColor)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ]),
    ));
  }
}
