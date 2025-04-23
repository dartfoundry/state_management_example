import 'dart:async';

import 'package:state_management_example/models/product.dart';

/// Mock API service for product data
class ApiService {
  // Simulated product database
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Mercury Earbuds',
      description:
          'Wireless Earbuds. Bluetooth 5.4 with ENC Noise canceling microphone. IP7 waterproof. Top reviewed for sound quality',
      price: 299.99,
      imageUrl: 'assets/earbuds.jpg',
      categories: ['Electronics', 'Audio'],
    ),
    Product(
      id: '2',
      name: 'Saturn Headphones',
      description:
          'Noise-cancelling wireless headphones. Impressive 60-hour battery life for extended use. Comfortable memory foam ear cups for long wear.',
      price: 699.99,
      imageUrl: 'assets/headphones.jpg',
      categories: ['Electronics', 'Audio'],
    ),
    Product(
      id: '3',
      name: 'Uranus Smartwatch',
      description:
          'Smart Fitness Watch. 1.85" for Men. Answer/Make Call. Heart Rate, Sleep Monitor, Pedometer, 120+ Sport Modes Activity Tracker, IP68 Waterproof.',
      price: 389.99,
      imageUrl: 'assets/smartwatch.jpg',
      categories: ['Electronics', 'Watches', 'Computers'],
    ),
    Product(
      id: '4',
      name: 'Jupiter VR Headset',
      description:
          'Color pass-through cameras allow you to clearly see your surroundings. High-resolution picture. Powerful processor. Comfortable design.',
      price: 1299.99,
      imageUrl: 'assets/headset.jpg',
      categories: ['Electronics', 'Visual'],
    ),
    Product(
      id: '5',
      name: 'Venus Speakers',
      description:
          'External computer speakers for amplifying PC or laptop audio. USB-Powered. In-line volume control. Scratch-free padded base. Frequency range of 80 Hz - 20 KHz; 2.4 watts of total RMS power (1.2 watts per speaker)',
      price: 79.99,
      imageUrl: 'assets/speakers.jpg',
      categories: ['Electronics', 'Audio'],
    ),
    Product(
      id: '6',
      name: 'Mars Tablet',
      description:
          'Full HD entertainment — A 10.1" 1080p display brings brilliant color to all your shows and games. Binge watch longer with 13-hour battery, 32 or 64 GB of storage, and up to 1 TB expandable storage with micro-SD card (sold separately).',
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
