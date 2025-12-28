import 'package:equatable/equatable.dart';

/// Land Entity
class Land extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String location;
  final double area; // in decimal/acres
  final String? soilType;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Land({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.area,
    this.soilType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    location,
    area,
    soilType,
    notes,
    createdAt,
    updatedAt,
  ];
}
