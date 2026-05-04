import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Impact {
  final String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  final String pingEndpoint = 'gate/v1/ping/';
  final String tokenEndpoint = 'gate/v1/token/';
  final String refreshEndpoint = 'gate/v1/refresh/';

  /// Check if backend is reachable
  Future<bool> isUp() async {
    final url = baseUrl + pingEndpoint;

    final response = await http.get(Uri.parse(url));

    return response.statusCode == 200;
  }

  /// Perform login with user credentials
  /// If success → store tokens locally
  Future<bool> login(String username, String password) async {
    final url = baseUrl + tokenEndpoint;

    final response = await http.post(
      Uri.parse(url),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final sp = await SharedPreferences.getInstance();

      // Save tokens locally
      await sp.setString('access', decoded['access']);
      await sp.setString('refresh', decoded['refresh']);

      return true;
    }

    return false;
  }

  /// Refresh JWT tokens using stored refresh token
  Future<bool> refreshToken() async {
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');

    if (refresh == null) return false;

    final url = baseUrl + refreshEndpoint;

    final response = await http.post(
      Uri.parse(url),
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

  /// clear tokens on logout
  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('access');
    await sp.remove('refresh');
  }
}