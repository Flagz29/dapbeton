import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MidtransPaymentPage extends StatefulWidget {
  @override
  _MidtransPaymentPageState createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  final double hargaProduk = 4230000; // Harga asli
  final double ppn = 0.11; // PPN 11%
  File? _imageFile; // File untuk bukti pembayaran
  String? selectedPaymentMethod; // Metode pembayaran terpilih

  // Fungsi untuk memilih gambar bukti pembayaran
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPembayaran = hargaProduk + (hargaProduk * ppn);

    return Scaffold(
      appBar: AppBar(
        title: Text("Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red, // Sesuaikan dengan tema aplikasi
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Pembayaran
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Harga Produk", style: TextStyle(fontSize: 14)),
                      Text("Rp ${hargaProduk.toStringAsFixed(0)}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("PPN (11%)", style: TextStyle(fontSize: 14)),
                      Text("Rp ${(hargaProduk * ppn).toStringAsFixed(0)}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        "Rp ${totalPembayaran.toStringAsFixed(0)}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Pilihan Metode Pembayaran
            Text("Pilih Metode Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
              ),
              child: Column(
                children: [
                  _buildPaymentOption("🏦 Bank Transfer", "Transfer via rekening bank"),
                  _buildPaymentOption("📱 E-Wallet", "GoPay, OVO, Dana, LinkAja"),
                  _buildPaymentOption("📸 QRIS", "Scan QR untuk pembayaran instan"),
                  _buildPaymentOption("💳 Kartu Kredit/Debit", "Visa, Mastercard"),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Upload Bukti Pembayaran (hanya untuk Bank Transfer)
            if (selectedPaymentMethod == "🏦 Bank Transfer") ...[
              Text("Upload Bukti Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("Klik untuk unggah bukti pembayaran", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: 150),
                        ),
                ),
              ),
              SizedBox(height: 20),
            ],

            // Tombol Konfirmasi Pembayaran
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedPaymentMethod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Silakan pilih metode pembayaran!"),
                      backgroundColor: Colors.red,
                    ));
                  } else if (selectedPaymentMethod == "🏦 Bank Transfer" && _imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Silakan unggah bukti pembayaran!"),
                      backgroundColor: Colors.red,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Pembayaran berhasil dikonfirmasi!"),
                      backgroundColor: Colors.green,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Konfirmasi Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk opsi pembayaran
  Widget _buildPaymentOption(String title, String subtitle) {
    return RadioListTile<String>(
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      value: title,
      groupValue: selectedPaymentMethod,
      onChanged: (value) {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
    );
  }
}
