import 'dart:async';

import 'package:state_management_example/models/user.dart';

/// Mock authentication service
class AuthService {
  // Simulated user database
  final Map<String, String> _users = {'user@example.com': 'password123'};

  User? _currentUser;

  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null && _currentUser!.isAuthenticated;

  /// Login with email and password
  Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Check credentials
    if (!_users.containsKey(email) || _users[email] != password) {
      throw Exception('Invalid email or password');
    }

    // Create user
    _currentUser = User(id: '1', name: 'Test User', email: email);

    return _currentUser!;
  }

  /// Register new user
  Future<User> register(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Check if email already exists
    if (_users.containsKey(email)) {
      throw Exception('Email already registered');
    }

    // Register user
    _users[email] = password;

    // Create user
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
    );

    return _currentUser!;
  }

  /// Logout
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 500));
    _currentUser = null;
  }
}
