import 'package:state_management_example/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && runtimeType == other.runtimeType && product == other.product;

  @override
  int get hashCode => product.hashCode;
}
