import 'dart:convert';
import 'package:dapbeton/pages/cart_page.dart';
import 'package:dapbeton/pages/midtrans_payment_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

class ProductDetail1 extends StatefulWidget {
  final String title;
  final String description;
  final String price;
  final String image;

  const ProductDetail1({
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  @override
  State<ProductDetail1> createState() => _ProductDetail1State();
}

class _ProductDetail1State extends State<ProductDetail1> {
  int quantity = 1;

  void incrementQuantity() => setState(() => quantity++);
  void decrementQuantity() => setState(() {
        if (quantity > 1) quantity--;
      });

  // Fungsi untuk mengubah harga dengan menghapus simbol dan karakter lain
  double parsePrice(String price) {
    // Menghapus semua karakter selain angka dan koma
    String cleanedPrice = price.replaceAll(RegExp(r'[^\d]'), '');
    // Mengonversi string yang sudah dibersihkan ke double
    return double.parse(cleanedPrice);
  }

  Future<void> addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token tidak tersedia, silakan login ulang."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_name': widget.title,
          'price': parsePrice(widget.price), // Menggunakan fungsi parsePrice
          'quantity': quantity,
          'image': widget.image,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil ditambahkan ke keranjang!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<String> ketentuan = [
      "Untuk wilayah Tangerang Seberang, L2, dan L3 harga naik/tambah Rp50.000/M3.",
      "Untuk wilayah Tangerang Kota harga naik/tambah Rp70.000/M3.",
      "Untuk wilayah Masuk BAKAU harga naik/tambah Rp100.000/M3.",
      "Harga belum termasuk PPN 11%.",
      "Slump 10 ± 2 cm.",
      "Harga sudah termasuk pengujian sample beton di Laboratorium DAP Beton.",
      "Pengujian sample beton di laboratorium lain menjadi tanggung jawab pemesan.",
      "Harga dapat berubah sewaktu-waktu sesuai kenaikan harga semen, material batu, pasir, dan BBM.",
      "Pemakaian Concrete Pump minimal 40 M3 = Rp6.000.000.",
      "Jika lebih dari 40 M3, dikenakan biaya tambahan Rp. 50.000/M3."
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F7F7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Detail Produk',
            style: GoogleFonts.poppins(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double padding = constraints.maxWidth > 600 ? 32 : 16;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(widget.image,
                              fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        widget.title,
                        style: GoogleFonts.lato(
                          fontSize: min(screenWidth * 0.045, 24),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.description,
                        style: GoogleFonts.poppins(
                          fontSize: min(screenWidth * 0.030, 16),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Text(
                        widget.price,
                        style: GoogleFonts.lato(
                          fontSize: min(screenWidth * 0.038, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.black),
                            onPressed: decrementQuantity,
                          ),
                          Text('$quantity',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.black),
                            onPressed: incrementQuantity,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 211, 47, 47),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text('Tambah ke Keranjang',
                            style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                      const SizedBox(height: 30),
                      Text("Ketentuan:",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                      const SizedBox(height: 10),
                      ...ketentuan.map((item) => Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text("• $item",
                                style: GoogleFonts.roboto(
                                    fontSize: 13, color: Colors.black)),
                          )),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MidtransPaymentPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 211, 47, 47),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                          ),
                          child: Text('Lanjut ke Pembayaran',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
