import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://localhost:5000/api/auth";
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setInt("userId", data["userId"]); // Simpan User ID
      await prefs.setString("token", data["token"]); // Simpan Token JWT

      print("🔥 User ID disimpan: ${data["userId"]}");
      return true;
    } else {
      print("⚠ Gagal login: ${response.body}");
      return false;
    }
  }
}
