import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/repositories/loan_repository_impl.dart';
import '../../domain/repositories/loan_repository.dart';
import '../../domain/usecases/add_loan_usecase.dart';
import '../../domain/usecases/delete_loan_usecase.dart';
import '../../domain/usecases/get_all_loans_usecase.dart';
import '../../domain/usecases/update_loan_usecase.dart';
import 'loans_state.dart';
import 'loans_view_model.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService.instance);
final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService.instance);
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepositoryImpl(databaseService: ref.read(databaseServiceProvider), supabaseService: ref.read(supabaseServiceProvider), uuid: ref.read(uuidProvider));
});

final getAllLoansUseCaseProvider = Provider<GetAllLoansUseCase>((ref) => GetAllLoansUseCase(ref.read(loanRepositoryProvider)));
final addLoanUseCaseProvider = Provider<AddLoanUseCase>((ref) => AddLoanUseCase(ref.read(loanRepositoryProvider)));
final updateLoanUseCaseProvider = Provider<UpdateLoanUseCase>((ref) => UpdateLoanUseCase(ref.read(loanRepositoryProvider)));
final deleteLoanUseCaseProvider = Provider<DeleteLoanUseCase>((ref) => DeleteLoanUseCase(ref.read(loanRepositoryProvider)));

final loansViewModelProvider = StateNotifierProvider<LoansViewModel, LoansState>((ref) {
  return LoansViewModel(getAllLoansUseCase: ref.read(getAllLoansUseCaseProvider), addLoanUseCase: ref.read(addLoanUseCaseProvider), updateLoanUseCase: ref.read(updateLoanUseCaseProvider), deleteLoanUseCase: ref.read(deleteLoanUseCaseProvider));
});
