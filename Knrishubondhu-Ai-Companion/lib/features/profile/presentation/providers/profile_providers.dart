import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/supabase_providers.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/save_profile_usecase.dart';

/// UUID Provider
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    supabaseService: ref.watch(supabaseServiceProvider),
    databaseService: ref.watch(databaseServiceProvider),
    uuid: ref.watch(uuidProvider),
  );
});

/// Save Profile Use Case Provider
final saveProfileUseCaseProvider = Provider<SaveProfileUseCase>((ref) {
  return SaveProfileUseCase(ref.watch(profileRepositoryProvider));
});

/// Get Profile Use Case Provider
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});
