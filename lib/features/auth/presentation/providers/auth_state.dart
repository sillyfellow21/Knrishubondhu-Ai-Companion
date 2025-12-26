import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Auth State
class AuthState extends Equatable {
  final bool isLoading;
  final User? user;
  final String? errorMessage;
  final bool isSignUpMode;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isSignUpMode = true,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
    bool? isSignUpMode,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isSignUpMode: isSignUpMode ?? this.isSignUpMode,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, errorMessage, isSignUpMode];
}
