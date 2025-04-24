import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl = 'http://localhost:5000/api/auth'; // Sesuaikan dengan backend

  /// 🔹 Fungsi untuk mengambil profil user berdasarkan userId
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    print("Token: $token"); // Debugging
    print("User ID: $userId"); // Debugging

    if (token == null || userId == null) {
      print("Token atau userId tidak ditemukan!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/auth/profile/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("Response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      return null;
    }
  }

  /// 🔴 Fungsi untuk menghapus user berdasarkan userId
  Future<bool> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/auth/$userId'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Berhasil
      } else {
        print('⚠ Gagal menghapus akun: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠ Terjadi kesalahan saat menghapus akun: $e');
      return false;
    }
  }
  
  
}


