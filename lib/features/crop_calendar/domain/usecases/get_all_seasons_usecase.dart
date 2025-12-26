import 'package:dartz/dartz.dart';
import '../entities/season_calendar.dart';
import '../repositories/crop_calendar_repository.dart';

/// Use case for getting all seasons
class GetAllSeasonsUseCase {
  final CropCalendarRepository repository;
  
  GetAllSeasonsUseCase(this.repository);
  
  Future<Either<String, List<SeasonCalendar>>> call() async {
    return await repository.getAllSeasons();
  }
}
