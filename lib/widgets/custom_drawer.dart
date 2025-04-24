import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_service.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/order_history_page.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<Map<String, dynamic>?> _userData;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _userData = userService.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildHeader("Memuat...", "Memuat...", null);
              } else if (snapshot.hasError || snapshot.data == null) {
                return _buildHeader("Gagal Memuat", "Coba lagi", null);
              } else {
                final userData = snapshot.data!;
                return _buildHeader(
                  userData['nama'] ?? "Nama Tidak Ditemukan",
                  userData['email'] ?? "Email Tidak Ditemukan",
                  userData['profile_picture'],
                );
              }
            },
          ),
          _buildMenuItem(Icons.home, "Home", () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          }),
          _buildMenuItem(Icons.history, "Riwayat Pemesanan", () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderHistoryPage()));
          }),
          _buildMenuItem(Icons.logout, "Logout", () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          }),
          Divider(),
          _buildMenuItem(Icons.delete, "Hapus Akun", () {
            _deleteAccount(context);
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String email, String? profilePicture) {
    return UserAccountsDrawerHeader(
      accountName: Text(name),
      accountEmail: Text(email),
      currentAccountPicture: CircleAvatar(
        backgroundImage: profilePicture != null && profilePicture.isNotEmpty
            ? NetworkImage(profilePicture)
            : null,
        backgroundColor: Colors.white,
        child: profilePicture == null || profilePicture.isEmpty
            ? Icon(Icons.person, size: 50, color: Colors.red)
            : null,
      ),
      decoration: BoxDecoration(color: Colors.red),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.black)),
      onTap: onTap,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Anda belum login!")));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Akun'),
        content: Text('Apakah Anda yakin ingin menghapus akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse("http://localhost:5000/api/auth/users/$userId"),
          headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          await prefs.clear();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus akun!")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan!")));
      }
    }
  }
}
