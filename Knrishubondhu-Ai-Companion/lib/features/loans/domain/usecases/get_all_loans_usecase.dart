import 'package:dartz/dartz.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

class GetAllLoansUseCase {
  final LoanRepository repository;
  GetAllLoansUseCase(this.repository);
  Future<Either<String, List<Loan>>> call() async => await repository.getAllLoans();
}
