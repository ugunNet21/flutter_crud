import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api/product-service'; 

  Future<List> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create product');
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }
}
