import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'consts.dart';
import 'sign_up_model.dart';
import 'providers.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
    final signUpModel = Provider.of<SignUpModel>(context, listen: false);
    File? imageFile = null;


    _openGallery(BuildContext context) async {
      final ImagePicker _picker = ImagePicker();
      var photo = await _picker.pickImage(source: ImageSource.gallery);
      this.setState(() {
        imageFile = photo as File;
      });
      Navigator.of(context).pop();
    }

    _openCamera(BuildContext context) async {
      final ImagePicker _picker = ImagePicker();
      var photo = await _picker.pickImage(source: ImageSource.camera);
      this.setState(() {
        imageFile = photo as File;
      });
      Navigator.of(context).pop();
    }

    _deleteImage(BuildContext context) {
      this.setState(() {
        imageFile = File('images/titles/avatar.png');
      });
      Navigator.of(context).pop();
    }

    Future<void> _showChoiceDialog(BuildContext context) {
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Select"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                        child: Text("Gallery"),
                        onTap: () {
                          _openGallery(context);
                        }),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                        child: Text("Camera"),
                        onTap: () {
                          _openCamera(context);
                        }),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                        child: Text("Remove current avatar"),
                        onTap: () {
                          _deleteImage(context);
                        }),
                  ],),
              ),);
          });
    }

    void _trySignUp() {
      FocusManager.instance.primaryFocus?.unfocus();
      if (signUpModel.emailController.text.isEmpty ||
          signUpModel.passwordController.text.isEmpty ||
          signUpModel.userNameController.text.isEmpty ||
          signUpModel.secondPasswordController.text.isEmpty) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(const SnackBar(
          content: Text('All fields are required!'),
        ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        return;
      }
      if (!RegExp("^[a-zA-Z0-9+_.~]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(
          signUpModel.emailController.text)) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(const SnackBar(
          content: Text('Enter a valid email.'),
        ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        return;
      }
      if (signUpModel.passwordController.text !=
          signUpModel.secondPasswordController.text) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(const SnackBar(
          content: Text('Passwords do not match!'),
        ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        return;
      }
      if (signUpModel.passwordController.text.length < 6) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(const SnackBar(
          content: Text('Password should contain at least 6 characters.'),
        ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        return;
      }
      AuthModel.instance().signUp(signUpModel.emailController.text.trim(),
          signUpModel.passwordController.text.trim());
      Navigator.of(context).pop();

      // Todo: finish up "email is already registered".
      // Todo: finish up "userName is already registered".
    }




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
                          onTap: () => _showChoiceDialog(context),
                          child:  CircleAvatar(
                            radius: 55.0,
                            backgroundImage: ExactAssetImage('images/titles/avatar.png'),),
                        ),
                      ]),
                      Column(children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
                            child: TextFormField(
                                controller: signUpModel.userNameController,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: secondaryColor,
                                  border: OutlineInputBorder(),
                                  hintText: 'Username',
                                ))),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
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
                                onPressed: () {
                                  _trySignUp();
                                }
                                )),
                  ])));

    });
  }
}