import 'dart:async';

/// A generic store for state management.
class StateStore<T> {
  // Current state
  T _state;

  // Stream controller for state updates
  final _stateController = StreamController<T>.broadcast();

  // Constructor
  StateStore(this._state) {
    // Initialize the stream with current state
    _stateController.add(_state);
  }

  // State getters
  T get state => _state;
  Stream<T> get stream => _stateController.stream;

  // Update state
  void update(T newState) {
    _state = newState;
    _stateController.add(_state);
  }

  // Update state with a reducer function
  void updateWith(T Function(T currentState) reducer) {
    final newState = reducer(_state);
    update(newState);
  }

  void dispose() {
    _stateController.close();
  }
}
