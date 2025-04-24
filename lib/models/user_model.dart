class User {
  final int id;
  final String nama;
  final String email;
  final String phone;

  User({required this.id, required this.nama, required this.email, required this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
