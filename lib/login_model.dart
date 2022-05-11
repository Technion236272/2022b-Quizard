import 'package:flutter/cupertino.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class LoginModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoggingIn = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _profileSheetController = SnappingSheetController();

  bool get isLoggingIn => _isLoggingIn;
  bool get isLoggedIn => _isLoggedIn;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  SnappingSheetController get profileSheetController => _profileSheetController;

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
