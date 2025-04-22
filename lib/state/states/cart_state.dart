import 'package:state_management_example/models/cart_item.dart';
import 'package:state_management_example/models/product.dart';

class CartState {
  final List<CartItem> items;
  final bool isCheckingOut;
  final String? error;

  const CartState({this.items = const [], this.isCheckingOut = false, this.error});

  double get total => items.fold(0, (sum, item) => sum + item.total);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool hasProduct(Product product) => items.any((item) => item.product.id == product.id);

  int getQuantity(Product product) {
    final item = items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    return item.quantity;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isCheckingOut,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      error: clearError ? null : error ?? this.error,
    );
  }
}
