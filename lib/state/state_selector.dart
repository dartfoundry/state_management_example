import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:state_management_example/state/state_provider.dart';

/// Selector that rebuilds only when selected value from a specific state store changes.
class StateSelector<T, R> extends StatefulWidget {
  final R Function(T state) selector;
  final Widget Function(BuildContext context, R selectedValue) builder;

  const StateSelector({super.key, required this.selector, required this.builder});

  @override
  State<StateSelector<T, R>> createState() => _StateSelectorState<T, R>();
}

class _StateSelectorState<T, R> extends State<StateSelector<T, R>> {
  late R _selectedValue;
  Widget? _lastBuiltWidget;
  bool _didUpdateDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didUpdateDependencies) {
      final store = StateProvider.of<T>(context);
      _selectedValue = widget.selector(store.state);
      _didUpdateDependencies = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StateProvider.of<T>(context);

    return StreamBuilder<T>(
      stream: store.stream,
      initialData: store.state,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.6),
              child: const ShadProgress(),
            ),
          );
        }

        // Extract the value using the selector
        final newSelectedValue = widget.selector(data);

        // Only rebuild if the selected value has changed
        if (_lastBuiltWidget == null || !_areEqual(newSelectedValue, _selectedValue)) {
          debugPrint('Rebuilding ${widget.runtimeType} because selected value changed');
          _selectedValue = newSelectedValue;
          _lastBuiltWidget = widget.builder(context, _selectedValue);
        } else {
          debugPrint('Skipping rebuild of ${widget.runtimeType} - selected value unchanged');
        }

        return _lastBuiltWidget!;
      },
    );
  }

  // Custom equality check that handles various types
  bool _areEqual(R a, R b) {
    if (a == b) return true;

    // Handle lists (deep comparison)
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    // Handle maps (deep comparison)
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || a[key] != b[key]) return false;
      }
      return true;
    }

    return false;
  }
}
