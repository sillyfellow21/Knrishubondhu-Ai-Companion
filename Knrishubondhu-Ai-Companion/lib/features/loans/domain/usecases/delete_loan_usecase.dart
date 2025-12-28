import 'package:dartz/dartz.dart';
import '../repositories/loan_repository.dart';

class DeleteLoanUseCase {
  final LoanRepository repository;
  DeleteLoanUseCase(this.repository);
  Future<Either<String, void>> call(String loanId) async => await repository.deleteLoan(loanId);
}
