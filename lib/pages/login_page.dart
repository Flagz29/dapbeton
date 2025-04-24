import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'home_page.dart'; // Import halaman home
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool isPasswordVisible = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        print("Proses login dimulai...");
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "email": emailController.text,
            "password": passwordController.text
          }),
        );

        print("Response diterima: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data.containsKey('token')) {
            String token = data['token'];
            String userId = data['userId'].toString();  // Ambil ID user dari API


            // Simpan token dan userId setelah login
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token); // Simpan token JWT
            await prefs.setString('userId', userId); // Simpan ID User

            Fluttertoast.showToast(
              msg: "Login Berhasil",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );

            // Pindah ke halaman home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            print("Error: Token tidak ditemukan dalam response");
            Fluttertoast.showToast(
              msg: "Login gagal: Token tidak ditemukan",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        } else {
          print("Login gagal dengan status: ${response.statusCode}");
          Fluttertoast.showToast(
            msg: "Email atau password salah",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        print("Error saat login: $e"); // Menampilkan error di debug console
        Fluttertoast.showToast(
          msg: "Terjadi kesalahan: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Image.asset('assets/logo.png', width: 200),
                    const SizedBox(height: 21),
                    Text(
                      "Selamat datang",
                      style: GoogleFonts.mulish(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      "Masuk untuk mengakses akun Anda",
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Image.asset('assets/truck.png', width: 200),
                    const SizedBox(height: 9),
                    _buildTextField(Icons.email, "Email", emailController,
                        isEmail: true),
                    const SizedBox(height: 25),
                    _buildTextField(
                        Icons.lock, "Kata sandi", passwordController,
                        isPassword: true),
                    const SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: Color(0xFFD32F2F),
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            Text("Ingat Saya",
                                style: GoogleFonts.mulish(fontSize: 12)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            // Tambahkan fungsi lupa kata sandi di sini
                          },
                          child: Text(
                            "Lupa kata sandi?",
                            style: GoogleFonts.mulish(
                              fontSize: 12,
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Masuk",
                          style: GoogleFonts.mulish(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 23),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Belum punya akun?",
                          style: GoogleFonts.mulish(fontSize: 13),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              " Daftar sekarang",
                              style: GoogleFonts.mulish(
                                color: Color(0xFFD32F2F),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hintText, TextEditingController controller,
      {bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !isPasswordVisible : false,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[700],
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hintText tidak boleh kosong";
        }
        if (isEmail &&
            !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                .hasMatch(value)) {
          return "Masukkan email yang valid";
        }
        return null;
      },
    );
  }
}
