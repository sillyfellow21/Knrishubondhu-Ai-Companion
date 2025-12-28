import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/add_loan_usecase.dart';
import '../../domain/usecases/delete_loan_usecase.dart';
import '../../domain/usecases/get_all_loans_usecase.dart';
import '../../domain/usecases/update_loan_usecase.dart';
import 'loans_state.dart';

class LoansViewModel extends StateNotifier<LoansState> {
  final GetAllLoansUseCase getAllLoansUseCase;
  final AddLoanUseCase addLoanUseCase;
  final UpdateLoanUseCase updateLoanUseCase;
  final DeleteLoanUseCase deleteLoanUseCase;
  
  LoansViewModel({required this.getAllLoansUseCase, required this.addLoanUseCase, required this.updateLoanUseCase, required this.deleteLoanUseCase}) : super(const LoansInitial());
  
  Future<void> loadLoans() async {
    state = const LoansLoading();
    try {
      final result = await getAllLoansUseCase.call();
      result.fold((error) => state = LoansError(error), (loans) => state = loans.isEmpty ? const LoansEmpty() : LoansLoaded(loans));
    } catch (e) {
      state = const LoansError('ঋণের তথ্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }
  
  Future<bool> addLoan({required String lenderName, required double amount, required String purpose, required DateTime loanDate, DateTime? dueDate}) async {
    try {
      final result = await addLoanUseCase.call(lenderName: lenderName, amount: amount, purpose: purpose, loanDate: loanDate, dueDate: dueDate);
      return result.fold((error) => false, (loan) {
        loadLoans();
        return true;
      });
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> updateLoan({required String loanId, String? lenderName, double? amount, double? paidAmount, String? purpose, DateTime? loanDate, DateTime? dueDate, String? status}) async {
    try {
      final result = await updateLoanUseCase.call(loanId: loanId, lenderName: lenderName, amount: amount, paidAmount: paidAmount, purpose: purpose, loanDate: loanDate, dueDate: dueDate, status: status);
      return result.fold((error) => false, (loan) {
        loadLoans();
        return true;
      });
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> deleteLoan(String loanId) async {
    try {
      final result = await deleteLoanUseCase.call(loanId);
      return result.fold((error) => false, (_) {
        loadLoans();
        return true;
      });
    } catch (e) {
      return false;
    }
  }
  
  Future<void> refresh() async => await loadLoans();
}
