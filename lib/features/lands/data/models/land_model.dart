import '../../domain/entities/land.dart';

/// Land Model for data layer
class LandModel extends Land {
  const LandModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.location,
    required super.area,
    super.soilType,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });
  
  /// Create from SQLite database
  factory LandModel.fromDatabase(Map<String, dynamic> map) {
    return LandModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      area: map['area'] as double,
      soilType: map['soil_type'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  /// Create from Supabase
  factory LandModel.fromSupabase(Map<String, dynamic> map) {
    return LandModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      area: (map['area'] as num).toDouble(),
      soilType: map['soil_type'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  /// Convert to SQLite map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'location': location,
      'area': area,
      'soil_type': soilType,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced': 1,
    };
  }
  
  /// Convert to Supabase map
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'location': location,
      'area': area,
      'soil_type': soilType,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
