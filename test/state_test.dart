import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_management_example/state/state_manager.dart';
import 'package:state_management_example/state/state_store.dart';

void main() {
  group('Store', () {
    test('should initialize with initial state', () {
      final store = StateStore<int>(42);
      expect(store.state, 42);
    });

    test('should update state and notify listeners', () async {
      final store = StateStore<int>(10);

      // Create a completer to get notified when a specific value is received
      final completer20 = Completer<int>();
      final completer25 = Completer<int>();

      // Listen to the store stream
      final subscription = store.stream.listen((value) {
        if (value == 20) completer20.complete(value);
        if (value == 25) completer25.complete(value);
      });

      // Verify initial state directly
      expect(store.state, 10);

      // Update the state
      store.update(20);

      // Wait for the value with timeout
      final value20 = await completer20.future.timeout(
        Duration(seconds: 5),
        onTimeout: () => -1, // Use a sentinel value on timeout
      );
      expect(value20, 20, reason: 'Stream should emit 20 after update');

      // Update with a function
      store.updateWith((current) => current + 5);

      // Wait for the next value with timeout
      final value25 = await completer25.future.timeout(
        Duration(seconds: 5),
        onTimeout: () => -1, // Use a sentinel value on timeout
      );
      expect(value25, 25, reason: 'Stream should emit 25 after updateWith');

      // Clean up
      subscription.cancel();
      store.dispose();
    });

    test('should handle complex state objects', () {
      final initialState = TestState(name: 'Initial', count: 0);
      final store = StateStore<TestState>(initialState);

      expect(store.state.name, 'Initial');
      expect(store.state.count, 0);

      // Update with a new state object
      store.update(TestState(name: 'Updated', count: 1));
      expect(store.state.name, 'Updated');
      expect(store.state.count, 1);

      // Update with a reducer function
      store.updateWith((state) => state.copyWith(count: state.count + 1));
      expect(store.state.name, 'Updated');
      expect(store.state.count, 2);

      store.dispose();
    });
  });

  group('StoreManager', () {
    test('should register and retrieve stores by type', () {
      final manager = StateManager();

      // Register different types of stores
      final counterStore = StateStore<int>(0);
      final userStore = StateStore<UserState>(UserState(id: '1', name: 'Test User'));
      final settingsStore = StateStore<SettingsState>(SettingsState(isDarkMode: false));

      manager.register<int>(counterStore);
      manager.register<UserState>(userStore);
      manager.register<SettingsState>(settingsStore);

      // Retrieve stores and verify they are the correct instances
      expect(manager.get<int>(), counterStore);
      expect(manager.get<UserState>(), userStore);
      expect(manager.get<SettingsState>(), settingsStore);

      // Verify the state is correctly stored
      expect(manager.get<int>().state, 0);
      expect(manager.get<UserState>().state.name, 'Test User');
      expect(manager.get<SettingsState>().state.isDarkMode, false);

      // Clean up
      manager.dispose();
    });

    test('should throw error when retrieving unregistered store', () {
      final manager = StateManager();

      expect(() => manager.get<String>(), throwsA(isA<FlutterError>()));

      // Clean up
      manager.dispose();
    });

    test('should dispose all registered stores', () {
      final manager = StateManager();

      // Create stores
      final counterStore = StateStore<int>(0);
      final userStore = StateStore<UserState>(UserState(id: '1', name: 'Test User'));

      manager.register<int>(counterStore);
      manager.register<UserState>(userStore);

      // Dispose all stores via manager
      manager.dispose();

      // Try to use the stores after disposal - this should fail
      // Note: We're testing if state updates are rejected after disposal,
      // not if listening to the stream throws an error
      expect(() => counterStore.update(5), throwsStateError);

      expect(() => userStore.update(UserState(id: '2', name: 'New User')), throwsStateError);
    });

    test('should update state through manager correctly', () {
      final manager = StateManager();

      final counterStore = StateStore<int>(0);
      manager.register<int>(counterStore);

      // Update through the store instance obtained from manager
      final retrievedStore = manager.get<int>();
      retrievedStore.update(42);

      // Verify state was updated in both references
      expect(retrievedStore.state, 42);
      expect(counterStore.state, 42);

      // Update using updateWith
      retrievedStore.updateWith((current) => current * 2);

      // Verify state was updated again
      expect(retrievedStore.state, 84);
      expect(counterStore.state, 84);

      // Clean up
      manager.dispose();
    });
  });

  group('Integration: Store and StoreManager', () {
    test('should maintain consistency between store instances', () {
      final manager = StateManager();

      // Register a store
      final originalStore = StateStore<TestState>(TestState(name: 'Initial', count: 0));
      manager.register<TestState>(originalStore);

      // Get the store via manager
      final retrievedStore = manager.get<TestState>();

      // Update via the retrieved store
      retrievedStore.updateWith((state) => state.copyWith(name: 'Updated via manager'));

      // Both references should have the updated state
      expect(originalStore.state.name, 'Updated via manager');
      expect(retrievedStore.state.name, 'Updated via manager');

      // Update via the original store
      originalStore.updateWith((state) => state.copyWith(count: 999));

      // The update should be reflected in both references
      expect(originalStore.state.count, 999);
      expect(retrievedStore.state.count, 999);

      // Clean up
      manager.dispose();
    });

    test('should properly handle multiple state types', () {
      final manager = StateManager();

      // Register multiple state types
      manager.register<int>(StateStore<int>(100));
      manager.register<String>(StateStore<String>('hello'));
      manager.register<bool>(StateStore<bool>(true));

      // Update each state type and verify updates
      final intStore = manager.get<int>();
      final stringStore = manager.get<String>();
      final boolStore = manager.get<bool>();

      intStore.update(200);
      stringStore.update('world');
      boolStore.update(false);

      // Verify states were updated
      expect(intStore.state, 200);
      expect(stringStore.state, 'world');
      expect(boolStore.state, false);

      // Clean up
      manager.dispose();
    });
  });
}

// Test state classes
class TestState {
  final String name;
  final int count;

  TestState({required this.name, required this.count});

  TestState copyWith({String? name, int? count}) {
    return TestState(name: name ?? this.name, count: count ?? this.count);
  }
}

class UserState {
  final String id;
  final String name;

  UserState({required this.id, required this.name});
}

class SettingsState {
  final bool isDarkMode;

  SettingsState({required this.isDarkMode});
}
