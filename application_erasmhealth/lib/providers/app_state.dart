import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;

  double score = 75; // mock starting score

  void login() {
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    score = 75; // reset
    notifyListeners();
  }

  void addDrink() {
    score -= 10;
    if (score < 0) score = 0;
    notifyListeners();
  }

  void recover() {
    score += 5;
    if (score > 100) score = 100;
    notifyListeners();
  }
}