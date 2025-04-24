import 'package:dapbeton/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'order_history_page.dart';
import 'package:dapbeton/screen/profile_page.dart';



class CustomFooter extends StatelessWidget {
  final int currentIndex;

  const CustomFooter({required this.currentIndex}); // Tambahkan parameter currentIndex

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: "Riwayat"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
      ],
      selectedItemColor: Color(0xFFD32F2F),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex, // Gunakan currentIndex dari parameter
      onTap: (index) {
        if (index == currentIndex) return; // Hindari reload jika di halaman yang sama

        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderHistoryPage()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage())); // Ganti LoginPage ke ProfilePage
        }
      },
    );
  }
}
