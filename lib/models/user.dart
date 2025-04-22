class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  bool get isAuthenticated => id.isNotEmpty;

  // Anonymous user
  static const User anonymous = User(id: '', name: '', email: '');
}
