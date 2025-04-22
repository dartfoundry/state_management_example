import 'package:flutter/widgets.dart';
import 'package:state_management_example/state/state_store.dart';

/// A class to hold store instances by their type
class StateManager {
  final Map<Type, StateStore<dynamic>> _stores = {};

  /// Register a state store with a specific type
  void register<T>(StateStore<T> store) {
    _stores[T] = store;
  }

  /// Get a store by type
  StateStore<T> get<T>() {
    final store = _stores[T];
    if (store == null) {
      throw FlutterError(
        'No StateStore<$T> was found in the StateManager. '
        'Make sure to register it before accessing.',
      );
    }
    return store as StateStore<T>;
  }

  /// Dispose all registered state stores
  void dispose() {
    for (final store in _stores.values) {
      store.dispose();
    }
    _stores.clear();
  }
}
