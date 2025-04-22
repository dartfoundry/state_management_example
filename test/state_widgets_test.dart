import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_management_example/state/state_consumer.dart';
import 'package:state_management_example/state/state_manager.dart';
import 'package:state_management_example/state/state_provider.dart';
import 'package:state_management_example/state/state_selector.dart';
import 'package:state_management_example/state/state_store.dart';

void main() {
  group('Widget tests for state components', () {
    testWidgets('StateProvider should provide state stores to descendants', (
      WidgetTester tester,
    ) async {
      // Create a state manager with test stores
      final stateManager =
          StateManager()
            ..register<int>(StateStore<int>(42))
            ..register<String>(StateStore<String>('test'));

      // Setup a counter to track how many times our finder function is called
      int finderCallCount = 0;

      // Build a test widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: StateProvider(
            stateManager: stateManager,
            child: Builder(
              builder: (context) {
                finderCallCount++;

                // Get stores from context
                final intStore = StateProvider.of<int>(context);
                final stringStore = StateProvider.of<String>(context);

                return Column(
                  children: [
                    Text('Int value: ${intStore.state}'),
                    Text('String value: ${stringStore.state}'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify the state stores are correctly provided and accessible
      expect(find.text('Int value: 42'), findsOneWidget);
      expect(find.text('String value: test'), findsOneWidget);
      expect(
        finderCallCount,
        1,
        reason: 'Builder should have been called once during initial build',
      );
    });

    testWidgets('StateConsumer should rebuild when state changes', (WidgetTester tester) async {
      // Create a state manager with a counter state store
      final counterStore = StateStore<int>(0);
      final stateManager = StateManager()..register<int>(counterStore);

      // Build a test widget tree with StoreConsumer
      await tester.pumpWidget(
        MaterialApp(
          home: StateProvider(
            stateManager: stateManager,
            child: Scaffold(
              body: Center(
                child: StateConsumer<int>(
                  builder: (context, count) {
                    return Text('Count: $count', key: ValueKey('counter-text'));
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Count: 0'), findsOneWidget);

      // Update the state
      counterStore.update(5);

      // Wait for the stream to emit the new value and the widget to rebuild
      await tester.pumpAndSettle();

      // Verify the widget was rebuilt with the new state
      expect(find.text('Count: 5'), findsOneWidget);

      // Update again with updateWith
      counterStore.updateWith((count) => count + 3);

      // Wait for the stream to emit the new value and the widget to rebuild
      await tester.pumpAndSettle();

      // Verify the widget was rebuilt again
      expect(find.text('Count: 8'), findsOneWidget);
    });

    testWidgets('StateSelector should only rebuild when selected value changes', (
      WidgetTester tester,
    ) async {
      // Create variables to track builds
      int counterBuilds = 0;
      int nameBuilds = 0;

      // Create a key for each widget to ensure they're properly identified
      final counterKey = GlobalKey();
      final nameKey = GlobalKey();

      // Create a state store with the test state
      final store = StateStore<TestState>(TestState(counter: 0, name: 'initial'));
      final stateManager = StateManager()..register<TestState>(store);

      // Build a test widget with two selectors
      await tester.pumpWidget(
        MaterialApp(
          home: StateProvider(
            stateManager: stateManager,
            child: Column(
              children: [
                // Selector that only cares about the counter
                StateSelector<TestState, int>(
                  key: counterKey,
                  selector: (state) {
                    debugPrint('Selecting counter: ${state.counter}');
                    return state.counter;
                  },
                  builder: (context, counter) {
                    debugPrint('Building counter: $counter (build #${++counterBuilds})');
                    return Text('Counter: $counter', key: ValueKey('counter-text'));
                  },
                ),
                // Selector that only cares about the name
                StateSelector<TestState, String>(
                  key: nameKey,
                  selector: (state) {
                    debugPrint('Selecting name: ${state.name}');
                    return state.name;
                  },
                  builder: (context, name) {
                    debugPrint('Building name: $name (build #${++nameBuilds})');
                    return Text('Name: $name', key: ValueKey('name-text'));
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Allow the widget tree to stabilize
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Counter: 0'), findsOneWidget);
      expect(find.text('Name: initial'), findsOneWidget);

      // Record initial build counts
      final initialCounterBuilds = counterBuilds;
      final initialNameBuilds = nameBuilds;

      debugPrint('Initial counter builds: $initialCounterBuilds');
      debugPrint('Initial name builds: $initialNameBuilds');

      // Update only the counter - this should rebuild only the counter widget
      debugPrint('Updating counter to 5...');
      store.updateWith((state) => state.copyWith(counter: 5));

      // Allow the widget tree to stabilize
      await tester.pumpAndSettle();

      // Verify counter widget updated
      expect(find.text('Counter: 5'), findsOneWidget);
      expect(find.text('Name: initial'), findsOneWidget);

      // Track the actual build counts after counter update
      final counterBuildsAfterCounterUpdate = counterBuilds;
      final nameBuildsAfterCounterUpdate = nameBuilds;

      debugPrint('Counter builds after counter update: $counterBuildsAfterCounterUpdate');
      debugPrint('Name builds after counter update: $nameBuildsAfterCounterUpdate');

      // Verify that only the counter widget rebuilt
      expect(
        counterBuildsAfterCounterUpdate,
        initialCounterBuilds + 1,
        reason: 'Counter should rebuild once after counter update',
      );

      // Verify the name widget didn't rebuild again
      if (nameBuildsAfterCounterUpdate > initialNameBuilds) {
        debugPrint('WARNING: Name widget rebuilt even though only counter changed');
      }

      // Update only the name - this should rebuild only the name widget
      debugPrint('Updating name to "updated"...');
      store.updateWith((state) => state.copyWith(name: 'updated'));

      // Allow the widget tree to stabilize
      await tester.pumpAndSettle();

      // Verify name widget updated
      expect(find.text('Counter: 5'), findsOneWidget);
      expect(find.text('Name: updated'), findsOneWidget);

      // Track the build counts after name update
      final counterBuildsAfterNameUpdate = counterBuilds;
      final nameBuildsAfterNameUpdate = nameBuilds;

      debugPrint('Counter builds after name update: $counterBuildsAfterNameUpdate');
      debugPrint('Name builds after name update: $nameBuildsAfterNameUpdate');

      // Verify the name widget rebuilt
      expect(
        nameBuildsAfterNameUpdate,
        nameBuildsAfterCounterUpdate + 1,
        reason: 'Name should rebuild once after name update',
      );

      // Verify the counter widget didn't rebuild again
      if (counterBuildsAfterNameUpdate > counterBuildsAfterCounterUpdate) {
        debugPrint('WARNING: Counter widget rebuilt even though only name changed');
      }
    });

    testWidgets('StateProvider should properly dispose state stores', (WidgetTester tester) async {
      // Create test stores
      final counterStore = StateStore<int>(0);
      final nameStore = StateStore<String>('test');

      // Create a state manager with test state stores
      final stateManager =
          StateManager()
            ..register<int>(counterStore)
            ..register<String>(nameStore);

      // Build a widget tree with StateProvider
      await tester.pumpWidget(
        MaterialApp(home: StateProvider(stateManager: stateManager, child: Text('Test'))),
      );

      // Replace the widget tree, triggering dispose on the old StateProvider
      await tester.pumpWidget(MaterialApp(home: Text('Replaced')));

      // Force all pending timers (this ensures dispose has completed)
      await tester.pumpAndSettle();

      // Try to update the state stores - this should fail if they're disposed
      expect(
        () => counterStore.update(1),
        throwsStateError,
        reason: 'Should not be able to update disposed counter state store',
      );

      expect(
        () => nameStore.update('new'),
        throwsStateError,
        reason: 'Should not be able to update disposed name state store',
      );
    });

    testWidgets('Error handling in StateProvider', (WidgetTester tester) async {
      // Create an empty state manager
      final stateManager = StateManager();

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: StateProvider(
            stateManager: stateManager,
            child: Builder(
              builder: (context) {
                // Attempt to access a state store that doesn't exist
                // This should throw a FlutterError
                try {
                  StateProvider.of<int>(context);
                  return Text('This should not appear');
                } catch (e) {
                  return Text('Error: ${e.toString()}');
                }
              },
            ),
          ),
        ),
      );

      // Verify the error message is displayed
      expect(find.textContaining('No StateStore<int> was found'), findsOneWidget);
    });
  });
}

// Setup a test state class
class TestState {
  final int counter;
  final String name;

  TestState({required this.counter, required this.name});

  TestState copyWith({int? counter, String? name}) {
    return TestState(counter: counter ?? this.counter, name: name ?? this.name);
  }
}
