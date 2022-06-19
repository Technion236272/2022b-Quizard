import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:quizard/localization/classes/language_constants.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'consts.dart';
import 'localization/classes/language.dart';
import 'providers.dart';
import 'sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LoginModel()),
    ChangeNotifierProvider(create: (context) => GameModel())
  ], child: const Root()));
}

class Root extends StatefulWidget {
  // This widget is the root of the application.
  const Root({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  late StreamSubscription? _userStateListener;

  @override
  void initState() {
    super.initState();

    _userStateListener =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        debugPrint('DEBUG: User is signed out');
      } else {
        debugPrint('DEBUG: User is signed in');
      }
    });
  }

  @override
  void dispose() {
    _userStateListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Localization();
  }
}

// sign in automatically if app was closed
class LoadHomePage extends StatelessWidget {
  const LoadHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<bool> _prepHomePage() async {
      final loginModel = Provider.of<LoginModel>(context, listen: false);
      final currentUser = AuthModel.instance().user!;
      return await FirebaseFirestore.instance
          .collection("$firestoreMainPath/users")
          .get()
          .then((users) async {
        for (var user in users.docs) {
          if (currentUser.uid == user.id) {
            loginModel.setUserId(user.id);
            loginModel.setEmail(user["email"]);
            loginModel.setUsername(user["username"]);
            loginModel.setWins(user["wins"]);
            try {
              loginModel.setDailyWins(user["DailyWins"]);
              loginModel.setMonthlyWins(user["MonthlyWins"]);
            } catch (e) {
              debugPrint("ERROR = $e");
            }
            if (currentUser.photoURL != null) {
              loginModel.setUserImageUrl(currentUser.photoURL!);
            }
            final ref =
                FirebaseStorage.instance.ref('images/profiles/${user.id}.jpg');
            final url = await ref.getDownloadURL();
            loginModel.setUserImageUrl(url);
            loginModel.logIn();
            return true;
          }
        }
        return false;
      });
    }

    return Container(
        color: backgroundColor,
        child: FutureBuilder(
            future: _prepHomePage(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                if (snapshot.data == true) {
                  return const HomePage();
                }
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _loadingSignUp = false;

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
          .showSnackBar(SnackBar(
            content: Text(translation(context).wrongCertificates),
          ))
          .closed
          .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
      loginModel.toggleLogging(); // Enable log in button back
    }

    Future<void> _goToHomePage() async {
      final uid = loginModel.userId;
      //TODO: Support also .png files
      final ref = FirebaseStorage.instance.ref('images/profiles/$uid.jpg');
      final url = await ref.getDownloadURL();
      loginModel.setUserImageUrl(url);
      loginModel.logIn();
      Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => const HomePage()));
      loginModel.toggleLogging();
    }

    void login(photoLink) {
      FirebaseFirestore.instance
          .collection('$firestoreMainPath/users')
          .get()
          .then((users) async {
        for (var user in users.docs) {
          if (user["email"] == FirebaseAuth.instance.currentUser?.email) {
            loginModel.setUserId(user.id);
            loginModel.setEmail(user["email"]);
            loginModel.setUsername(user["username"]);
            loginModel.setWins(user["wins"]);
            try {
              loginModel.setDailyWins(user["DailyWins"]);
              loginModel.setMonthlyWins(user["MonthlyWins"]);
            } catch (e) {
              debugPrint("ERROR = $e");
            }
            loginModel.setUserImageUrl(photoLink);
          }
        }
      });
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

      FirebaseFirestore.instance
          .collection('$firestoreMainPath/users')
          .get()
          .then((users) async {
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
                try {
                  loginModel.setDailyWins(user["DailyWins"]);
                  loginModel.setMonthlyWins(user["MonthlyWins"]);
                } catch (e) {
                  debugPrint("ERROR = $e");
                }

                loginModel.setPassword(loginModel.passwordController.text);
                loginModel.emailOrUsernameController.text = "";
                loginModel.passwordController.text = "";
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

    void _signUpPrep() async {
      if (!_loadingSignUp) {
        setState(() {
          _loadingSignUp = true;
        });
        final loginModel = Provider.of<LoginModel>(context, listen: false);
        final ref = FirebaseStorage.instance.ref('images/profiles/avatar.png');
        final url = await ref.getDownloadURL();
        loginModel.setUserImageUrl(url);
        final blogImage = await ref.getData();
        loginModel.setInitBlocksAvatar(blogImage!);
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (context) => const SignUpScreen()));
        setState(() {
          _loadingSignUp = false;
        });
      }
    }

    // Consumer for disabling button while logging in
    return Consumer<LoginModel>(builder: (context, loginModel, child) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //const Padding(padding: EdgeInsets.all(30)),
                  const Image(image: AssetImage('images/titles/quizard.png')),
                  Text(
                    translation(context).loginToAccount,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Column(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextFormField(
                            controller: loginModel.emailOrUsernameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: secondaryColor,
                              border: const OutlineInputBorder(),
                              hintText: translation(context).usernameOrEmail,
                            ))),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextFormField(
                            controller: loginModel.passwordController,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: secondaryColor,
                              border: const OutlineInputBorder(),
                              hintText: translation(context).password,
                            ))),
                  ]),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)), // max width
                    child: Text(translation(context).login,
                        style: const TextStyle(fontSize: 18)),
                    onPressed: loginModel.isLoggingIn ? null : _tryLogin,
                  ),
                  Row(children: <Widget>[
                    // OR Divider
                    const Expanded(child: Divider(color: defaultColor)),
                    Text(translation(context).or),
                    const Expanded(child: Divider(color: defaultColor)),
                  ]),
                  Column(
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: secondaryColor,
                                minimumSize:
                                    const Size.fromHeight(50)), // max width
                            onPressed: () {
                              signInWithGoogle().then((value) {
                                bool userExist = false;
                                FirebaseFirestore.instance
                                    .collection('$firestoreMainPath/users')
                                    .get()
                                    .then((users) async {
                                  List<String> allUsersName = [];
                                  String source = "";

                                  for (var user in users.docs) {
                                    allUsersName.add(user["username"]);
                                    if (user["email"] ==
                                        FirebaseAuth
                                            .instance.currentUser?.email) {
                                      source = user["source"].toString();
                                      userExist = true;
                                    }
                                  }
                                  if (!userExist) {
                                    var users = FirebaseFirestore.instance
                                        .collection("$firestoreMainPath/users");

                                    uniqueNameIndex = 0;
                                    final userToAdd = <String, dynamic>{
                                      "answers": [],
                                      "categories": [],
                                      "email": value!.email,
                                      "questions": [],
                                      "friends": [],
                                      "username": getUniqueUserName(
                                          value.email!.split("@")[0],
                                          allUsersName),
                                      "wins": 0,
                                      "DailyWins": 0,
                                      "photoLink":
                                          "${FirebaseAuth.instance.currentUser?.photoURL}",
                                      "source": "google",
                                      "MonthlyWins": 0
                                    };
                                    users.doc(value.uid).set(userToAdd);
                                    login(
                                        "${FirebaseAuth.instance.currentUser?.photoURL}");
                                    Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                            builder: (context) =>
                                                const HomePage()));
                                  } else {
                                    if (source != "google") {
                                      if (source == "facebook") {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          customSnackBar(
                                            content:
                                                translation(context).snackBar9,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          customSnackBar(
                                            content:
                                                translation(context).snackBar10,
                                          ),
                                        );
                                      }
                                    } else {
                                      login(
                                          "${FirebaseAuth.instance.currentUser?.photoURL}");
                                      Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                              builder: (context) =>
                                                  const HomePage()));
                                    }
                                  }
                                });
                              });
                            },
                            label: Text(translation(context).continueWithGoogle,
                                style: const TextStyle(color: defaultColor)),
                            icon: Image.asset(
                              'images/google.png',
                              height: 24,
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: secondaryColor,
                                minimumSize:
                                    const Size.fromHeight(50)), // max width
                            onPressed: () async {
                              signinWithFacebook().then((value) {
                                bool userExist = false;
                                FirebaseFirestore.instance
                                    .collection('$firestoreMainPath/users')
                                    .get()
                                    .then((users) async {
                                  List<String> allUsersName = [];
                                  String source = "";
                                  for (var user in users.docs) {
                                    allUsersName.add(user["username"]);
                                    if (user["email"] ==
                                        FirebaseAuth
                                            .instance.currentUser?.email) {
                                      source = user["source"].toString();
                                      userExist = true;
                                    }
                                  }
                                  if (!userExist) {
                                    var users = FirebaseFirestore.instance
                                        .collection("$firestoreMainPath/users");
                                    final user = <String, dynamic>{
                                      "answers": [],
                                      "categories": [],
                                      "email": value?.email,
                                      "questions": [],
                                      "friends": [],
                                      "username": getUniqueUserName(
                                          "${value?.email?.split("@")[0]}",
                                          allUsersName),
                                      "wins": 0,
                                      "DailyWins": 0,
                                      "photoLink":
                                          "${FirebaseAuth.instance.currentUser?.photoURL}",
                                      "source": "facebook",
                                      "MonthlyWins": 0
                                    };
                                    users.doc(value?.uid).set(user);
                                    login(
                                        "${FirebaseAuth.instance.currentUser?.photoURL}");
                                    Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                            builder: (context) =>
                                                const HomePage()));
                                  } else {
                                    if (source != "facebook") {
                                      if (source == "google") {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          customSnackBar(
                                            content:
                                            translation(context).snackBar11,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          customSnackBar(
                                            content:
                                            translation(context).snackBar10,
                                          ),
                                        );
                                      }
                                    } else {
                                      login(
                                          "${FirebaseAuth.instance.currentUser?.photoURL}");
                                      Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                              builder: (context) =>
                                                  const HomePage()));
                                    }
                                  }
                                });
                              });
                            },
                            label: Text(
                                translation(context).continueWithFacebook,
                                style: const TextStyle(color: defaultColor)),
                            icon: Image.asset(
                              'images/facebook.png',
                              height: 24,
                            ),
                          )),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(translation(context).noAccount),
                        InkWell(
                            child: Text(translation(context).signUp),
                            onTap: () => _signUpPrep())
                      ])
                ]),
          ));
    });
  }

  Future<User?> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content:
              translation(context).snackBar13,
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content: translation(context).snackBar14,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content: translation(context).snackBar15,
          ),
        );
      }
    }

    return user;
  }

  Future<User?> signinWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential

    User? user;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content: translation(context).snackBar16,
          ),
        );
      } else if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content: translation(context).snackBar14,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content: translation(context).snackBar18,
        ),
      );
    }
    return user;
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  int uniqueNameIndex = 0;
  String getUniqueUserName(String name, List<String> allUsersNameList) {
    String uniqueName = name;
    for (String userName in allUsersNameList) {
      if (userName == name) {
        uniqueNameIndex++;
        uniqueName =
            getUniqueUserName("${name}_$uniqueNameIndex", allUsersNameList);
      }
    }
    debugPrint("uniqueName = $uniqueName");
    return uniqueName;
  }
}
