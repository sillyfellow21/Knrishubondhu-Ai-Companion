import 'package:dartz/dartz.dart';
import '../entities/loan.dart';

abstract class LoanRepository {
  Future<Either<String, List<Loan>>> getAllLoans();
  Future<Either<String, Loan>> addLoan({required String lenderName, required double amount, required String purpose, required DateTime loanDate, DateTime? dueDate});
  Future<Either<String, Loan>> updateLoan({required String loanId, String? lenderName, double? amount, double? paidAmount, String? purpose, DateTime? loanDate, DateTime? dueDate, String? status});
  Future<Either<String, void>> deleteLoan(String loanId);
}
