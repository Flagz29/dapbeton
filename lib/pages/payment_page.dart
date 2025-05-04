import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key, required double totalPrice}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _total = 0.0;
  bool _isLoading = true;
  String _errorMessage = '';
  String? _selectedPaymentMethod;
  final currencyFormat = NumberFormat("#,##0", "id_ID");

  @override
  void initState() {
    super.initState();
    _fetchCartTotal();
  }

  Future<void> _fetchCartTotal() async {
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
        Uri.parse('http://localhost:5000/api/cart/total'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success']) {
        setState(() {
          _subtotal = (data['data']['subtotal'] as num).toDouble();
          _tax = (data['data']['tax'] as num).toDouble();
          _total = (data['data']['total'] as num).toDouble();
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data total');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu', 
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
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

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': _total,
          'tax': _tax,
          'subtotal': _subtotal,
          'payment_method': _selectedPaymentMethod,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success']) {
        Navigator.pushReplacementNamed(context, '/payment-success');
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memproses pembayaran');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses pembayaran', 
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? const Color(0xFFD32F2F) : Colors.black,
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedPaymentMethod == value 
              ? const Color(0xFFD32F2F) 
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD32F2F)),
        title: Text(title, style: GoogleFonts.poppins()),
        trailing: _selectedPaymentMethod == value
            ? const Icon(Icons.check_circle, color: Color(0xFFD32F2F))
            : null,
        onTap: () {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
      ),
    );
  }

  Widget _buildPaymentDetailCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Subtotal', 'Rp ${currencyFormat.format(_subtotal)}'),
            const Divider(height: 20, thickness: 1),
            _buildDetailRow('PPN (11%)', 'Rp ${currencyFormat.format(_tax)}'),
            const Divider(height: 20, thickness: 1),
            _buildDetailRow(
              'Total Pembayaran',
              'Rp ${currencyFormat.format(_total)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metode Pembayaran',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPaymentMethodTile(
          icon: Icons.credit_card,
          title: 'Kartu Kredit/Debit',
          value: 'credit_card',
        ),
        _buildPaymentMethodTile(
          icon: Icons.account_balance,
          title: 'Transfer Bank',
          value: 'bank_transfer',
        ),
        _buildPaymentMethodTile(
          icon: Icons.qr_code,
          title: 'QRIS',
          value: 'qris',
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Konfirmasi Pembayaran',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Pembayaran', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _errorMessage.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Pembayaran',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPaymentDetailCard(),
                      const SizedBox(height: 30),
                      _buildPaymentMethodSection(),
                      const SizedBox(height: 30),
                      _buildConfirmButton(),
                    ],
                  ),
                ),
    );
  }
}