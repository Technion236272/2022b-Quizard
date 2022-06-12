import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'consts.dart';
import 'home.dart';
import 'providers.dart';
import 'sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LoginModel()),
    ChangeNotifierProvider(create: (context) => GameModel())
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
          .showSnackBar(const SnackBar(
            content: Text('Wrong certificates'),
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
          .collection('$strVersion/users')
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
              print("ERROR = $e");
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
          .collection('$strVersion/users')
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
                            minimumSize:
                                const Size.fromHeight(50)), // max width
                        child: const Text('Log in',
                            style: TextStyle(fontSize: 18)),
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
                            onPressed: () {
                              signInWithGoogle().then((value) {
                                bool userExist = false;
                                FirebaseFirestore.instance
                                    .collection('$strVersion/users')
                                    .get()
                                    .then((users) async {
                                  for (var user in users.docs) {
                                    if (user["email"] ==
                                        FirebaseAuth
                                            .instance.currentUser?.email) {
                                      userExist = true;
                                    }
                                  }
                                  if (!userExist) {
                                    var users = FirebaseFirestore.instance
                                        .collection("$strVersion/users");
                                    final userToAdd = <String, dynamic>{
                                      "answers": [],
                                      "categories": [],
                                      "email": value!.email,
                                      "questions": [],
                                      "username": value.displayName,
                                      "wins": 0,
                                      "DailyWins": 0,
                                      "photoLink":
                                          "${FirebaseAuth.instance.currentUser?.photoURL}",
                                      "MonthlyWins": 0
                                    };
                                    users.doc(value.uid).set(userToAdd);
                                  }

                                  login(
                                      "${FirebaseAuth.instance.currentUser?.photoURL}");
                                  Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (context) =>
                                              const HomePage()));
                                });
                              });
                            }, //TODO: Continue with Google
                            label: const Text('Continue with Google',
                                style: TextStyle(color: defaultColor)),
                            icon: Image.asset(
                              'images/google.png',
                              height: 24,
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: secondaryColor,
                                minimumSize:
                                    const Size.fromHeight(50)), // max width
                            onPressed: () async {
                              signinWithFacebook().then((value) {
                                bool userExist = false;
                                FirebaseFirestore.instance
                                    .collection('$strVersion/users')
                                    .get()
                                    .then((users) async {
                                  for (var user in users.docs) {
                                    if (user["email"] ==
                                        FirebaseAuth
                                            .instance.currentUser?.email) {
                                      userExist = true;
                                    }
                                  }
                                  if (!userExist) {
                                    var users = FirebaseFirestore.instance
                                        .collection("$strVersion/users");
                                    final user = <String, dynamic>{
                                      "answers": [],
                                      "categories": [],
                                      "email": value.user?.email,
                                      "questions": [],
                                      "username": value.user?.displayName,
                                      "wins": 0,
                                      "DailyWins": 0,
                                      "photoLink":
                                          "${FirebaseAuth.instance.currentUser?.photoURL}",
                                      "MonthlyWins": 0
                                    };
                                    users.doc(value.user?.uid).set(user);
                                  }
                                  login(
                                      "${FirebaseAuth.instance.currentUser?.photoURL}");
                                  Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (context) =>
                                              const HomePage()));
                                });
                              });
                            }, //TODO: Continue with Facebook
                            label: const Text('Continue with Facebook',
                                style: TextStyle(color: defaultColor)),
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
                        const Text("Don't have an account? "),
                        InkWell(
                            child: const Text('Sign Up'),
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
                  'The account already exists with a different credential.',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content: 'Error occurred using Google Sign-In. Try again.',
          ),
        );
      }
    }

    return user;
  }

  Future<UserCredential> signinWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential

    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);

    return userCredential;
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
}
