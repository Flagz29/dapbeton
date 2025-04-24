import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String baseUrl = 'http://localhost:5000/products'; // Ganti dengan URL API backend kamu

  // Fungsi untuk menyimpan produk ke database
  static Future<bool> addProduct(Map<String, String> productData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(productData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
