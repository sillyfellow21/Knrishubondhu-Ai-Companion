import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

/// Auth View Model Provider
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    signInUseCase: ref.watch(signInUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
  );
});

/// Auth View Model
class AuthViewModel extends StateNotifier<AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;

  AuthViewModel({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
  }) : super(const AuthState());

  /// Toggle between sign up and sign in mode
  void toggleMode() {
    state = state.copyWith(
      isSignUpMode: !state.isSignUpMode,
      errorMessage: null,
    );
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await signUpUseCase(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      return result.fold(
        (failure) {
          Logger.error('Sign up failed', error: failure.message);
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (user) {
          Logger.info('Sign up successful: ${user.email}');
          state = state.copyWith(
            isLoading: false,
            user: user,
            errorMessage: null,
          );
          return true;
        },
      );
    } catch (e) {
      Logger.error('Unexpected error during sign up', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।',
      );
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await signInUseCase(
        email: email,
        password: password,
      );

      return result.fold(
        (failure) {
          Logger.error('Sign in failed', error: failure.message);
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (user) {
          Logger.info('Sign in successful: ${user.email}');
          state = state.copyWith(
            isLoading: false,
            user: user,
            errorMessage: null,
          );
          return true;
        },
      );
    } catch (e) {
      Logger.error('Unexpected error during sign in', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।',
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await signOutUseCase();

      result.fold(
        (failure) {
          Logger.error('Sign out failed', error: failure.message);
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (_) {
          Logger.info('Sign out successful');
          state = state.copyWith(
            isLoading: false,
            user: null,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      Logger.error('Unexpected error during sign out', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সাইন আউট ব্যর্থ হয়েছে',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
