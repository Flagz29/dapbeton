class Cart {
  final int id;
  final int userId;
  final List<CartItem> products;
  final DateTime createdAt;

  Cart({
    required this.id,
    required this.userId,
    required this.products,
    required this.createdAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var list = json['products'] as List;
    List<CartItem> productsList = list.map((i) => CartItem.fromJson(i)).toList();

    return Cart(
      id: json['id'],
      userId: json['user_id'],
      products: productsList,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map> productsJson = products.map((i) => i.toJson()).toList();

    return {
      'id': id,
      'user_id': userId,
      'products': productsJson,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CartItem {
  final String productName;
  final double price;
  final int quantity;
  final String image;

  CartItem({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productName: json['product_name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
