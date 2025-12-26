import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/add_land_usecase.dart';
import '../../domain/usecases/delete_land_usecase.dart';
import '../../domain/usecases/get_all_lands_usecase.dart';
import 'lands_state.dart';

/// Lands View Model
class LandsViewModel extends StateNotifier<LandsState> {
  final GetAllLandsUseCase getAllLandsUseCase;
  final AddLandUseCase addLandUseCase;
  final DeleteLandUseCase deleteLandUseCase;
  
  LandsViewModel({
    required this.getAllLandsUseCase,
    required this.addLandUseCase,
    required this.deleteLandUseCase,
  }) : super(const LandsInitial());
  
  /// Load all lands
  Future<void> loadLands() async {
    state = const LandsLoading();
    
    try {
      Logger.info('Loading lands...');
      
      final result = await getAllLandsUseCase.call();
      
      result.fold(
        (error) {
          Logger.error('Error loading lands: $error');
          state = LandsError(error);
        },
        (lands) {
          Logger.info('Loaded ${lands.length} lands');
          if (lands.isEmpty) {
            state = const LandsEmpty();
          } else {
            state = LandsLoaded(lands);
          }
        },
      );
    } catch (e) {
      Logger.error('Unexpected error loading lands: $e');
      state = const LandsError('জমির তথ্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }
  
  /// Add a new land
  Future<bool> addLand({
    required String name,
    required String location,
    required double area,
    String? soilType,
    String? notes,
  }) async {
    try {
      Logger.info('Adding new land: $name');
      
      final result = await addLandUseCase.call(
        name: name,
        location: location,
        area: area,
        soilType: soilType,
        notes: notes,
      );
      
      return result.fold(
        (error) {
          Logger.error('Error adding land: $error');
          return false;
        },
        (land) {
          Logger.info('Land added successfully: ${land.name}');
          // Reload lands
          loadLands();
          return true;
        },
      );
    } catch (e) {
      Logger.error('Unexpected error adding land: $e');
      return false;
    }
  }
  
  /// Delete a land
  Future<bool> deleteLand(String landId) async {
    try {
      Logger.info('Deleting land: $landId');
      
      final result = await deleteLandUseCase.call(landId);
      
      return result.fold(
        (error) {
          Logger.error('Error deleting land: $error');
          return false;
        },
        (_) {
          Logger.info('Land deleted successfully');
          // Reload lands
          loadLands();
          return true;
        },
      );
    } catch (e) {
      Logger.error('Unexpected error deleting land: $e');
      return false;
    }
  }
  
  /// Refresh lands
  Future<void> refresh() async {
    await loadLands();
  }
}
