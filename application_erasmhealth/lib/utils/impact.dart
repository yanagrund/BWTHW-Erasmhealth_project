import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// All /day/ endpoints return this outer envelope:
// { "status": "success", "data": { "date": "YYYY-MM-DD", "data": <payload> } }
//
// The inner "data" shape differs per endpoint:
//   steps        → List  of { "time", "value" }        ("value" is a STRING)
//   heart_rate   → List  of { "time", "value", "confidence" }
//   resting_hr   → Map        { "time", "value", "error" }
//   sleep        → Map        { "minutesAsleep", "minutesAwake", ... }

class Impact {
  final String baseUrl = 'https://impact.dei.unipd.it/bwthw/';

  final String pingEndpoint = 'gate/v1/ping/';
  final String tokenEndpoint = 'gate/v1/token/';
  final String refreshEndpoint = 'gate/v1/refresh/';
  final String stepsEndpoint = 'data/v1/steps/patients/';
  final String sleepEndpoint = 'data/v1/sleep/patients/';
  final String heartRateEndpoint = 'data/v1/heart_rate/patients/';
  final String restingHeartRateEndpoint =
      'data/v1/resting_heart_rate/patients/';

  final String username = 'Jpefaq6m58';

  // ── Date helpers ─────────────────────────────────────────────────────────────

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  String getTodayDate() => _fmt(DateTime.now());
  String getYesterdayDate() =>
      _fmt(DateTime.now().subtract(const Duration(days: 1)));

  // ── Auth ──────────────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('access');
  }

  Future<http.Response> _authorizedGet(String url) async {
    final token = await getToken();
    return http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<bool> isUp() async {
    final response = await http.get(Uri.parse(baseUrl + pingEndpoint));
    return response.statusCode == 200;
  }

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl + tokenEndpoint),
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decoded['access']);
      await sp.setString('refresh', decoded['refresh']);
      return true;
    }
    return false;
  }

  Future<bool> refreshToken() async {
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    if (refresh == null) return false;

    final response = await http.post(
      Uri.parse(baseUrl + refreshEndpoint),
      body: {'refresh': refresh},
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      await sp.setString('access', decoded['access']);
      await sp.setString('refresh', decoded['refresh']);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('access');
    await sp.remove('refresh');
  }

  // ── Convenience wrappers for "today" ─────────────────────────────────────────
  // Delegate to fetchHealthDataForDate so all parsing lives in one place.

  Future<int> getSteps() async =>
      ((await fetchHealthDataForDate(getTodayDate()))["steps"] as int?) ?? 0;
  Future<double> getSleep() async =>
      ((await fetchHealthDataForDate(getTodayDate()))["sleep"] as double?) ??
      0.0;
  Future<double> getHeartRate() async =>
      ((await fetchHealthDataForDate(getTodayDate()))["heart"] as double?) ??
      70.0;
  Future<double> getRestingHeartRate() async =>
      ((await fetchHealthDataForDate(getTodayDate()))["resting"] as double?) ??
      70.0;
  Future<Map<String, dynamic>> fetchHealthData() =>
      fetchHealthDataForDate(getTodayDate());

  // ── Date-range helper ─────────────────────────────────────────────────────────
  // daterange endpoint returns the same outer wrapper but with a List under "data":
  // { "data": [ { "date": "YYYY-MM-DD", "data": [ step items... ] }, ... ] }

  Future<List<String>> findLatestDatesWithData({int count = 2}) async {
    final endDt = DateTime.now().subtract(const Duration(days: 1));
    final startDt = endDt.subtract(const Duration(days: 6));

    try {
      final response = await _authorizedGet(
        '$baseUrl$stepsEndpoint$username/daterange/start_date/${_fmt(startDt)}/end_date/${_fmt(endDt)}/',
      );

      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic>? days = json['data'] as List<dynamic>?;
      if (days == null || days.isEmpty) return [];

      final datesWithData =
          days
              .where((day) {
                final readings = day['data'] as List?;
                return readings != null && readings.isNotEmpty;
              })
              .map<String>((day) => day['date'] as String)
              .toList()
            ..sort();

      if (datesWithData.length <= count) return datesWithData;
      return datesWithData.sublist(datesWithData.length - count);
    } catch (e) {
      return [];
    }
  }

  // ── Core fetch ────────────────────────────────────────────────────────────────
  //
  // Every /day/ endpoint wraps its payload like this:
  //   { "data": { "date": "YYYY-MM-DD", "data": <inner> } }
  //
  // Confirmed inner shapes from live API responses:
  //   sleep      → Map   { "minutesAsleep": 347, "minutesAwake": 42, ... }
  //   heart_rate → List  [ { "time": "00:00:00", "value": 71, "confidence": 1 }, ... ]
  //   resting_hr → Map   { "time": "00:00:00", "value": 57.54, "error": 6.79 }
  //   steps      → List  [ { "time": "00:13:00", "value": "0" }, ... ]  ← value is a STRING

  Future<Map<String, dynamic>> fetchHealthDataForDate(String date) async {
    try {
      final results = await Future.wait([
        _authorizedGet("$baseUrl$sleepEndpoint$username/day/$date/"),
        _authorizedGet("$baseUrl$heartRateEndpoint$username/day/$date/"),
        _authorizedGet("$baseUrl$restingHeartRateEndpoint$username/day/$date/"),
        _authorizedGet("$baseUrl$stepsEndpoint$username/day/$date/"),
      ]);

      final sleepJson = jsonDecode(results[0].body) as Map<String, dynamic>;
      final heartJson = jsonDecode(results[1].body) as Map<String, dynamic>;
      final restingJson = jsonDecode(results[2].body) as Map<String, dynamic>;
      final stepsJson = jsonDecode(results[3].body) as Map<String, dynamic>;

      // Helper: safely reach json["data"]["data"]
      dynamic inner(Map<String, dynamic> j) => (j["data"] as Map?)?["data"];

      // ── Sleep ────────────────────────────────────────────────────────────────
      // Inner is a Map with top-level "minutesAsleep"
      double sleep = 0.0;
      final sleepInner = inner(sleepJson);
      if (sleepInner is Map) {
        sleep = ((sleepInner["minutesAsleep"] ?? 0) as num).toDouble() / 60.0;
      }

      // ── Heart rate ───────────────────────────────────────────────────────────
      // Inner is a List; average all "value" entries
      double heart = 70.0;
      final heartInner = inner(heartJson);
      if (heartInner is List && heartInner.isNotEmpty) {
        double sum = 0;
        for (final item in heartInner) {
          sum += (item["value"] as num).toDouble();
        }
        heart = sum / heartInner.length;
      }

      // ── Resting heart rate ───────────────────────────────────────────────────
      // Inner is a Map with "value"
      double resting = 70.0;
      final restingInner = inner(restingJson);
      if (restingInner is Map && restingInner["value"] != null) {
        resting = (restingInner["value"] as num).toDouble();
      }

      // ── Steps ────────────────────────────────────────────────────────────────
      // Inner is a List; "value" is a STRING (e.g. "0", "8") — must parse
      int steps = 0;
      final stepsInner = inner(stepsJson);
      if (stepsInner is List) {
        for (final item in stepsInner) {
          final v = item["value"];
          if (v is num) {
            steps += v.toInt();
          } else if (v is String) {
            steps += int.tryParse(v) ?? 0;
          }
        }
      }

      return {
        "sleep": sleep,
        "sleepTypes": sleepTypes,
        "heart": heart,
        "resting": resting,
        "steps": steps,
      };
    } catch (e) {
      return {
        "sleep": 0.0,
        "sleepTypes": [],
        "heart": 70.0,
        "resting": 70.0,
        "steps": 0,
      };
    }
  }
}
