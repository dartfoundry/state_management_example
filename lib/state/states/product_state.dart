import 'package:state_management_example/models/product.dart';

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  List<String> get categories {
    final allCategories = <String>{};
    for (final product in products) {
      allCategories.addAll(product.categories);
    }
    return allCategories.toList()..sort();
  }

  List<Product> get filteredProducts {
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      return products;
    }
    return products.where((p) => p.categories.contains(selectedCategory)).toList();
  }

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      selectedCategory: clearCategory ? null : selectedCategory ?? this.selectedCategory,
    );
  }
}
