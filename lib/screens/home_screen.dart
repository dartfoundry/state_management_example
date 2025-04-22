import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:state_management_example/models/product.dart';
import 'package:state_management_example/screens/cart_screen.dart';
import 'package:state_management_example/screens/product_screen.dart';
import 'package:state_management_example/services/api_service.dart';
import 'package:state_management_example/state/states/cart_state.dart';
import 'package:state_management_example/state/states/product_state.dart';
import 'package:state_management_example/state/state_consumer.dart';
import 'package:state_management_example/state/state_provider.dart';
import 'package:state_management_example/state/state_selector.dart';
import 'package:state_management_example/state/state_store.dart';
import 'package:state_management_example/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late StateStore<ProductState> _productStore;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (!_isInitialized) {
      _productStore = StateProvider.of<ProductState>(context);
      _loadProducts();
      _isInitialized = true;
    }
  }

  Future<void> _loadProducts() async {
    // Set loading state
    _productStore.updateWith((state) => state.copyWith(isLoading: true, clearError: true));

    try {
      final products = await _apiService.getProducts();

      // Check if the widget is still mounted before updating state
      if (!mounted) return;

      _productStore.updateWith((state) => state.copyWith(products: products, isLoading: false));
    } catch (e) {
      // Check if the widget is still mounted before updating state
      if (!mounted) return;

      _productStore.updateWith((state) => state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop App', style: theme.textTheme.h3),
        actions: [_buildCartButton(), SizedBox(width: 8.0)],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: Column(children: [_buildCategoriesFilter(), Expanded(child: _buildProductGrid())]),
      ),
    );
  }

  Widget _buildCartButton() {
    return StateSelector<CartState, int>(
      selector: (state) => state.itemCount,
      builder: (context, itemCount) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ShadButton.outline(
              leading: Icon(LucideIcons.shoppingCart),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => CartScreen()));
              },
              child: Text('Cart'),
            ),
            if (itemCount > 0)
              Positioned(top: 1.0, right: 0.0, child: ShadBadge(child: Text('$itemCount'))),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesFilter() {
    return StateConsumer<ProductState>(
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return SizedBox.shrink();
        }

        return SizedBox(
          height: 50.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              _buildCategoryChip('All', state.selectedCategory == null),
              ...state.categories.map(
                (category) => _buildCategoryChip(category, state.selectedCategory == category),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    final store = StateProvider.of<ProductState>(context);
    final theme = ShadTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category, style: theme.textTheme.small),
        selected: isSelected,
        side: BorderSide(color: theme.colorScheme.border),
        onSelected: (_) {
          if (category == 'All') {
            // When selecting "All", explicitly set selectedCategory to null
            store.updateWith((state) => state.copyWith(clearCategory: true));
          } else {
            // For other categories, set the selectedCategory normally
            store.updateWith((state) => state.copyWith(selectedCategory: category));
          }
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return StateConsumer<ProductState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.6),
              child: const ShadProgress(),
            ),
          );
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.error}'),
                SizedBox(height: 16.0),
                ShadButton(onPressed: _loadProducts, child: Text('Retry')),
              ],
            ),
          );
        }

        final products = state.filteredProducts;

        if (products.isEmpty) {
          return Center(child: Text('No products found'));
        }

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: products.length,
          itemBuilder:
              (ctx, i) => ProductCard(
                product: products[i],
                onTap: () => _navigateToProductDetail(products[i]),
              ),
        );
      },
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductScreen(product: product)));
  }
}
