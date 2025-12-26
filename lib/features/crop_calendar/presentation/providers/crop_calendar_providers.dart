import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_providers.dart';
import '../../data/repositories/crop_calendar_repository_impl.dart';
import '../../domain/repositories/crop_calendar_repository.dart';
import '../../domain/usecases/get_all_seasons_usecase.dart';
import 'crop_calendar_state.dart';
import 'crop_calendar_view_model.dart';

/// Crop Calendar Repository Provider
final cropCalendarRepositoryProvider = Provider<CropCalendarRepository>((ref) {
  return CropCalendarRepositoryImpl(
    databaseService: ref.read(databaseServiceProvider),
  );
});

/// Get All Seasons Use Case Provider
final getAllSeasonsUseCaseProvider = Provider<GetAllSeasonsUseCase>((ref) {
  return GetAllSeasonsUseCase(ref.read(cropCalendarRepositoryProvider));
});

/// Crop Calendar View Model Provider
final cropCalendarViewModelProvider = StateNotifierProvider<CropCalendarViewModel, CropCalendarState>((ref) {
  return CropCalendarViewModel(
    getAllSeasonsUseCase: ref.read(getAllSeasonsUseCaseProvider),
  );
});
