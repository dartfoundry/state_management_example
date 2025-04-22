import 'dart:async';

import 'package:state_management_example/models/product.dart';

/// Mock API service for product data
class ApiService {
  // Simulated product database
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Mercury Earbuds',
      description: 'Noise-cancelling wireless earphones',
      price: 299.99,
      imageUrl: 'assets/earbuds.jpg',
      categories: ['Electronics', 'Audio'],
    ),
    Product(
      id: '2',
      name: 'Saturn Headphones',
      description: 'Noise-cancelling wireless headphones',
      price: 699.99,
      imageUrl: 'assets/headphones.jpg',
      categories: ['Electronics', 'Audio'],
    ),
    Product(
      id: '3',
      name: 'Jupiter VR Headset',
      description: '',
      price: 1299.99,
      imageUrl: 'assets/headset.jpg',
      categories: ['Electronics', 'Visual'],
    ),
    Product(
      id: '4',
      name: 'Uranus Smartwatch',
      description: '',
      price: 389.99,
      imageUrl: 'assets/smartwatch.jpg',
      categories: ['Electronics', 'Watches'],
    ),
    Product(
      id: '5',
      name: 'Venus Speakers',
      description: '',
      price: 79.99,
      imageUrl: 'assets/speakers.jpg',
      categories: ['Electronics', 'Audio'],
    ),
    Product(
      id: '6',
      name: 'Tablet',
      description: '',
      price: 179.99,
      imageUrl: 'assets/tablet.jpg',
      categories: ['Electronics', 'Computers'],
    ),
  ];

  /// Get all products (with simulated network delay)
  Future<List<Product>> getProducts() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    return _products;
  }

  /// Get product by ID
  Future<Product?> getProduct(String id) async {
    await Future.delayed(Duration(milliseconds: 500));

    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Simulate checkout process
  Future<bool> checkout(List<Map<String, dynamic>> items) async {
    // Simulate network request
    await Future.delayed(Duration(seconds: 2));

    // Simulate successful checkout (always succeeds in this mock)
    return true;
  }
}
