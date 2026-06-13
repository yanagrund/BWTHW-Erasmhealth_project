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

    // Day -1 is "today's" score; history starts at day -2.
    final end = DateTime.now().subtract(const Duration(days: 2));
    final start = end.subtract(Duration(days: days - 1));

    // 4 parallel daterange requests instead of days×4 individual requests.
    final perDayData = await impactService.fetchHealthDataForRange(start, end);

    // Populate per-day cache so the Yesterday tab reuses these results.
    for (final entry in perDayData.entries) {
      _historyCache.putIfAbsent(entry.key, () => Future.value(entry.value));
    }

    if (perDayData.isEmpty) {
      return {"sleep": 0.0, "heart": 70.0, "resting": 70.0, "steps": 0};
    }

    double totalSleep = 0, totalHeart = 0, totalResting = 0;
    int totalSteps = 0;

    for (final data in perDayData.values) {
      totalSleep += (data["sleep"] as num).toDouble();
      totalHeart += (data["heart"] as num).toDouble();
      totalResting += (data["resting"] as num).toDouble();
      totalSteps += data["steps"] as int;
    }

    final count = perDayData.length;
    return {
      "sleep": totalSleep / count,
      "heart": totalHeart / count,
      "resting": totalResting / count,
      "steps": (totalSteps / count).toInt(),
    };
  }

  void clearCache() {
    _historyCache.clear();
  }
}
