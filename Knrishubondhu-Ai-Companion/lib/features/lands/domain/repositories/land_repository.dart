import 'package:dartz/dartz.dart';
import '../entities/land.dart';

/// Land Repository Interface
abstract class LandRepository {
  /// Get all lands for the current user
  Future<Either<String, List<Land>>> getAllLands();
  
  /// Get a single land by ID
  Future<Either<String, Land>> getLandById(String landId);
  
  /// Add a new land
  Future<Either<String, Land>> addLand({
    required String name,
    required String location,
    required double area,
    String? soilType,
    String? notes,
  });
  
  /// Update an existing land
  Future<Either<String, Land>> updateLand({
    required String landId,
    String? name,
    String? location,
    double? area,
    String? soilType,
    String? notes,
  });
  
  /// Delete a land
  Future<Either<String, void>> deleteLand(String landId);
  
  /// Sync lands with Supabase
  Future<Either<String, void>> syncLands();
}
