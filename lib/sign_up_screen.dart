import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'consts.dart';
import 'sign_up_model.dart';

class SignUpScreen extends StatefulWidget{
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    super.initState();

    // Hide StatusBar, Show navigation buttons
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpModel>(builder: (context, signUpModel, child) {
      return Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                            child: Icon(
                              Icons.arrow_back,
                              size: 32.0,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                            }
                        )],
                    ),
                    const Image(
                        image: AssetImage('images/titles/almost_there.png')),
                    const Text(
                      'Select your avatar',
                      style: TextStyle(color: Colors.white, height: 2, fontSize: 18),),
                    Column(children: <Widget>[
                      SizedBox(),
                      GestureDetector(
                      onTap: null,              // Todo: Select image as an avatar.
                      child:  CircleAvatar(
                        radius: 55.0,
                        backgroundImage: ExactAssetImage('images/titles/avatar.png'),),
                    )]),
                    Column(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 3),
                          child: TextFormField(
                              controller: signUpModel.userNameController,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(),
                                hintText: 'Username',
                              ))),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 3),
                          child: TextFormField(
                              controller: signUpModel.emailController,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: secondaryColor,
                                border: OutlineInputBorder(),
                                hintText: 'Email',
                              ))),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 3),
                          child: TextFormField(
                              controller: signUpModel.passwordController,
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
                              horizontal: 24, vertical: 3),
                          child: TextFormField(
                              controller: signUpModel.secondPasswordController,
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
                    Padding(   // TODO: Fix Overflow
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: secondaryColor,
                                minimumSize:
                                const Size.fromHeight(50)),
                            child: const Text('Finish signing up',
                                style: TextStyle(color: defaultColor)),
                            onPressed: () {          // TODO: Add sign up implementation
                              Navigator.of(context).pop();
                            }
                        )),
                  ])
          ));
    });
  }
}