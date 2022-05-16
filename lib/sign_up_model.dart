import 'package:flutter/cupertino.dart';

class SignUpModel extends ChangeNotifier {

  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secondPasswordController = TextEditingController();

  TextEditingController get userNameController => _userNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get secondPasswordController => _secondPasswordController;

}
