import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:state_management_example/models/cart_item.dart';
import 'package:state_management_example/models/product.dart';
import 'package:state_management_example/state/states/cart_state.dart';
import 'package:state_management_example/state/state_provider.dart';
import 'package:state_management_example/state/state_selector.dart';
import 'package:state_management_example/state/state_store.dart';
import 'package:state_management_example/utils/formatters.dart';

class ProductScreen extends StatelessWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(product.name, style: theme.textTheme.h3)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              AspectRatio(
                aspectRatio: 1.0,
                child: Hero(
                  tag: 'product-${product.id}',
                  child:
                      product.imageUrl.startsWith('assets')
                          ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                          : Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: theme.colorScheme.secondary,
                                  child: Center(
                                    child: Icon(
                                      LucideIcons.image,
                                      size: 100.0,
                                      color: theme.colorScheme.border,
                                    ),
                                  ),
                                ),
                          ),
                ),
              ),

              // Product details
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(product.name, style: theme.textTheme.h4)),
                        Text(formatCurrency(amount: product.price), style: theme.textTheme.h4),
                      ],
                    ),

                    SizedBox(height: 16.0),

                    // Categories
                    if (product.categories.isNotEmpty) ...[
                      Wrap(
                        spacing: 8.0,
                        children:
                            product.categories
                                .map((category) => ShadBadge(child: Text(category)))
                                .toList(),
                      ),
                      SizedBox(height: 16.0),
                    ],

                    // Description
                    Text('Description', style: theme.textTheme.table),
                    SizedBox(height: 8.0),
                    Text(product.description, style: theme.textTheme.p),

                    SizedBox(height: 24.0),

                    // Add to cart action
                    _buildAddToCartSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartSection(BuildContext context) {
    final theme = ShadTheme.of(context);

    return StateSelector<CartState, int>(
      selector: (state) => state.getQuantity(product),
      builder: (context, quantity) {
        // Get a reference to the CartState store
        final cartStore = StateProvider.of<CartState>(context);

        return Row(
          children: [
            if (quantity > 0) ...[
              Text('In Cart: ', style: theme.textTheme.p),
              ShadIconButton.ghost(
                icon: Icon(LucideIcons.minus),
                onPressed: () => _decreaseQuantity(cartStore),
              ),
              Text(quantity.toString(), style: theme.textTheme.p),
              ShadIconButton.ghost(
                icon: Icon(LucideIcons.plus),
                onPressed: () => _addToCart(cartStore),
              ),
              Spacer(),
              ShadButton.outline(
                onPressed: () => _removeFromCart(cartStore),
                child: Text('Remove'),
              ),
            ] else
              Expanded(
                child: ShadButton(
                  onPressed: () => _addToCart(cartStore),
                  child: Text('Add to Cart'),
                ),
              ),
          ],
        );
      },
    );
  }

  void _addToCart(StateStore<CartState> cartStore) {
    cartStore.updateWith((state) {
      final currentItems = List<CartItem>.from(state.items);
      final index = currentItems.indexWhere((item) => item.product.id == product.id);

      if (index >= 0) {
        // Update existing item
        currentItems[index] = currentItems[index].copyWith(
          quantity: currentItems[index].quantity + 1,
        );
      } else {
        // Add new item
        currentItems.add(CartItem(product: product));
      }

      return state.copyWith(items: currentItems);
    });
  }

  void _decreaseQuantity(StateStore<CartState> cartStore) {
    cartStore.updateWith((state) {
      final currentItems = List<CartItem>.from(state.items);
      final index = currentItems.indexWhere((item) => item.product.id == product.id);

      if (index >= 0) {
        final currentQuantity = currentItems[index].quantity;
        if (currentQuantity <= 1) {
          // Remove item if quantity becomes 0
          currentItems.removeAt(index);
        } else {
          // Decrease quantity
          currentItems[index] = currentItems[index].copyWith(quantity: currentQuantity - 1);
        }
      }

      return state.copyWith(items: currentItems);
    });
  }

  void _removeFromCart(StateStore<CartState> cartStore) {
    cartStore.updateWith((state) {
      final currentItems = List<CartItem>.from(state.items)
        ..removeWhere((item) => item.product.id == product.id);

      return state.copyWith(items: currentItems);
    });
  }
}
