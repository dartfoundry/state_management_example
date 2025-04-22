import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:state_management_example/state/state_provider.dart';

/// Consumer widget that rebuilds when a specific state store changes
class StateConsumer<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T state) builder;

  const StateConsumer({super.key, required this.builder});

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
        return builder(context, data);
      },
    );
  }
}
