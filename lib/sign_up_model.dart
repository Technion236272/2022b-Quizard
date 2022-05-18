import 'package:flutter/cupertino.dart';

class SignUpModel extends ChangeNotifier {
  String _userId = '';
  String _userImageUrl = '';

  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secondPasswordController = TextEditingController();

  TextEditingController get userNameController => _userNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get secondPasswordController => _secondPasswordController;
  String get userId => _userId;
  String get userImageUrl => _userImageUrl;


  void setUserId(String id) {
    _userId = id;
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
}
