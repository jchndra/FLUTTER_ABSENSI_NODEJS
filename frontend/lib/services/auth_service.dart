import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  static const _baseUrl = API_BASE_URL;

  /// Login with username and password. Returns response map on success.
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}));

    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data['error'] ?? 'Login failed');
  }
}
