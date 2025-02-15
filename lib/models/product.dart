class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  // Factory constructor to create a Product from a JSON object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
    );
  }

  // Method to convert a Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }
}
