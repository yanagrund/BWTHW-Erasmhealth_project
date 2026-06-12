import 'package:application_erasmhealth/utils/impact.dart';

class HistoryService {
  final Impact impactService;
  final Map<String, Future<Map<String, dynamic>>> _historyCache = {};

  HistoryService(this.impactService);

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<Map<String, dynamic>> fetchHistoryData(DateTime date) {
    final formattedDate = _formatDate(date);
    return _historyCache.putIfAbsent(
      formattedDate,
      () => impactService.fetchHealthDataForDate(formattedDate),
    );
  }

  Future<Map<String, dynamic>> fetchRangeData(int days) async {
    if (days <= 0) {
      return {"sleep": 0.0, "heart": 70.0, "resting": 70.0, "steps": 0};
    }

    final dateFutures = List.generate(days, (index) {
      // Offset by 2: day -1 is "today" (current score), so history starts at day -2.
      final date = DateTime.now().subtract(Duration(days: index + 2));
      return fetchHistoryData(date);
    });

    final results = await Future.wait(dateFutures);

    double totalSleep = 0;
    double totalHeart = 0;
    double totalResting = 0;
    int totalSteps = 0;

    for (final data in results) {
      totalSleep += (data["sleep"] as num).toDouble();
      totalHeart += (data["heart"] as num).toDouble();
      totalResting += (data["resting"] as num).toDouble();
      totalSteps += data["steps"] as int;
    }

    return {
      "sleep": totalSleep / days,
      "heart": totalHeart / days,
      "resting": totalResting / days,
      "steps": (totalSteps / days).toInt(),
    };
  }

  void clearCache() {
    _historyCache.clear();
  }
}
