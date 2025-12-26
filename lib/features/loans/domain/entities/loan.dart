import 'package:equatable/equatable.dart';

/// Loan Entity
class Loan extends Equatable {
  final String id;
  final String userId;
  final String lenderName;
  final double amount;
  final double paidAmount;
  final String purpose;
  final DateTime loanDate;
  final DateTime? dueDate;
  final String status; // pending, partial, paid
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Loan({
    required this.id,
    required this.userId,
    required this.lenderName,
    required this.amount,
    required this.paidAmount,
    required this.purpose,
    required this.loanDate,
    this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  
  double get remainingAmount => amount - paidAmount;
  bool get isPaid => paidAmount >= amount;
  
  @override
  List<Object?> get props => [id, userId, lenderName, amount, paidAmount, purpose, loanDate, dueDate, status, createdAt, updatedAt];
}
