import 'package:application_erasmhealth/utils/impact.dart';

class HistoryService {
  final Impact impactService;

  HistoryService(this.impactService);

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<Map<String, dynamic>> fetchHistoryData(DateTime date) async {
    return impactService.fetchHealthDataForDate(_formatDate(date));
  }

  Future<Map<String, dynamic>> fetchRangeData(int days) async {
    double totalSleep = 0;
    double totalHeart = 0;
    double totalResting = 0;
    int totalSteps = 0;
    int count = 0;

    for (int i = 1; i <= days; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final data = await fetchHistoryData(date);

      totalSleep += (data["sleep"] as num).toDouble();
      totalHeart += (data["heart"] as num).toDouble();
      totalResting += (data["resting"] as num).toDouble();
      totalSteps += data["steps"] as int;
      count++;
    }

    if (count == 0) {
      return {"sleep": 0.0, "heart": 70.0, "resting": 70.0, "steps": 0};
    }

    return {
      "sleep": totalSleep / count,
      "heart": totalHeart / count,
      "resting": totalResting / count,
      "steps": (totalSteps / count).toInt(),
    };
  }
}
