import 'package:dartz/dartz.dart';
import '../entities/land.dart';
import '../repositories/land_repository.dart';

/// Use case for getting all lands
class GetAllLandsUseCase {
  final LandRepository repository;
  
  GetAllLandsUseCase(this.repository);
  
  Future<Either<String, List<Land>>> call() async {
    return await repository.getAllLands();
  }
}
