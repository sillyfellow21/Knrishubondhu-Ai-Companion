import 'package:dartz/dartz.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

class UpdateLoanUseCase {
  final LoanRepository repository;
  UpdateLoanUseCase(this.repository);
  Future<Either<String, Loan>> call({required String loanId, String? lenderName, double? amount, double? paidAmount, String? purpose, DateTime? loanDate, DateTime? dueDate, String? status}) async {
    return await repository.updateLoan(loanId: loanId, lenderName: lenderName, amount: amount, paidAmount: paidAmount, purpose: purpose, loanDate: loanDate, dueDate: dueDate, status: status);
  }
}
