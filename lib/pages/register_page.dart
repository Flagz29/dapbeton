import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isChecked = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (!isChecked) {
        Fluttertoast.showToast(
          msg: "Harap setujui Syarat dan Ketentuan",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nama": nameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "password": passwordController.text,
          "konfirmasi password": confirmpasswordController.text
        }),
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "✅ Pendaftaran Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 63, 142, 56),
          textColor: Colors.white,
          fontSize: 16.0,
          timeInSecForIosWeb: 2,
          webBgColor: "linear-gradient(to right, #32a852, #1e7e34)",
          webPosition: "center",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Pendaftaran gagal, coba lagi",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Widget _buildTextField(
    IconData icon,
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
    Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
              ? TextInputType.phone
              : TextInputType.text,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[700]),
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
        if (isPhone && !RegExp(r"^[0-9]+$").hasMatch(value)) {
          return "Masukkan nomor handphone yang valid";
        }
        return null;
      },
    );
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
                    Text("Selamat datang",
                        style: GoogleFonts.mulish(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                    const SizedBox(height: 9),
                    Text("Mulai dengan membuat akun gratis",
                        style: GoogleFonts.mulish(
                          fontSize: 14,
                          color: Colors.grey[700],
                        )),
                    const SizedBox(height: 9),
                    Image.asset('assets/truck.png', width: 200),
                    const SizedBox(height: 9),
                    _buildTextField(Icons.person, "Nama lengkap", nameController),
                    const SizedBox(height: 25),
                    _buildTextField(Icons.email, "Email", emailController, isEmail: true),
                    const SizedBox(height: 25),
                    _buildTextField(Icons.phone, "Nomor Handphone", phoneController, isPhone: true),
                    const SizedBox(height: 25),
                    _buildTextField(Icons.lock, "Kata sandi", passwordController, isPassword: true),
                    const SizedBox(height: 17),
                    _buildTextField(
                      Icons.lock,
                      "Konfirmasi Kata sandi",
                      confirmpasswordController,
                      isPassword: true,
                      onFieldSubmitted: (_) => _register(), // Trigger saat tekan Enter
                    ),
                    const SizedBox(height: 17),
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
                        Text.rich(
                          TextSpan(
                            text: "Centang untuk menyetujui ",
                            style: GoogleFonts.mulish(fontSize: 12),
                            children: [
                              TextSpan(
                                text: "Syarat",
                                style: GoogleFonts.mulish(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: " dan "),
                              TextSpan(
                                text: "Ketentuan",
                                style: GoogleFonts.mulish(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Daftar",
                            style: GoogleFonts.mulish(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    const SizedBox(height: 23),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sudah punya akun?", style: GoogleFonts.mulish(fontSize: 13)),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(
                              " Masuk sekarang",
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
}
