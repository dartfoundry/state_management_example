import 'package:flutter/widgets.dart';
import 'package:state_management_example/state/state_manager.dart';
import 'package:state_management_example/state/state_store.dart';

/// A widget that provides multiple stores to the widget tree
class StateProvider extends StatefulWidget {
  final StateManager stateManager;
  final Widget child;

  const StateProvider({super.key, required this.stateManager, required this.child});

  @override
  State<StateProvider> createState() => _StateProviderState();

  /// Get a state store from the context
  static StateStore<T> of<T>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_InheritedState>();
    if (provider == null) {
      throw FlutterError('No StateProvider found in context');
    }
    return provider.stateManager.get<T>();
  }
}

class _StateProviderState extends State<StateProvider> {
  @override
  void dispose() {
    widget.stateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedState(stateManager: widget.stateManager, child: widget.child);
  }
}

/// InheritedWidget that holds the state manager
class _InheritedState extends InheritedWidget {
  final StateManager stateManager;

  const _InheritedState({required this.stateManager, required super.child});

  @override
  bool updateShouldNotify(_InheritedState old) {
    return stateManager != old.stateManager;
  }
}
