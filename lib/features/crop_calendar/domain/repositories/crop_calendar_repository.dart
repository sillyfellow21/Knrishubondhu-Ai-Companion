import 'package:dartz/dartz.dart';
import '../entities/season_calendar.dart';

/// Crop Calendar Repository Interface
abstract class CropCalendarRepository {
  /// Get all season calendars
  Future<Either<String, List<SeasonCalendar>>> getAllSeasons();
  
  /// Get a specific season by ID
  Future<Either<String, SeasonCalendar>> getSeasonById(String seasonId);
}
