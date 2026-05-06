import 'dart:math';

class HealthScoreService {
  static double compute({
    required double sleep,
    required double currentHR,
    required double restingHR,
    required int steps,
  }) {
    double baselineHR = 70;

    double sleepScore = _sleepScore(sleep);
    double heartScore = _heartScore(currentHR, baselineHR);
    double restingScore = _restingScore(restingHR);
    double activityScore = _stepsScore(steps);

    double score =
        0.30 * sleepScore +
        0.25 * heartScore +
        0.20 * restingScore +
        0.25 * activityScore;

    //penality for possible alcohol consumption (if heart rate is elevated and sleep is poor)
    double alcoholPenalty = 0;
    if ((currentHR - baselineHR) > 10) alcoholPenalty += 10;
    if (sleep < 6) alcoholPenalty += 10;

    score -= alcoholPenalty;

    return score.clamp(0, 100);
  }

  static double _sleepScore(double h) {
    if (h >= 7 && h <= 9) return 100;
    if (h < 7) return (h / 7) * 100;
    return (9 / h) * 100;
  }

  static double _heartScore(double current, double baseline) {
    double diff = current - baseline;
    if (diff <= 0) return 100;
    if (diff >= 20) return 0;
    return 100 - (diff / 20) * 100;
  }

  static double _restingScore(double hr) {
    if (hr <= 60) return 100;
    if (hr >= 90) return 0;
    return 100 - ((hr - 60) / 30) * 100;
  }

  static double _stepsScore(int steps) {
    if (steps >= 10000) return 100;
    return (steps / 10000) * 100;
  }
}