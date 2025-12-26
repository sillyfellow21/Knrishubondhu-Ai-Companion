import 'package:equatable/equatable.dart';
import '../../domain/entities/season_calendar.dart';

/// Crop Calendar State
abstract class CropCalendarState extends Equatable {
  const CropCalendarState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class CropCalendarInitial extends CropCalendarState {
  const CropCalendarInitial();
}

/// Loading state
class CropCalendarLoading extends CropCalendarState {
  const CropCalendarLoading();
}

/// Loaded state
class CropCalendarLoaded extends CropCalendarState {
  final List<SeasonCalendar> seasons;
  
  const CropCalendarLoaded(this.seasons);
  
  @override
  List<Object?> get props => [seasons];
}

/// Error state
class CropCalendarError extends CropCalendarState {
  final String message;
  
  const CropCalendarError(this.message);
  
  @override
  List<Object?> get props => [message];
}
