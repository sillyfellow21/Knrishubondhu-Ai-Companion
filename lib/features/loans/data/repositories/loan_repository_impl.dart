import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../models/loan_model.dart';

class LoanRepositoryImpl implements LoanRepository {
  final DatabaseService databaseService;
  final SupabaseService supabaseService;
  final Uuid uuid;
  
  LoanRepositoryImpl({required this.databaseService, required this.supabaseService, required this.uuid});
  
  @override
  Future<Either<String, List<Loan>>> getAllLoans() async {
    try {
      final db = await databaseService.database;
      final user = supabaseService.currentUser;
      if (user == null) return const Left('ব্যবহারকারী লগইন করা নেই।');
      
      final results = await db.query('loans', where: 'user_id = ?', whereArgs: [user.id], orderBy: 'loan_date DESC');
      final loans = results.map((map) => LoanModel.fromDatabase(map)).toList();
      
      Logger.info('Retrieved ${loans.length} loans');
      _syncLoans();
      return Right(loans);
    } catch (e) {
      Logger.error('Error getting loans: $e');
      return const Left('ঋণের তথ্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }
  
  @override
  Future<Either<String, Loan>> addLoan({required String lenderName, required double amount, required String purpose, required DateTime loanDate, DateTime? dueDate}) async {
    try {
      final db = await databaseService.database;
      final user = supabaseService.currentUser;
      if (user == null) return const Left('ব্যবহারকারী লগইন করা নেই।');
      
      final now = DateTime.now();
      final loan = LoanModel(id: uuid.v4(), userId: user.id, lenderName: lenderName, amount: amount, paidAmount: 0, purpose: purpose, loanDate: loanDate, dueDate: dueDate, status: 'pending', createdAt: now, updatedAt: now);
      
      await db.insert('loans', loan.toDatabase());
      Logger.info('Loan added: ${loan.lenderName}');
      
      try {
        await supabaseService.insertData('loans', loan.toSupabase());
      } catch (e) {
        Logger.warning('Failed to sync loan to Supabase: $e');
      }
      
      return Right(loan);
    } catch (e) {
      Logger.error('Error adding loan: $e');
      return const Left('ঋণ যোগ করতে ব্যর্থ হয়েছে।');
    }
  }
  
  @override
  Future<Either<String, Loan>> updateLoan({required String loanId, String? lenderName, double? amount, double? paidAmount, String? purpose, DateTime? loanDate, DateTime? dueDate, String? status}) async {
    try {
      final db = await databaseService.database;
      final results = await db.query('loans', where: 'id = ?', whereArgs: [loanId], limit: 1);
      if (results.isEmpty) return const Left('ঋণ পাওয়া যায়নি।');
      
      final existing = LoanModel.fromDatabase(results.first);
      final updated = LoanModel(
        id: existing.id, userId: existing.userId, lenderName: lenderName ?? existing.lenderName, amount: amount ?? existing.amount, paidAmount: paidAmount ?? existing.paidAmount, purpose: purpose ?? existing.purpose, loanDate: loanDate ?? existing.loanDate, dueDate: dueDate ?? existing.dueDate,
        status: status ?? (paidAmount != null && paidAmount >= (amount ?? existing.amount) ? 'paid' : paidAmount != null && paidAmount > 0 ? 'partial' : existing.status),
        createdAt: existing.createdAt, updatedAt: DateTime.now(),
      );
      
      await db.update('loans', updated.toDatabase(), where: 'id = ?', whereArgs: [loanId]);
      Logger.info('Loan updated: $loanId');
      
      try {
        await supabaseService.updateData('loans', updated.toSupabase(), 'id', loanId);
      } catch (e) {
        Logger.warning('Failed to sync loan update to Supabase: $e');
      }
      
      return Right(updated);
    } catch (e) {
      Logger.error('Error updating loan: $e');
      return const Left('ঋণ আপডেট করতে ব্যর্থ হয়েছে।');
    }
  }
  
  @override
  Future<Either<String, void>> deleteLoan(String loanId) async {
    try {
      final db = await databaseService.database;
      await db.delete('loans', where: 'id = ?', whereArgs: [loanId]);
      Logger.info('Loan deleted: $loanId');
      
      try {
        await supabaseService.deleteData('loans', 'id', loanId);
      } catch (e) {
        Logger.warning('Failed to delete loan from Supabase: $e');
      }
      
      return const Right(null);
    } catch (e) {
      Logger.error('Error deleting loan: $e');
      return const Left('ঋণ মুছে ফেলতে ব্যর্থ হয়েছে।');
    }
  }
  
  Future<void> _syncLoans() async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) return;
      
      final supabaseLoans = await supabaseService.queryData('loans', filters: {'user_id': user.id});
      final db = await databaseService.database;
      
      for (final loanData in supabaseLoans) {
        final loan = LoanModel.fromSupabase(loanData);
        final existing = await db.query('loans', where: 'id = ?', whereArgs: [loan.id], limit: 1);
        
        if (existing.isEmpty) {
          await db.insert('loans', loan.toDatabase());
        } else {
          final existingLoan = LoanModel.fromDatabase(existing.first);
          if (loan.updatedAt.isAfter(existingLoan.updatedAt)) {
            await db.update('loans', loan.toDatabase(), where: 'id = ?', whereArgs: [loan.id]);
          }
        }
      }
      Logger.info('Loans synced');
    } catch (e) {
      Logger.error('Error syncing loans: $e');
    }
  }
}
