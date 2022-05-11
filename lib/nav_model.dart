import 'package:flutter/cupertino.dart';

class NavModel extends ChangeNotifier {
  /*
  * 0 - Profile
  * 1 - Play
  * 2 - Leaderboard
  */
  int _previousIndex = 1;
  int _currentIndex = 1;
  bool onSettingIndex = false;

  int get currentIndex => _currentIndex;
  int get previousIndex => _previousIndex;

  void setIndex(int index) {
    onSettingIndex = true;
    _previousIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();
    onSettingIndex = false;
  }

  void returnToPrev() {
    if (_previousIndex != 0 && onSettingIndex == false) {
      _currentIndex = _previousIndex;
    }
    notifyListeners();
  }
}
