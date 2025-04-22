import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:state_management_example/screens/home_screen.dart';
import 'package:state_management_example/state/state_manager.dart';
import 'package:state_management_example/state/state_provider.dart';
import 'package:state_management_example/state/state_store.dart';
import 'package:state_management_example/state/states/auth_state.dart';
import 'package:state_management_example/state/states/cart_state.dart';
import 'package:state_management_example/state/states/product_state.dart';

class ShopApp extends StatelessWidget {
  // Create a state manager and register all state stores
  final StateManager stateManager =
      StateManager()
        ..register<AuthState>(StateStore<AuthState>(AuthState()))
        ..register<ProductState>(StateStore<ProductState>(ProductState()))
        ..register<CartState>(StateStore<CartState>(CartState()));

  ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Make the state manager available to all widgets in the widget tree
    return StateProvider(
      stateManager: stateManager,
      child: ShadApp(
        title: 'Shop App',
        darkTheme: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadZincColorScheme.dark(),
        ),
        theme: ShadThemeData(
          brightness: Brightness.light,
          colorScheme: const ShadZincColorScheme.light(),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
