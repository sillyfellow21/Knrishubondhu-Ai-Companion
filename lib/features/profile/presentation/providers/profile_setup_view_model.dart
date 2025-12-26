import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/save_profile_usecase.dart';
import 'profile_providers.dart';
import 'profile_setup_state.dart';

/// Profile Setup View Model Provider
final profileSetupViewModelProvider =
    StateNotifierProvider<ProfileSetupViewModel, ProfileSetupState>((ref) {
  return ProfileSetupViewModel(
    saveProfileUseCase: ref.watch(saveProfileUseCaseProvider),
  );
});

/// Profile Setup View Model
class ProfileSetupViewModel extends StateNotifier<ProfileSetupState> {
  final SaveProfileUseCase saveProfileUseCase;

  ProfileSetupViewModel({
    required this.saveProfileUseCase,
  }) : super(const ProfileSetupState());

  /// Save user profile
  Future<bool> saveProfile({
    required String userId,
    required String fullName,
    required String area,
    required double landAmount,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await saveProfileUseCase(
        userId: userId,
        fullName: fullName,
        area: area,
        landAmount: landAmount,
      );

      return result.fold(
        (failure) {
          final errorMsg = 'প্রোফাইল সংরক্ষণ ব্যর্থ: ${failure.message}';
          Logger.error('Save profile failed', error: errorMsg);
          state = state.copyWith(
            isLoading: false,
            errorMessage: errorMsg,
            isSaved: false,
          );
          return false;
        },
        (profile) {
          Logger.info('Profile saved successfully: ${profile.fullName}');
          state = state.copyWith(
            isLoading: false,
            profile: profile,
            errorMessage: null,
            isSaved: true,
          );
          return true;
        },
      );
    } catch (e) {
      Logger.error('Unexpected error during save profile', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।',
        isSaved: false,
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset state
  void reset() {
    state = const ProfileSetupState();
  }
}
