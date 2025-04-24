import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final currencyFormat = NumberFormat("#,##0", "id_ID");

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
      final double price = double.tryParse(item['price'].toString()) ?? 0.0;
      final int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      return sum + (price * quantity);
    });
  }

  Future<void> fetchCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _cartItems = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal mengambil data keranjang';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }
  Future<void> deleteCartItem(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) return;

  try {
    final response = await http.delete(
      Uri.parse('http://localhost:5000/api/cart/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Update state sebelum response untuk animasi yang lebih smooth
      setState(() {
        _cartItems.removeWhere((item) => item['id'].toString() == id);
      });
    } else {
      // Handle error response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus item: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // Handle network error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  Future<void> _showDeleteConfirmation(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Item',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus item ini?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus',
                style: GoogleFonts.poppins(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteCartItem(id);
    }
  }



Future<void> updateQuantity(String itemId, int newQuantity) async {
  if (newQuantity < 1) return;
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) return;

  try {
    final response = await http.put(
      Uri.parse('http://localhost:5000/api/cart/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'quantity': newQuantity}),
    );

    if (response.statusCode == 200) {
      final updatedItem = json.decode(response.body);
      setState(() {
        final index = _cartItems.indexWhere(
          (item) => item['id'].toString() == itemId
        );
        if (index != -1) {
          _cartItems[index] = updatedItem;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
      // Revert to previous quantity
      fetchCart();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
    fetchCart();
  }
}

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final response = await http.delete(
      Uri.parse('http://localhost:5000/api/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _cartItems.clear();
      });
    }
  }

  Future<void> _showClearAllConfirmation() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Semua Item',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
            'Apakah Anda yakin ingin menghapus semua item di keranjang?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus Semua',
                style: GoogleFonts.poppins(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F7F7),
        centerTitle: true,
        title: Text('Keranjang',
            style: GoogleFonts.poppins(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _cartItems.isEmpty
                  ? Center(
                      child: Text('Keranjang kosong',
                          style: GoogleFonts.poppins()))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 4)
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item['image'] ?? '',
                                        width: 200,
                                        height: 112.5,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.fastfood,
                                                    size: 40),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['product_name'],
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Rp ${currencyFormat.format(double.tryParse(item['price'].toString()) ?? 0)}",
                                            style: GoogleFonts.poppins(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove,
                                                    size: 20),
                                                onPressed: () {
                                                  int currentQty = int.tryParse(
                                                          item['quantity']
                                                              .toString()) ??
                                                      1;
                                                  if (currentQty > 1) {
                                                    updateQuantity(
                                                        item['id'].toString(),
                                                        currentQty - 1);
                                                  } else {
                                                    _showDeleteConfirmation(
                                                        item['id'].toString());
                                                  }
                                                },
                                              ),
                                              Text('${item['quantity']}',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 14)),
                                              IconButton(
                                                icon: Icon(Icons.add, size: 20),
                                                onPressed: () {
                                                  int currentQty = int.tryParse(
                                                          item['quantity']
                                                              .toString()) ??
                                                      0;
                                                  updateQuantity(
                                                      item['id'].toString(),
                                                      currentQty + 1);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.grey),
                                      onPressed: () => _showDeleteConfirmation(
                                          item['id'].toString()),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total",
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      "Rp ${currencyFormat.format(totalPrice)}",
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _showClearAllConfirmation,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.redAccent),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: Text("Hapus Semua",
                                          style: GoogleFonts.poppins(
                                              color: Colors.redAccent)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/checkout');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: Text("Bayar Sekarang",
                                          style: GoogleFonts.poppins(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
        ),
      ),
    );
  }
}
