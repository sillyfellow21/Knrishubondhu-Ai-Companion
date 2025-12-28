import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/repositories/land_repository_impl.dart';
import '../../domain/repositories/land_repository.dart';
import '../../domain/usecases/add_land_usecase.dart';
import '../../domain/usecases/delete_land_usecase.dart';
import '../../domain/usecases/get_all_lands_usecase.dart';
import 'lands_state.dart';
import 'lands_view_model.dart';

/// Database Service Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Supabase Service Provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

/// UUID Provider
final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

/// Land Repository Provider
final landRepositoryProvider = Provider<LandRepository>((ref) {
  return LandRepositoryImpl(
    databaseService: ref.read(databaseServiceProvider),
    supabaseService: ref.read(supabaseServiceProvider),
    uuid: ref.read(uuidProvider),
  );
});

/// Get All Lands Use Case Provider
final getAllLandsUseCaseProvider = Provider<GetAllLandsUseCase>((ref) {
  return GetAllLandsUseCase(ref.read(landRepositoryProvider));
});

/// Add Land Use Case Provider
final addLandUseCaseProvider = Provider<AddLandUseCase>((ref) {
  return AddLandUseCase(ref.read(landRepositoryProvider));
});

/// Delete Land Use Case Provider
final deleteLandUseCaseProvider = Provider<DeleteLandUseCase>((ref) {
  return DeleteLandUseCase(ref.read(landRepositoryProvider));
});

/// Lands View Model Provider
final landsViewModelProvider = StateNotifierProvider<LandsViewModel, LandsState>((ref) {
  return LandsViewModel(
    getAllLandsUseCase: ref.read(getAllLandsUseCaseProvider),
    addLandUseCase: ref.read(addLandUseCaseProvider),
    deleteLandUseCase: ref.read(deleteLandUseCaseProvider),
  );
});
