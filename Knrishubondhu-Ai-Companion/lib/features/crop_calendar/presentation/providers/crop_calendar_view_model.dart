import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_all_seasons_usecase.dart';
import 'crop_calendar_state.dart';

/// Crop Calendar View Model
class CropCalendarViewModel extends StateNotifier<CropCalendarState> {
  final GetAllSeasonsUseCase getAllSeasonsUseCase;
  
  CropCalendarViewModel({
    required this.getAllSeasonsUseCase,
  }) : super(const CropCalendarInitial());
  
  /// Load all seasons
  Future<void> loadSeasons() async {
    state = const CropCalendarLoading();
    
    try {
      Logger.info('Loading crop calendar seasons...');
      
      final result = await getAllSeasonsUseCase.call();
      
      result.fold(
        (error) {
          Logger.error('Error loading seasons: $error');
          state = CropCalendarError(error);
        },
        (seasons) {
          Logger.info('Loaded ${seasons.length} seasons');
          state = CropCalendarLoaded(seasons);
        },
      );
    } catch (e) {
      Logger.error('Unexpected error loading seasons: $e');
      state = const CropCalendarError('ফসল ক্যালেন্ডার লোড করতে ব্যর্থ হয়েছে।');
    }
  }
  
  /// Refresh seasons
  Future<void> refresh() async {
    await loadSeasons();
  }
}
