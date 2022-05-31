import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'game.dart';

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
    var users = FirebaseFirestore.instance.collection("versions/v1/users");
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
  List<bool?> _areReady = [false];
  bool _isPrivate = true;
  bool _isLocked = false;
  bool _enableSubmitFalseAnswer = true;
  String _pinCode = '';
  String _admin = '';
  int userIndex = -1;
  int _currentScreen = 1;
  List<String> _participants = [];
  List<String> _officialCategories = [];
  List<String> _customCategories = [];
  List<String> _selectedCategories = [];
  List<String> _gameQuestions = [];
  List<String> _gameAnswers = [];
  List<String> currentAnswers = [];
  List<Widget> _currentQuizOptions = [];

  final _falseAnswerController = TextEditingController();

  List<bool?> get areReady => _areReady;
  bool get isPrivate => _isPrivate;
  bool get isLocked => _isLocked;
  bool get enableSubmitFalseAnswer => _enableSubmitFalseAnswer;
  String get pinCode => _pinCode;
  String get admin => _admin;
  int get currentScreen => _currentScreen;
  List<String> get participants => _participants;
  List<String> get officialCategories => _officialCategories; // For admin
  List<String> get customCategories => _customCategories; // For admin
  List<String> get selectedCategories => _selectedCategories; // For participant
  List<String> get gameQuestions => _gameQuestions;
  List<String> get gameAnswers => _gameAnswers;
  TextEditingController get falseAnswerController => _falseAnswerController;
  List<Widget> get currentQuizOptions => _currentQuizOptions;

  set areReady(List<bool?> values) {
    _areReady = values;
    notifyListeners();
  }

  set isPrivate(bool value) {
    _isPrivate = value;
    notifyListeners();
  }

  set isLocked(bool value) {
    _isLocked = value;
    notifyListeners();
  }

  set enableSubmitFalseAnswer(bool value) {
    _enableSubmitFalseAnswer = value;
    notifyListeners();
  }

  set pinCode(String value) {
    _pinCode = value;
    notifyListeners();
  }

  set admin(String value) {
    _admin = value;
    notifyListeners();
  }

  set currentScreen(int value) {
    _currentScreen = value;
    notifyListeners();
  }

  set participants(List<String> values) {
    _participants = values;
    notifyListeners();
  }

  set officialCategories(List<String> categories) {
    _officialCategories = categories;
    notifyListeners();
  }

  set customCategories(List<String> categories) {
    _customCategories = categories;
    notifyListeners();
  }

  set selectedCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  set gameQuestions(List<String> questions) {
    _gameQuestions = questions;
    notifyListeners();
  }

  set gameAnswers(List<String> answers) {
    _gameAnswers = answers;
    notifyListeners();
  }

  set currentQuizOptions(List<Widget> values) {
    _currentQuizOptions = values;
    notifyListeners();
  }

  void addParticipant(String username) {
    if (!_participants.contains(username)) {
      _participants.add(username);
      notifyListeners();
    }
  }

  void removeParticipant(String username) {
    if (_participants.contains(username)) {
      _participants.remove(username);
      notifyListeners();
    }
  }

  void resetData() {
    _areReady = [false];
    _isPrivate = true;
    _isLocked = false;
    _pinCode = '';
    _admin = '';
    _participants = [];
    _officialCategories = [];
    _customCategories = [];
    notifyListeners();
  }

  void update(DocumentSnapshot game) {
    if (game.exists) {
      _areReady = List<bool?>.from(game["are_ready"]);
      _isLocked = game["is_locked"];
      _participants = List<String>.from(game["participants"]);
      _officialCategories = List<String>.from(game["official_categories"]);
      _customCategories = List<String>.from(game["custom_categories"]);
      _selectedCategories = _officialCategories + _customCategories;
    }
  }

  void quizOptionsUpdate() {
    if (_currentQuizOptions.isEmpty) {
      _currentQuizOptions
          .add(Answer(answerText: currentAnswers[0], questionScore: 10));
      for (int i = 1; i < currentAnswers.length; i++) {
        _currentQuizOptions
            .add(Answer(answerText: currentAnswers[i], questionScore: 0));
      }
      _currentQuizOptions.shuffle();
      _currentQuizOptions.insert(
          0, Question(gameQuestions[questionIndex], questionIndex + 1));
    }
  }
}
