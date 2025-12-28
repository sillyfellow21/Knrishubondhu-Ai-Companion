import '../../domain/entities/season_calendar.dart';

/// Crop Model
class CropModel extends Crop {
  const CropModel({
    required super.name,
    required super.plantingMonth,
    required super.harvestMonth,
    required super.duration,
    required super.tips,
  });
  
  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      name: json['name'] as String,
      plantingMonth: json['plantingMonth'] as String,
      harvestMonth: json['harvestMonth'] as String,
      duration: json['duration'] as String,
      tips: json['tips'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'plantingMonth': plantingMonth,
      'harvestMonth': harvestMonth,
      'duration': duration,
      'tips': tips,
    };
  }
}

/// Season Calendar Model
class SeasonCalendarModel extends SeasonCalendar {
  const SeasonCalendarModel({
    required super.id,
    required super.name,
    required super.months,
    required super.icon,
    required super.crops,
    required super.lastYearProduction,
    required super.thisYearProduction,
  });
  
  factory SeasonCalendarModel.fromJson(Map<String, dynamic> json) {
    final cropsJson = json['crops'] as List;
    final crops = cropsJson.map((crop) => CropModel.fromJson(crop)).toList();
    
    return SeasonCalendarModel(
      id: json['id'] as String,
      name: json['name'] as String,
      months: json['months'] as String,
      icon: json['icon'] as String,
      crops: crops,
      lastYearProduction: json['lastYearProduction'] as String,
      thisYearProduction: json['thisYearProduction'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'months': months,
      'icon': icon,
      'crops': crops.map((crop) => (crop as CropModel).toJson()).toList(),
      'lastYearProduction': lastYearProduction,
      'thisYearProduction': thisYearProduction,
    };
  }
  
  /// Convert to database map (for caching)
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'months': months,
      'icon': icon,
      'last_year_production': lastYearProduction,
      'this_year_production': thisYearProduction,
      'crops_json': crops.map((crop) => (crop as CropModel).toJson()).toList().toString(),
    };
  }
}
