class Product {
  final int id;
  final String name;
  final int price;
  final String description;
  final String image;
  final int stock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.stock,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Nama Produk',
      price: json['price'] as int? ?? 0,
      description: json['description'] as String? ?? 'Deskripsi tidak tersedia',
      image: json['image'] as String? ?? 'assets/placeholder.png',
      stock: json['stock'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String? ?? '2023-01-01'),
    );
  }
}
