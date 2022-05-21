import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum Status { uninitialized, authenticated, authenticating, unauthenticated }

class AuthModel with ChangeNotifier {
  final FirebaseAuth _auth;
  User? _user;
  Status _status = Status.uninitialized;

  AuthModel.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.authenticated;

  Future<String?> signUp(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return _auth.currentUser?.uid;
    } catch (e) {
      _status = Status.unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<void> setUp(String email, String userName, String userId) async {
    var users = FirebaseFirestore.instance.collection("users");
    final user = <String, dynamic>{
      "answers": [],
      "categories": [],
      "email": email,
      "questions": [],
      "username": userName,
      "wins": 0
    };
    users.doc(userId).set(user);
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.authenticated;
    }
    notifyListeners();
  }
}

class LoginModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoggingIn = false;
  String _userId = '';
  String _username = '';
  String _email = '';
  String _password = '';
  int _wins = 0;
  String _userImageUrl = '';
  List<Dismissible> cachedQuestionsList = [];
  late Uint8List initAvatarBlock;

  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool get isLoggingIn => _isLoggingIn;
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get userId => _userId;
  String get email => _email;
  String get password => _password;
  String get userImageUrl => _userImageUrl;
  int get wins => _wins;
  TextEditingController get emailOrUsernameController =>
      _emailOrUsernameController;
  TextEditingController get passwordController => _passwordController;

  void logIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logOut() {
    _isLoggedIn = false;
    _username = '';
    _email = '';
    _wins = 0;
    _userImageUrl = '';
    cachedQuestionsList = [];
    notifyListeners();
  }

  // for disabling login button
  void toggleLogging() {
    _isLoggingIn = !_isLoggingIn;
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setWins(int wins) {
    _wins = wins;
    notifyListeners();
  }

  void setUserId(String uid) {
    _userId = uid;
    notifyListeners();
  }

  void setPassword(String pass) {
    _password = pass;
    notifyListeners();
  }

  void setUserImageUrl(String url) {
    _userImageUrl = url;
    notifyListeners();
  }

  NetworkImage? getUserImage() {
    if (_userImageUrl == '') {
      return null;
    } else {
      return NetworkImage(_userImageUrl);
    }
  }

  void notifyAddedQuestion() {
    notifyListeners();
  }

  void setInitBlocksAvatar(Uint8List blocks) {
    initAvatarBlock = blocks;
    notifyListeners();
  }

  ImageProvider getInitAvatar() {
    return Image.memory(initAvatarBlock).image;
  }
}

class GameModel extends ChangeNotifier {
  bool? _isReady = false;

  bool? get isReady => _isReady;

  void toggleIsReady() {
    _isReady = !_isReady!;
    notifyListeners();
  }
}
