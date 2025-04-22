import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:state_management_example/models/cart_item.dart';
import 'package:state_management_example/models/product.dart';
import 'package:state_management_example/state/states/cart_state.dart';
import 'package:state_management_example/state/state_provider.dart';
import 'package:state_management_example/state/state_selector.dart';
import 'package:state_management_example/state/state_store.dart';
import 'package:state_management_example/utils/formatters.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            AspectRatio(
              aspectRatio: 1.5,
              child:
                  product.imageUrl.startsWith('assets')
                      ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                      : Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.secondary,
                            child: Center(
                              child: Icon(
                                LucideIcons.image,
                                size: 50.0,
                                color: theme.colorScheme.border,
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Product details
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  Text(formatCurrency(amount: product.price), style: theme.textTheme.small),
                  SizedBox(height: 8.0),
                  _buildAddToCartButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    final theme = ShadTheme.of(context);

    return StateSelector<CartState, int>(
      selector: (state) => state.getQuantity(product),
      builder: (context, quantity) {
        final cartStore = StateProvider.of<CartState>(context);

        if (quantity > 0) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ShadIconButton(
                icon: Icon(LucideIcons.minus, size: 16.0),
                onPressed: () => _decreaseQuantity(cartStore),
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    // minWidth: 50.0,
                    maxHeight: theme.inputTheme.constraints?.maxHeight ?? 40.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.border),
                    borderRadius: theme.radius,
                  ),
                  child: Center(child: Text(quantity.toString(), style: theme.textTheme.p)),
                ),
              ),

              ShadIconButton(
                icon: Icon(LucideIcons.plus, size: 16.0),
                onPressed: () => _addToCart(cartStore),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: ShadButton(onPressed: () => _addToCart(cartStore), child: Text('Add to Cart')),
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
}
