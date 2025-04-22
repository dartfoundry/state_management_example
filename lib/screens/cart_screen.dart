import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:state_management_example/services/api_service.dart';
import 'package:state_management_example/state/states/cart_state.dart';
import 'package:state_management_example/state/state_consumer.dart';
import 'package:state_management_example/state/state_provider.dart';
import 'package:state_management_example/state/state_store.dart';
import 'package:state_management_example/theme/theme_color.dart';
import 'package:state_management_example/utils/formatters.dart';
import 'package:state_management_example/widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Shopping Cart', style: theme.textTheme.h3)),
      body: StateConsumer<CartState>(
        builder: (context, state) {
          if (state.isCheckingOut) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.6),
                    child: const ShadProgress(),
                  ),
                  SizedBox(height: 16.0),
                  Text('Processing your order...'),
                ],
              ),
            );
          }

          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shoppingCart, size: 80.0, color: theme.colorScheme.border),
                  SizedBox(height: 16.0),
                  Text('Your cart is empty', style: theme.textTheme.lead),
                  SizedBox(height: 24.0),
                  ShadButton.outline(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.0),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => ShadSeparator.horizontal(),
                  itemBuilder: (context, index) {
                    return CartItemTile(item: state.items[index]);
                  },
                ),
              ),
              _buildOrderSummary(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartState state) {
    final cartStore = StateProvider.of<CartState>(context);
    final theme = ShadTheme.of(context);

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.0, offset: Offset(0.0, -2.0))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total (${state.itemCount} items):', style: theme.textTheme.p),
                Text(formatCurrency(amount: state.total), style: theme.textTheme.h4),
              ],
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: ShadButton.outline(
                      onPressed: () => _clearCart(cartStore),
                      child: Text('Clear Cart'),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: ShadButton(
                      onPressed: () => _checkout(cartStore),
                      child: Text('Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCart(StateStore<CartState> cartStore) {
    cartStore.updateWith((state) => state.copyWith(items: []));
  }

  Future<void> _checkout(StateStore<CartState> cartStore) async {
    // Set loading state
    cartStore.updateWith((state) => state.copyWith(isCheckingOut: true, clearError: true));

    final theme = ShadTheme.of(context);

    try {
      // Convert cart items to format expected by API
      final items =
          cartStore.state.items
              .map(
                (item) => {
                  'productId': item.product.id,
                  'quantity': item.quantity,
                  'price': item.product.price,
                },
              )
              .toList();

      // Call checkout API
      final success = await _apiService.checkout(items);

      // Check if widget is still mounted before using context
      if (!mounted) return;

      if (success) {
        // Clear cart after successful checkout
        cartStore.updateWith((state) => CartState());

        // Show success message
        ShadToaster.of(context).show(
          ShadToast(
            backgroundColor: ThemeColor.green.asColor,
            description: Row(
              children: [
                Icon(LucideIcons.check, color: theme.colorScheme.primaryForeground, size: 24.0),
                SizedBox(width: 16.0),
                Text(
                  'Order placed successfully!',
                  style: theme.textTheme.p.copyWith(color: theme.colorScheme.primaryForeground),
                ),
              ],
            ),
          ),
        );

        // Go back to product list
        Navigator.of(context).pop();
      } else {
        throw Exception('Checkout failed');
      }
    } catch (e) {
      // Check if widget is still mounted before updating state
      if (!mounted) return;

      // Handle error
      cartStore.updateWith((state) => state.copyWith(isCheckingOut: false, error: e.toString()));

      // Show error message
      ShadToaster.of(
        context,
      ).show(ShadToast.destructive(description: Text('Checkout failed: ${e.toString()}')));
    }
  }
}
