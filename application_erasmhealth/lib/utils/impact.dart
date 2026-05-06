import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//username: zuoMU0WcFe
//password: 12345678!

class Impact {
  final String baseUrl = 'https://impact.dei.unipd.it/bwthw/';

  // authentication
  final String pingEndpoint = 'gate/v1/ping/';
  final String tokenEndpoint = 'gate/v1/token/';
  final String refreshEndpoint = 'gate/v1/refresh/';

  // data endpoints
  final String stepsEndpoint = 'data/v1/steps/patients/';
  final String sleepEndpoint = 'data/v1/sleep/patients/';
  final String heartRateEndpoint = 'data/v1/heart_rate/patients/';
  final String restingHeartRateEndpoint = 'data/v1/resting_heart_rate/patients/';

  // username
  final String username = 'zuoMU0WcFe';

  String getTodayDate() { // Returns date in YYYY-MM-DD format
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<String?> getToken() async { // Retrieves the access token from shared preferences
    final sp = await SharedPreferences.getInstance();
    return sp.getString('access');
  }

  Future<http.Response> _authorizedGet(String url) async { // Makes an authorized GET request to the given URL
    final token = await getToken();

    return await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }

  Future<bool> isUp() async { // Checks if the API is up by pinging the endpoint
    final response = await http.get(Uri.parse(baseUrl + pingEndpoint));
    return response.statusCode == 200;
  } 

  Future<bool> login(String username, String password) async { // Logs in the user by sending a POST request to the token endpoint with the provided username and password
    final response = await http.post(
      Uri.parse(baseUrl + tokenEndpoint),
      body: {
        'username': username,
        'password': password,
      },
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

  Future<bool> refreshToken() async { // Refreshes the access token using the refresh token stored in shared preferences. If the refresh token is valid, it updates the access and refresh tokens in shared preferences and returns true. Otherwise, it returns false.
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

  Future<void> logout() async { // Logs out the user by removing the access and refresh tokens from shared preferences
    final sp = await SharedPreferences.getInstance();
    await sp.remove('access');
    await sp.remove('refresh');
  }

  Future<int> getSteps() async { // Retrieves the total number of steps for the current day by making an authorized GET request to the steps endpoint. It parses the JSON response and sums up the values of the "value" field in the "data" array. If there is no data, it returns 0.
    final day = getTodayDate();

    final response = await _authorizedGet(
        "$baseUrl$stepsEndpoint$username/day/$day/");

    final json = jsonDecode(response.body);

    if (json["data"] == null || json["data"].isEmpty) return 0;

    int total = 0;
    for (var item in json["data"]) {
      total += (item["value"] as num).toInt();
    }

    return total;
  }

  Future<double> getSleep() async { // Retrieves the total hours of sleep for the current day by making an authorized GET request to the sleep endpoint. It parses the JSON response and sums up the values of the "value" field in the "data" array. If there is no data, it returns 0.
    final day = getTodayDate();

    final response = await _authorizedGet(
        "$baseUrl$sleepEndpoint$username/day/$day/");

    final json = jsonDecode(response.body);

    if (json["data"] == null || json["data"].isEmpty) return 0;

    double total = 0;
    for (var item in json["data"]) {
      total += (item["value"] as num).toDouble();
    }

    return total;
  }

  Future<double> getHeartRate() async { // Retrieves the current heart rate for the current day by making an authorized GET request to the heart rate endpoint. It parses the JSON response and returns the value of the "value" field in the last item of the "data" array. If there is no data, it returns 70.
    final day = getTodayDate();

    final response = await _authorizedGet(
        "$baseUrl$heartRateEndpoint$username/day/$day/");

    final json = jsonDecode(response.body);

    if (json["data"] == null || json["data"].isEmpty) return 70;

    return (json["data"].last["value"] as num).toDouble();
  }

  Future<double> getRestingHeartRate() async { // Retrieves the resting heart rate for the current day by making an authorized GET request to the resting heart rate endpoint. It parses the JSON response and returns the value of the "value" field in the last item of the "data" array. If there is no data, it returns 70.
    final day = getTodayDate();

    final response = await _authorizedGet(
        "$baseUrl$restingHeartRateEndpoint$username/day/$day/");

    final json = jsonDecode(response.body);

    if (json["data"] == null || json["data"].isEmpty) return 70;

    return (json["data"].last["value"] as num).toDouble();
  }

  Future<Map<String, dynamic>> fetchHealthData() async { // Fetches all the health data (sleep, heart rate, resting heart rate, and steps) for the current day by calling the respective methods. It returns a map containing the values of each metric. If there is an error during the fetching process, it catches the exception and returns default values for each metric.
    try {
      final sleep = await getSleep();
      final heart = await getHeartRate();
      final resting = await getRestingHeartRate();
      final steps = await getSteps();

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
}