import 'package:flutter/material.dart';
import 'package:dapbeton/widgets/custom_drawer.dart';
import 'custom_footer.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool isProcessing = true;

  final List<Map<String, dynamic>> ongoingOrders = [
    {
      "title": "BETON MUTU B0",
      "status": "Dalam Proses",
      "price": "Rp 4.230.000",
      "quantity": "3x",
      "icon": Icons.timelapse,
      "color": Color(0xFFF7F7F7), // Background Card F7F7F7
      "textColor": Color(0xFFD32F2F), // Warna merah untuk teks status
    },
    {
      "title": "BETON MUTU B0",
      "status": "Dalam Proses",
      "price": "Rp 4.230.000",
      "quantity": "3x",
      "icon": Icons.timelapse,
      "color": Color(0xFFF7F7F7), // Background Card F7F7F7
      "textColor": Color(0xFFD32F2F), // Warna merah untuk teks status
    },
    {
      "title": "BETON MUTU B0",
      "status": "Dalam Proses",
      "price": "Rp 4.230.000",
      "quantity": "3x",
      "icon": Icons.timelapse,
      "color": Color(0xFFF7F7F7), // Background Card F7F7F7
      "textColor": Color(0xFFD32F2F), // Warna merah untuk teks status
    },
  ];

  final List<Map<String, dynamic>> completedOrders = [
    {
      "title": "BETON MUTU K 300",
      "status": "Selesai",
      "price": "Rp 5.100.000",
      "quantity": "2x",
      "icon": Icons.check_circle,
      "color": Color(0xFFF7F7F7), // Background Card F7F7F7
      "textColor": Colors.green, // Warna hijau untuk teks status
    },
    {
      "title": "BETON MUTU K 300",
      "status": "Selesai",
      "price": "Rp 5.100.000",
      "quantity": "2x",
      "icon": Icons.check_circle,
      "color": Color(0xFFF7F7F7), // Background Card F7F7F7
      "textColor": Colors.green, // Warna hijau untuk teks status
    },
    {
      "title": "BETON MUTU K 300",
      "status": "Selesai",
      "price": "Rp 5.100.000",
      "quantity": "2x",
      "icon": Icons.check_circle,
      "color": Color(0xFFF7F7F7), // Background Card F7F7F7
      "textColor": Colors.green, // Warna hijau untuk teks status
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pemesanan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Color(0xFFF7F7F7),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            
          ),
        ),
        
        actions: [
          IconButton(
              icon: Icon(Icons.shopping_cart_outlined), onPressed: () {}),
        ],
      ),
      
      
      drawer: CustomDrawer(),
      body: Container(
        color: Colors.white, // Background utama tetap putih
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                
                // Bagian Tab Section
                Container(
                  width: double.infinity, // Full width
                  color: isProcessing
                      ? Color.fromARGB(255, 255, 255, 255)
                      : Colors.white, // Sesuai dengan tab aktif
                  padding: EdgeInsets.symmetric(
                      vertical: 15), // Tambah padding agar lebih proporsional
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton("Dalam Proses", true),
                      SizedBox(width: 0),
                      _buildTabButton("Selesai", false),
                    ],
                  ),
                ),

                SizedBox(height: 19),
                // List Pesanan
                Expanded(
                  child: ListView(
                    children: (isProcessing ? ongoingOrders : completedOrders)
                        .map((order) => OrderCard(order: order))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomFooter(currentIndex: 1),
    );
  }

  Widget _buildTabButton(String title, bool isProcessingTab) {
    bool isActive = isProcessing == isProcessingTab;
    return InkWell(
      onTap: () {
        setState(() {
          isProcessing = isProcessingTab;
        });
      },
      borderRadius: BorderRadius.circular(8),
      splashColor:
          Color(0xFFD32F2F).withOpacity(0.3), // Warna merah gelap hover
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive
              ? Color(0xFFD32F2F)
              : Colors.transparent, // Warna merah tombol aktif
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: order["color"], // Background Card F7F7F7
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Status
            Container(
              decoration: BoxDecoration(
                color: order["textColor"].withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.all(8),
              child: Icon(order["icon"], color: order["textColor"], size: 24),
            ),
            SizedBox(width: 12),
            // Info Order
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order["title"],
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    order["status"],
                    style: TextStyle(color: order["textColor"], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    order["quantity"],
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            // Harga
            Text(
              order["price"],
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
