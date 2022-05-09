import 'package:flutter/cupertino.dart';

class LoginModel extends ChangeNotifier {
  LoginModel();

  bool _isLoggedIn = false;
  bool _isLoggingIn = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool get isLoggingIn => _isLoggingIn;
  bool get isLoggedIn => _isLoggedIn;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  void logIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logOut() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // for disabling login button
  void toggleLogging() {
    _isLoggingIn = !_isLoggingIn;
    notifyListeners();
  }
}
