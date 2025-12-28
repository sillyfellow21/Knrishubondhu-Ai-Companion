import 'package:dartz/dartz.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

class AddLoanUseCase {
  final LoanRepository repository;
  AddLoanUseCase(this.repository);
  Future<Either<String, Loan>> call({required String lenderName, required double amount, required String purpose, required DateTime loanDate, DateTime? dueDate}) async {
    return await repository.addLoan(lenderName: lenderName, amount: amount, purpose: purpose, loanDate: loanDate, dueDate: dueDate);
  }
}
