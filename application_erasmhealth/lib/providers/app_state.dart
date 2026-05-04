import 'package:flutter/material.dart';
import 'package:application_erasmhealth/utils/impact.dart'; 

/// Global state: connects UI ↔ ImpactService
class AppState extends ChangeNotifier {
  final Impact impactService;

  AppState(this.impactService);

  bool isLoggedIn = false;
  double score = 0; //for the moment, will be calculated with data from the watch 

  /// Login using ImpactService
  Future<bool> login(String username, String password) async {
    final success = await impactService.login(username, password);

    if (success) {
      isLoggedIn = true;
      notifyListeners(); // notify UI
    }

    return success;
  }

  /// Logout user
  Future<void> logout() async {
    await impactService.logout();

    isLoggedIn = false;
    score = 0;

    notifyListeners();
  }

  /// Mock logic (you already had this) still to  be thinked about with the data from the watch
  void addDrink() {
    score -= 10;
    if (score < 0) score = 0;
    notifyListeners();
  }

  void recover() { // this is just a mock function to increase the score, it will be calculated with the data from the watch
    score += 5;
    if (score > 100) score = 100;
    notifyListeners();
  }
}