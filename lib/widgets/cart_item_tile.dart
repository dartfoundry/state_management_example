import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:state_management_example/models/cart_item.dart';
import 'package:state_management_example/state/states/cart_state.dart';
import 'package:state_management_example/state/state_provider.dart';
import 'package:state_management_example/state/state_store.dart';
import 'package:state_management_example/theme/theme_color.dart';
import 'package:state_management_example/utils/formatters.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartStore = StateProvider.of<CartState>(context);
    final theme = ShadTheme.of(context);

    return Dismissible(
      key: Key('cart-item-${item.product.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        color: ThemeColor.red.asColor,
        child: Icon(LucideIcons.delete, color: theme.colorScheme.primaryForeground),
      ),
      onDismissed: (_) => _removeItem(cartStore),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: theme.radius,
          child:
              item.product.imageUrl.startsWith('asset')
                  ? Image.asset(item.product.imageUrl, fit: BoxFit.cover, width: 50.0, height: 50.0)
                  : Image.network(
                    item.product.imageUrl,
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 50.0,
                          height: 50.0,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                  ),
        ),
        title: Text(item.product.name),
        subtitle: Text(formatCurrency(amount: item.product.price)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuantityControls(cartStore, context),
            SizedBox(width: 16.0),
            SizedBox(
              width: 100.0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(formatCurrency(amount: item.total), style: theme.textTheme.p),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(StateStore<CartState> cartStore, context) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadIconButton.ghost(
          icon: Icon(LucideIcons.minus),
          onPressed: () => _decreaseQuantity(cartStore),
        ),
        Text('${item.quantity}', style: theme.textTheme.p),
        ShadIconButton.ghost(
          icon: Icon(LucideIcons.plus),
          onPressed: () => _increaseQuantity(cartStore),
        ),
      ],
    );
  }

  void _increaseQuantity(StateStore<CartState> cartStore) {
    cartStore.updateWith((state) {
      final items = List<CartItem>.from(state.items);
      final index = items.indexWhere((i) => i.product.id == item.product.id);

      if (index >= 0) {
        items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
      }

      return state.copyWith(items: items);
    });
  }

  void _decreaseQuantity(StateStore<CartState> cartStore) {
    cartStore.updateWith((state) {
      final items = List<CartItem>.from(state.items);
      final index = items.indexWhere((i) => i.product.id == item.product.id);

      if (index >= 0) {
        final newQuantity = items[index].quantity - 1;

        if (newQuantity <= 0) {
          items.removeAt(index);
        } else {
          items[index] = items[index].copyWith(quantity: newQuantity);
        }
      }

      return state.copyWith(items: items);
    });
  }

  void _removeItem(StateStore<CartState> cartStore) {
    cartStore.updateWith((state) {
      final items = List<CartItem>.from(state.items)
        ..removeWhere((i) => i.product.id == item.product.id);

      return state.copyWith(items: items);
    });
  }
}
