import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'consts.dart';

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

  Future<void> setUp(String email, String userName, String userId, String photoUrl) async {
    var users = FirebaseFirestore.instance.collection("$strVersion/users");
    final user = <String, dynamic>{
      "answers": [],
      "categories": [],
      "email": email,
      "questions": [],
      "username": userName,
      "wins": 0,
      "DailyWins": 0,
      "photoLink" : photoUrl,
      "MonthlyWins": 0
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
  int _dailyWins = 0;
  int _monthlyWins = 0;
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
  int get dailyWins => _dailyWins;
  int get monthlyWins => _monthlyWins;

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
    _dailyWins = 0;
    _monthlyWins = 0;
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

  void setDailyWins(int dailyWins) {
    _dailyWins = dailyWins;
    notifyListeners();
  }

  void setMonthlyWins(int monthlyWins) {
    _monthlyWins = monthlyWins;
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
      "selected_answer": "",
      "score": 0,
      "round_score": 0
    },
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": "",
      "score": 0,
      "round_score": 0
    },
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": "",
      "score": 0,
      "round_score": 0
    },
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": "",
      "score": 0,
      "round_score": 0
    },
    {
      "username": "",
      "is_ready": false,
      "false_answer": "",
      "selected_answer": "",
      "score": 0,
      "round_score": 0
    }
  ];
  int currentQuestionIndex = 0;
  int roundScoreView = 0; // "+num" in end game screen 2 for correct answer
  bool _isPrivate = true;
  bool _isLocked = false;
  bool _selectedCorrectAnswer = false;
  String _selectedAnswer = "";
  bool _timeOut = false;
  String _pinCode = 'null';
  int playerIndex = 0; // Starts from 0 for admin
  List<String> _officialCategories = [];
  List<String> _customCategories = [];
  List<String> _selectedCategories = []; // selected = official + custom
  List<String> _gameQuestions = []; // "questions" in Firestore
  List<String> _gameAnswers = []; // "answers" in Firestore
  List<String> _gameCategories = []; // "categories" in Firestore
  List<Widget> currentQuizOptions = [];
  final _falseAnswerController = TextEditingController();

  List<Map<String, dynamic>> get players => _playersMaps;
  bool get isPrivate => _isPrivate;
  bool get isLocked => _isLocked;
  bool get selectedCorrectAnswer => _selectedCorrectAnswer;
  String get selectedAnswer => _selectedAnswer;
  bool get timeOut => _timeOut;
  String get pinCode => _pinCode;
  List<String> get officialCategories => _officialCategories; // For admin
  List<String> get customCategories => _customCategories; // For admin
  List<String> get selectedCategories => _selectedCategories; // For participant
  List<String> get gameQuestions => _gameQuestions;
  List<String> get gameAnswers => _gameAnswers;
  List<String> get gameCategories => _gameCategories;
  TextEditingController get falseAnswerController => _falseAnswerController;

  set players(List<Map<String, dynamic>> players) {
    _playersMaps = players;
    notifyListeners();
  }

  set timeOut(bool value) {
    _timeOut = value;
    notifyListeners();
  }

  set selectedCorrectAnswer(bool value) {
    _selectedCorrectAnswer = value;
    notifyListeners();
  }

  set selectedAnswer(String value) {
    _selectedAnswer = value;
    notifyListeners();
  }

  // dataType should match the field in player's map
  void setDataToPlayer(String dataType, dynamic data, int index) {
    _playersMaps[index][dataType] = data;
    notifyListeners();
  }

  List _bubbleSortByScore(List<List<dynamic>> list) {
    for (int i = 0; i < list.length - 1; i++) {
      for (int j = 0; j < list.length - i - 1; j++) {
        if (list[j][1].toInt() < list[j + 1][1].toInt()) {
          final temp = list[j];
          list[j] = list[j + 1];
          list[j + 1] = temp;
        }
      }
    }
    return list;
  }

  List<dynamic> getPlayersSortedByScore(bool indexesOnly) {
    List<List<dynamic>> playersList = [];
    // build usernames with scores
    for (int i = 0; i < maxPlayers; i++) {
      if (_playersMaps[i]["username"] != "") {
        if (!indexesOnly) {
          playersList.add([
            _playersMaps[i]["username"].toString(),
            _playersMaps[i]["score"].toInt()
          ]);
        } else {
          playersList.add([i, _playersMaps[i]["score"].toInt()]);
        }
      }
    }

    final sortedList = _bubbleSortByScore(playersList);

    var retValList = [];
    for (int i = 0; i < sortedList.length; i++) {
      if (indexesOnly) {
        retValList.add(sortedList[i][0].toInt());
      } else {
        retValList.add(sortedList[i][0].toString());
      }
    }

    return retValList;
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

  set isPrivate(bool value) {
    _isPrivate = value;
    notifyListeners();
  }

  set isLocked(bool value) {
    _isLocked = value;
    notifyListeners();
  }

  set pinCode(String value) {
    _pinCode = value;
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

  set gameCategories(List<String> categories) {
    _gameCategories = categories;
    notifyListeners();
  }

  void resetData() {
    _playersMaps = [
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": "",
        "score": 0,
        "round_score": 0
      },
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": "",
        "score": 0,
        "round_score": 0
      },
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": "",
        "score": 0,
        "round_score": 0
      },
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": "",
        "score": 0,
        "round_score": 0
      },
      {
        "username": "",
        "is_ready": false,
        "false_answer": "",
        "selected_answer": "",
        "score": 0,
        "round_score": 0
      }
    ];
    currentQuestionIndex = 0;
    playerIndex = 0;
    roundScoreView = 0;
    _isPrivate = true;
    _isLocked = false;
    _pinCode = 'null';
    _officialCategories = [];
    _customCategories = [];
    _selectedCategories = [];
    _gameQuestions = [];
    _gameAnswers = [];
    _gameCategories = [];
    currentQuizOptions = [];
    _falseAnswerController.text = "";
    _selectedCorrectAnswer = false;
    _selectedAnswer = "";
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
      _gameCategories = List<String>.from(game["categories"]);
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

  void addScore(int score) {
    int i = playerIndex;
    players[i]["score"] += score;
    notifyListeners();
  }
}
