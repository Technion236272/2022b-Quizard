import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'sign_up_model.dart';
import 'providers.dart';
import 'dart:typed_data';
import 'consts.dart';


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
    Uint8List? blogImage;
    bool flag = false;
    final signUpModel = Provider.of<SignUpModel>(context, listen: false);

    void _openGallery(BuildContext context) async {
      FilePickerResult? result;
      result = await FilePicker.platform.pickFiles(withData: true);
      if(result != null) {
        blogImage = result.files.first.bytes;
        setState(() {});
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
        content: Text('Changed avatar successfully'),
      ))
          .closed
          .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
    }

    _deleteImage(BuildContext context) {
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
                        child: Text("Remove current avatar"),
                        onTap: () {
                          _deleteImage(context);
                        }),
                    Padding(padding: EdgeInsets.all(8.0)),
                InkWell(
                    child: Text('Close'),
                    onTap: () => Navigator.of(context).pop()
                )],),),
            );});

    }

    Future<void> setAvatar() async {
      var uid = signUpModel.userId;
      final ref = FirebaseStorage.instance.ref('images/profiles/$uid.jpg');
      await ref.putData(blogImage!);

    }

    Future<void> setUserId() async{
      FirebaseFirestore.instance.collection('users').get().then((users) {
        for (var user in users.docs) {
          if (user["email"] == signUpModel.emailController.text.trim() ||
              user["username"] == signUpModel.userNameController.text.trim()) {
            signUpModel.setUserId(user.id);
            ScaffoldMessenger
                .of(context)
                .showSnackBar(SnackBar(
              content: Text(user.id)));
            break;
          }
        };}).then((value) => null);
    }

    void register() {
      AuthModel.instance().signUp(signUpModel.emailController.text.trim(), signUpModel.userNameController.text.trim(),
          signUpModel.passwordController.text.trim());
      AuthModel.instance().setUp(signUpModel.emailController.text.trim(), signUpModel.userNameController.text.trim());

    }

    Future<void> checkAlreadyRegistered() async {
      FirebaseFirestore.instance.collection('users').get().then((users) {
        for (var user in users.docs) {
          if (user["email"] == signUpModel.emailController.text.trim() ||
              user["username"] == signUpModel.userNameController.text.trim()) {
            ScaffoldMessenger
                .of(context)
                .showSnackBar(const SnackBar(
              content: Text('Email/Username already exists.'),
            ))
                .closed
                .then((value) =>
                ScaffoldMessenger.of(context).clearSnackBars());
            flag = true;
          };
        }
      }).then((value) async {
        if (!flag) {
          register();
          await setUserId();
          await setAvatar();
          Navigator.of(context).pop();
        }});

      await signUpModel.deleteRegistration();
    }

    void _trySignUp() {
      FocusManager.instance.primaryFocus?.unfocus();
      if (signUpModel.emailController.text.trim().isEmpty ||
          signUpModel.passwordController.text.trim().isEmpty ||
          signUpModel.userNameController.text.trim().isEmpty ||
          signUpModel.secondPasswordController.text.trim().isEmpty) {
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
          signUpModel.emailController.text.trim())) {
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
      if (signUpModel.passwordController.text.trim().length < 6) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(const SnackBar(
          content: Text('Password should contain at least 6 characters.'),
        ))
            .closed
            .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
        return;
      }
      checkAlreadyRegistered();
    }


    return Consumer<SignUpModel>(builder: (context, signUpModel, child) {
      return Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(12),
              child: Expanded(
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
                          style: TextStyle(color: Colors.white, height: 2, fontSize: 20),),
                      Column(children: <Widget>[
                        GestureDetector(
                          onTap: () => _showChoiceDialog(context),
                            child: CircleAvatar(
                                backgroundImage: blogImage != null ? Image.memory(blogImage!).image: AssetImage('images/titles/avatar.png') ,
                                backgroundColor: thirdColor,
                                radius: 70))]),
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
                  ]))));

    });
  }
}