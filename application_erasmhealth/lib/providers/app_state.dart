import 'dart:async';
import 'package:flutter/material.dart';
import 'package:application_erasmhealth/utils/impact.dart';
import 'package:application_erasmhealth/services/health_score.dart';

class AppState extends ChangeNotifier {
  final Impact impactService;

  AppState(this.impactService);

  bool isLoggedIn = false;
  double score = 0;
  double yesterdayScore = 0;

  // health data
  double sleep = 0;
  double heart = 70;
  double resting = 70;
  int steps = 0;

  Timer? _timer;

  /// LOGIN
  Future<bool> login(String username, String password) async {
    final success = await impactService.login(username, password);

    if (success) {
      isLoggedIn = true;

      await fetchAndComputeScore(); 
      startAutoRefresh();           

      notifyListeners();
    }

    return success;
  }

  /// LOGOUT
  Future<void> logout() async {
    await impactService.logout();

    _timer?.cancel();

    isLoggedIn = false;
    score = 0;
    yesterdayScore = 0;

    notifyListeners();
  }

  Future<void> fetchAndComputeScore() async {
    final latestDates = await impactService.findLatestDatesWithData(count: 2);

    if (latestDates.isEmpty) {
      notifyListeners();
      return;
    }

    final latestDate = latestDates.last;
    final data = await impactService.fetchHealthDataForDate(latestDate);

    sleep = data["sleep"];
    heart = data["heart"];
    resting = data["resting"];
    steps = data["steps"];


    score = HealthScoreService.compute(
      sleep: sleep,
      currentHR: heart,
      restingHR: resting,
      steps: steps,
    );


    if (latestDates.length >= 2) {
      final previousDate = latestDates[latestDates.length - 2];
      final previousData = await impactService.fetchHealthDataForDate(previousDate);

      yesterdayScore = HealthScoreService.compute(
        sleep: previousData["sleep"],
        currentHR: previousData["heart"],
        restingHR: previousData["resting"],
        steps: previousData["steps"],
      );

    }


    notifyListeners();
  }

  /// auto-refresh of the score each 30 seconds
  void startAutoRefresh() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchAndComputeScore();
    });
  }
}