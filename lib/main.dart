import 'package:dapbeton/pages/product_detail1.dart';
import 'package:dapbeton/pages/cart_page.dart';
import 'package:dapbeton/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapbeton/pages/home_page.dart';
import 'package:dapbeton/pages/login_page.dart';
import 'package:dapbeton/screen/profile_page.dart';

void main(dynamic flutterCart) async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Cek apakah token tersimpan

  runApp(MyApp(isLoggedIn: token != null)); // Jika ada token, langsung ke Home
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DAP Beton',
      theme: ThemeData(primarySwatch: Colors.red),
      home: isLoggedIn ?HomePage() : LoginPage(), // Arahkan sesuai status login
    );
  }
}
