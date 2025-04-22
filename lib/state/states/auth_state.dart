import 'package:state_management_example/models/user.dart';

class AuthState {
  final User user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user = User.anonymous, this.isLoading = false, this.error});

  bool get isAuthenticated => user.isAuthenticated;

  AuthState copyWith({User? user, bool? isLoading, String? error, bool clearError = false}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
