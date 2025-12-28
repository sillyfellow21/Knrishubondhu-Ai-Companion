import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

/// Profile Setup State
class ProfileSetupState extends Equatable {
  final bool isLoading;
  final UserProfile? profile;
  final String? errorMessage;
  final bool isSaved;

  const ProfileSetupState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
    this.isSaved = false,
  });

  ProfileSetupState copyWith({
    bool? isLoading,
    UserProfile? profile,
    String? errorMessage,
    bool? isSaved,
  }) {
    return ProfileSetupState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, errorMessage, isSaved];
}
