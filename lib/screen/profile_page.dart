import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dapbeton/widgets/custom_drawer.dart';
import 'package:dapbeton/pages/custom_footer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController umurController = TextEditingController();

  String profilePicture = "https://example.com/default-profile.png";
  bool isLoading = true;
  int? userId;
  File? _image;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString("userId");

    if (storedUserId != null) {
      int? parsedUserId = int.tryParse(storedUserId);
      if (parsedUserId != null) {
        setState(() {
          userId = parsedUserId;
        });
        fetchUserProfile();
      } else {
        print("❌ Error: userId tidak valid");
      }
    }
  }

  Future<void> fetchUserProfile() async {
    if (userId == null) return;

    final url = "http://localhost:5000/api/auth/profile/$userId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        namaController.text = data['nama'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        umurController.text = data['umur']?.toString() ?? '';
        profilePicture = data['profile_picture'] ?? profilePicture;
        isLoading = false;
      });
    } else {
      print("❌ Error mengambil profil: ${response.statusCode}");
    }
  }

  Future<void> updateProfile() async {
    if (userId == null) return;

    final response = await http.put(
      Uri.parse("http://localhost:5000/api/auth/users/$userId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nama": namaController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "umur": int.tryParse(umurController.text) ?? 0,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil berhasil diperbarui")),
      );
    } else {
      print("❌ Gagal memperbarui profil: ${response.statusCode}");
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      var request = http.MultipartRequest(
          "POST", Uri.parse("http://localhost:5000/api/auth/profile/$userId"));
      request.fields["userId"] = userId.toString();
      request.files
          .add(await http.MultipartFile.fromPath("file", pickedFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        setState(() {
          profilePicture = data["profile_picture"];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Foto profil diperbarui!")),
        );
      } else {
        print("❌ Gagal mengupload foto: ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Color(0xFFF7F7F7),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: 1000), // Max width 1000px
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 📌 Foto Profil
                        GestureDetector(
                          onTap: pickAndUploadImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : NetworkImage(profilePicture) as ImageProvider,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Klik foto untuk mengubah",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),

                        SizedBox(height: 20),
                        _buildTextField("Nama", namaController, Icons.person),
                        _buildTextField("Email", emailController, Icons.email),
                        _buildTextField("No. HP", phoneController, Icons.phone),
                        _buildTextField("Umur", umurController, Icons.cake,
                            isNumber: true),

                        SizedBox(height: 20),

                        // 📌 Tombol Simpan Perubahan (Minimalis)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: updateProfile,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              "Simpan Perubahan",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),

                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomFooter(currentIndex: 2),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
        ),
      ),
    );
  }
}
