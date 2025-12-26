import 'package:equatable/equatable.dart';

/// Crop Information
class Crop extends Equatable {
  final String name;
  final String plantingMonth;
  final String harvestMonth;
  final String duration;
  final String tips;
  
  const Crop({
    required this.name,
    required this.plantingMonth,
    required this.harvestMonth,
    required this.duration,
    required this.tips,
  });
  
  @override
  List<Object?> get props => [name, plantingMonth, harvestMonth, duration, tips];
}

/// Season Calendar Entity
class SeasonCalendar extends Equatable {
  final String id;
  final String name;
  final String months;
  final String icon;
  final List<Crop> crops;
  final String lastYearProduction;
  final String thisYearProduction;
  
  const SeasonCalendar({
    required this.id,
    required this.name,
    required this.months,
    required this.icon,
    required this.crops,
    required this.lastYearProduction,
    required this.thisYearProduction,
  });
  
  @override
  List<Object?> get props => [
    id,
    name,
    months,
    icon,
    crops,
    lastYearProduction,
    thisYearProduction,
  ];
}
