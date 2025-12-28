import 'package:equatable/equatable.dart';

/// Seasonal Information Entity
class SeasonalInfo extends Equatable {
  final String id;
  final String landId;
  final String season; // গ্রীষ্ম, বর্ষা, শরৎ, হেমন্ত, শীত, বসন্ত
  final String? cropName;
  final String? notes;
  final DateTime? plantingDate;
  final DateTime? harvestDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const SeasonalInfo({
    required this.id,
    required this.landId,
    required this.season,
    this.cropName,
    this.notes,
    this.plantingDate,
    this.harvestDate,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    landId,
    season,
    cropName,
    notes,
    plantingDate,
    harvestDate,
    createdAt,
    updatedAt,
  ];
}
