import 'package:dartz/dartz.dart';
import '../entities/land.dart';
import '../repositories/land_repository.dart';

/// Use case for adding a new land
class AddLandUseCase {
  final LandRepository repository;
  
  AddLandUseCase(this.repository);
  
  Future<Either<String, Land>> call({
    required String name,
    required String location,
    required double area,
    String? soilType,
    String? notes,
  }) async {
    return await repository.addLand(
      name: name,
      location: location,
      area: area,
      soilType: soilType,
      notes: notes,
    );
  }
}
