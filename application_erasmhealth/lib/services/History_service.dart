import 'dart:convert';
import 'package:application_erasmhealth/utils/impact.dart';
import 'package:application_erasmhealth/services/mean.dart';
import 'package:application_erasmhealth/services/health_score.dart';

class HistoryService {
  final Impact impactService;

  HistoryService(this.impactService);

  // Helper to format any date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // New method: Fetches and averages data over a range
  Future<Map<String, dynamic>> fetchRangeData(int days) async {
    double totalSleep = 0;
    double totalHeart = 0;
    double totalResting = 0;
    int totalSteps = 0;
    int count = 0;

    for (int i = 1; i <= days; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      // Reuse your existing individual fetch logic
      final data = await fetchHistoryData(date); 
      
      totalSleep += data["sleep"];
      totalHeart += data["heart"];
      totalResting += data["resting"];
      totalSteps += data["steps"];
      count++;
    }

    return {
      "sleep": totalSleep / count,
      "heart": totalHeart / count,
      "resting": totalResting / count,
      "steps": (totalSteps / count).toInt(),
    };
  }

  Future<int> getSteps(DateTime date) async {
    final day = _formatDate(date);
    final response = await impactService.authorizedGet(
        "${impactService.baseUrl}${impactService.stepsEndpoint}${impactService.username}/day/$day/");

    final json = jsonDecode(response.body);
    if (json["data"] == null || json["data"].isEmpty) return 0;

    int total = 0;
    for (var item in json["data"]) {
      total += (item["value"] as num).toInt();
    }
    return total;
  }

  Future<double> getSleep(DateTime date) async {
    final day = _formatDate(date);
    final response = await impactService.authorizedGet(
        "${impactService.baseUrl}${impactService.sleepEndpoint}${impactService.username}/day/$day/");

    final json = jsonDecode(response.body);
    if (json["data"] == null || json["data"].isEmpty) return 0.0;

    double total = 0;
    for (var item in json["data"]) {
      total += (item["value"] as num).toDouble();
    }
    return total;
  }

  Future<double> getHeartRate(DateTime date) async {
    final day = _formatDate(date);
    final response = await impactService.authorizedGet(
        "${impactService.baseUrl}${impactService.heartRateEndpoint}${impactService.username}/day/$day/");

    final json = jsonDecode(response.body);
    if (json["data"] == null || json["data"].isEmpty) return 70.0;

    // Calculate mean (average) for the day
    double sum = 0;
    for (var item in json["data"]) {
      sum += (item["value"] as num).toDouble();
    }
    return sum / (json["data"] as List).length;
  }

  Future<double> getRestingHeartRate(DateTime date) async {
    final day = _formatDate(date);
    final response = await impactService.authorizedGet(
        "${impactService.baseUrl}${impactService.restingHeartRateEndpoint}${impactService.username}/day/$day/");

    final json = jsonDecode(response.body);
    if (json["data"] == null || json["data"].isEmpty) return 70.0;

    // Calculate mean (average) for the day
    double sum = 0;
    for (var item in json["data"]) {
      sum += (item["value"] as num).toDouble();
    }
    return sum / (json["data"] as List).length;
  }

  Future<Map<String, dynamic>> fetchHistoryData(DateTime date) async {
    try {
      final sleep = await getSleep(date);
      final heart = await getHeartRate(date);
      final resting = await getRestingHeartRate(date);
      final steps = await getSteps(date);

      return {
        "sleep": sleep,
        "heart": heart,
        "resting": resting,
        "steps": steps,
      };
    } catch (e) {
      return {
        "sleep": 0.0,
        "heart": 70.0,
        "resting": 70.0,
        "steps": 0,
      };
    }
  }
  // Add this method inside your HistoryService or as a helper in your Widget
  Future<double> getScoreForDate(DateTime date) async {
  // 1. Fetch data for that specific date using your new HistoryService
    final data = await historyService.fetchHistoryData(date);

  // 2. Compute the score locally without overwriting AppState
    double computedScore = HealthScoreService.compute(
      sleep: data["sleep"],
      currentHR: data["heart"],
      restingHR: data["resting"],
      steps: data["steps"],
      );
    return computedScore;
  }
}

