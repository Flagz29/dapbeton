import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final res = await http.get(
      Uri.parse('http://localhost:5000/api/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        cartItems = data.map((item) {
          item['selected'] = item['selected'] ?? false;
          return item;
        }).toList();
        calculateTotal();
      });
    }
  }

  void calculateTotal() {
    totalPrice = 0;
    for (var item in cartItems) {
      if (item['selected'] == true) {
        totalPrice += double.parse(item['price']) * item['quantity'];
      }
    }
  }

  Future<void> updateCartItem(int cartId, int quantity, bool selected) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await http.put(
      Uri.parse('http://localhost:5000/api/cart/$cartId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'quantity': quantity,
        'selected': selected,
      }),
    );

    fetchCartItems();
  }

  Future<void> deleteCartItem(int cartId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: const Text(
                  'Apakah Anda yakin ingin menghapus item ini dari keranjang?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Hapus',
                        style: TextStyle(color: Colors.red))),
              ],
            ));

    if (confirm == true) {
      final res = await http.delete(
        Uri.parse('http://localhost:5000/api/cart/$cartId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        fetchCartItems();
      }
    }
  }

  Future<void> deleteAllCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Hapus Semua Keranjang'),
              content: const Text(
                  'Apakah Anda yakin ingin menghapus semua item di keranjang?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Tidak')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ya')),
              ],
            ));

    if (confirm ?? false) {
      final res = await http.delete(
        Uri.parse('http://localhost:5000/api/cart/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        fetchCartItems();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Semua item telah dihapus dari keranjang!'),
          backgroundColor: Colors.green,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: isWideScreen ? 1000 : screenWidth),
          child: cartItems.isEmpty
              ? const Center(child: Text("Keranjang kosong"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['image'],
                                    width: isWideScreen ? 190 : 130,
                                    height: isWideScreen ? 100 : 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Rp ${item['price']}",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 211, 47, 47),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            onPressed: () {
                                              if (item['quantity'] > 1) {
                                                updateCartItem(
                                                    item['id'],
                                                    item['quantity'] - 1,
                                                    item['selected']);
                                              }
                                            },
                                          ),
                                          Text('${item['quantity']}'),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.add_circle_outline),
                                            onPressed: () {
                                              updateCartItem(
                                                  item['id'],
                                                  item['quantity'] + 1,
                                                  item['selected']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Checkbox(
                                      value: item['selected'] == true,
                                      onChanged: (val) {
                                        updateCartItem(item['id'],
                                            item['quantity'], val ?? false);
                                      },
                                      activeColor: const Color.fromARGB(
                                          255, 211, 47, 47),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color:
                                              Color.fromARGB(255, 211, 47, 47)),
                                      onPressed: () {
                                        deleteCartItem(item['id']);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Rp ${totalPrice.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 211, 47, 47),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: deleteAllCartItems,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 211, 47, 47),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: const Text(
                                    'Hapus Semua',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CartPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: const Text(
                                    'Bayar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
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
