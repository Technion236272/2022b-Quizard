import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'consts.dart';
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
    var users = FirebaseFirestore.instance.collection("$strVersion/users");
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
  List<Map<String, dynamic>> _playersMaps = [
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": ""
    },
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": ""
    },
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": ""
    },
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": ""
    },
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": ""
    }
  ];
  int _currentQuestionIndex = 0;
  bool _isPrivate = true;
  bool _isLocked = false;
  bool _enableSubmitFalseAnswer = true;
  String _pinCode = '';
  int playerIndex = 0; // Starts from 0 for admin
  int _currentPhase = 1; // 1 - Enter false answer ; 2 - Choose correct answer
  List<String> _officialCategories = [];
  List<String> _customCategories = [];
  List<String> _selectedCategories = []; // selected = official + custom
  List<String> _gameQuestions = []; // "questions" in Firestore
  List<String> _gameAnswers = []; // "answers" in Firestore
  List<Widget> _currentQuizOptions = [];

  final _falseAnswerController = TextEditingController();

  List<Map<String, dynamic>> get players => _playersMaps;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isPrivate => _isPrivate;
  bool get isLocked => _isLocked;
  bool get enableSubmitFalseAnswer => _enableSubmitFalseAnswer;
  String get pinCode => _pinCode;
  int get currentPhase => _currentPhase;
  List<String> get officialCategories => _officialCategories; // For admin
  List<String> get customCategories => _customCategories; // For admin
  List<String> get selectedCategories => _selectedCategories; // For participant
  List<String> get gameQuestions => _gameQuestions;
  List<String> get gameAnswers => _gameAnswers;
  TextEditingController get falseAnswerController => _falseAnswerController;
  List<Widget> get currentQuizOptions => _currentQuizOptions;

  // dataType should match the field in player's map
  void setDataToPlayer(String dataType, dynamic data, int index) {
    _playersMaps[index][dataType] = data;
    notifyListeners();
  }

  int getNumOfPlayers() {
    int numOfPlayers = 0;
    for (int i = 0; i < maxPlayers; i++) {
      if (_playersMaps[i]["username"] != "") {
        numOfPlayers++;
      }
    }
    return numOfPlayers;
  }

  int addNewPlayer(String username) {
    for (int i = 0; i < maxPlayers; i++) {
      if (_playersMaps[i]["username"] == "") {
        _playersMaps[i]["username"] = username;
        playerIndex = i;
        notifyListeners();
        return i;
      }
    }
    notifyListeners();
    return -1;
  }

  void removeMyself() {
    _playersMaps[playerIndex]["username"] = "";
    _playersMaps[playerIndex]["is_ready"] = false;
    _playersMaps[playerIndex]["selected_answer"] = "";
    _playersMaps[playerIndex]["false_answer"] = "";
    playerIndex = 0;
    notifyListeners();
  }

  int removeByUsername(String username) {
    for (int i = 0; i < maxPlayers; i++) {
      if (_playersMaps[i]["username"] == username) {
        _playersMaps[i]["username"] = "";
        _playersMaps[i]["is_ready"] = false;
        _playersMaps[i]["selected_answer"] = "";
        _playersMaps[i]["false_answer"] = "";
        notifyListeners();
        return i;
      }
    }
    return -1;
  }

  int getPlayerIndexByUsername(String username) {
    for (int i = 0; i < maxPlayers; i++) {
      if (players[i]["username"] == username) {
        return i;
      }
    }
    return -1;
  }

  bool areAllReady() {
    for (int i = 0; i < maxPlayers; i++) {
      if (players[i]["username"] != "") {
        if (players[i]["is_ready"] == false) {
          return false;
        }
      }
    }
    return true;
  }

  bool doesUsernameExist(String username) {
    for (int i = 0; i < maxPlayers; i++) {
      if (players[i]["username"] == username) {
        return true;
      }
    }
    return false;
  }

  set currentQuestionIndex(int value) {
    _currentQuestionIndex = value;
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
  }

  set pinCode(String value) {
    _pinCode = value;
    notifyListeners();
  }

  set currentPhase(int value) {
    _currentPhase = value;
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
  }

  void resetData() {
    _playersMaps = [
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": ""
      },
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": ""
      },
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": ""
      },
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": ""
      },
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": ""
      }
    ];
    _currentQuestionIndex = 0;
    playerIndex = 0;
    _currentPhase = 1;
    _enableSubmitFalseAnswer = true;
    _isPrivate = true;
    _isLocked = false;
    _pinCode = '';
    _officialCategories = [];
    _customCategories = [];
    _selectedCategories = [];
    _gameQuestions = [];
    _gameAnswers = [];
    _currentQuizOptions = [];
    _falseAnswerController.text = "";
    notifyListeners();
  }

  void update(DocumentSnapshot game) {
    if (game.exists) {
      for (int i = 0; i < maxPlayers; i++) {
        _playersMaps[i] = game["player$i"];
      }
      _isLocked = game["is_locked"];
      _isPrivate = game["is_private"];
      _officialCategories = List<String>.from(game["official_categories"]);
      _customCategories = List<String>.from(game["custom_categories"]);
      _selectedCategories = _officialCategories + _customCategories;
      _gameQuestions = List<String>.from(game["questions"]);
      _gameAnswers = List<String>.from(game["answers"]);
    }
  }

  List<String> getFalseAnswers() {
    List<String> falseAnswers = [];
    for (int i = 0; i < maxPlayers; i++) {
      if (players[i]["username"] != "") {
        falseAnswers.add(players[i]["false_answer"]);
      }
    }
    return falseAnswers;
  }

  List<String> getSelectedAnswers() {
    List<String> selectedAnswers = [];
    for (int i = 0; i < maxPlayers; i++) {
      if (players[i]["username"] != "") {
        selectedAnswers.add(players[i]["selected_answer"]);
      }
    }
    return selectedAnswers;
  }

  void resetFalseAnswers() {
    for (int i = 0; i < maxPlayers; i++) {
      players[i]["false_answer"] = '';
    }
  }

  void resetSelectedAnswers() {
    for (int i = 0; i < maxPlayers; i++) {
      players[i]["selected_answer"] = '';
    }
  }

  void quizOptionsUpdate() {
    List<String> falseAnswers = getFalseAnswers();
    String correctAnswer = gameAnswers[currentQuestionIndex];
    List<String> currentAnswers = [correctAnswer] + falseAnswers;
    if (_currentQuizOptions.isEmpty) {
      _currentQuizOptions
          .add(Answer(answerText: currentAnswers[0], questionScore: 10));
      for (int i = 1; i < currentAnswers.length; i++) {
        _currentQuizOptions
            .add(Answer(answerText: currentAnswers[i], questionScore: 0));
      }
      _currentQuizOptions.shuffle();
      _currentQuizOptions.insert(
          0,
          Question(
              gameQuestions[currentQuestionIndex], currentQuestionIndex + 1));
    }
  }
}
