import '../../domain/entities/loan.dart';

class LoanModel extends Loan {
  const LoanModel({required super.id, required super.userId, required super.lenderName, required super.amount, required super.paidAmount, required super.purpose, required super.loanDate, super.dueDate, required super.status, required super.createdAt, required super.updatedAt});
  
  factory LoanModel.fromDatabase(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      lenderName: map['lender_name'] as String,
      amount: map['amount'] as double,
      paidAmount: map['paid_amount'] as double,
      purpose: map['purpose'] as String,
      loanDate: DateTime.parse(map['loan_date'] as String),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  factory LoanModel.fromSupabase(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      lenderName: map['lender_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      purpose: map['purpose'] as String,
      loanDate: DateTime.parse(map['loan_date'] as String),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toDatabase() {
    return {'id': id, 'user_id': userId, 'lender_name': lenderName, 'amount': amount, 'paid_amount': paidAmount, 'purpose': purpose, 'loan_date': loanDate.toIso8601String(), 'due_date': dueDate?.toIso8601String(), 'status': status, 'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String(), 'synced': 1};
  }
  
  Map<String, dynamic> toSupabase() {
    return {'id': id, 'user_id': userId, 'lender_name': lenderName, 'amount': amount, 'paid_amount': paidAmount, 'purpose': purpose, 'loan_date': loanDate.toIso8601String(), 'due_date': dueDate?.toIso8601String(), 'status': status, 'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String()};
  }
}
