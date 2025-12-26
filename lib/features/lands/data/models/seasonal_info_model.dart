import '../../domain/entities/seasonal_info.dart';

/// Seasonal Info Model for data layer
class SeasonalInfoModel extends SeasonalInfo {
  const SeasonalInfoModel({
    required super.id,
    required super.landId,
    required super.season,
    super.cropName,
    super.notes,
    super.plantingDate,
    super.harvestDate,
    required super.createdAt,
    required super.updatedAt,
  });
  
  /// Create from database
  factory SeasonalInfoModel.fromDatabase(Map<String, dynamic> map) {
    return SeasonalInfoModel(
      id: map['id'] as String,
      landId: map['land_id'] as String,
      season: map['season'] as String,
      cropName: map['crop_name'] as String?,
      notes: map['notes'] as String?,
      plantingDate: map['planting_date'] != null
          ? DateTime.parse(map['planting_date'] as String)
          : null,
      harvestDate: map['harvest_date'] != null
          ? DateTime.parse(map['harvest_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'land_id': landId,
      'season': season,
      'crop_name': cropName,
      'notes': notes,
      'planting_date': plantingDate?.toIso8601String(),
      'harvest_date': harvestDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
