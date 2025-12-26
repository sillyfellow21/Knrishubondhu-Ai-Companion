import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.userId,
    required super.fullName,
    required super.area,
    required super.landAmount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      area: json['area'] as String,
      landAmount: (json['land_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'area': area,
      'land_amount': landAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'area': area,
      'land_amount': landAmount,
      'is_synced': 1,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserProfileModel.fromDatabase(Map<String, dynamic> db) {
    return UserProfileModel(
      id: db['id'] as String,
      userId: db['user_id'] as String,
      fullName: db['full_name'] as String,
      area: db['area'] as String,
      landAmount: (db['land_amount'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(db['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(db['updated_at'] as int),
    );
  }
}
