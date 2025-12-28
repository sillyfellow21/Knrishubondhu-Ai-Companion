import 'package:equatable/equatable.dart';

/// User Profile entity
class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String area;
  final double landAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.area,
    required this.landAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        area,
        landAmount,
        createdAt,
        updatedAt,
      ];
}
