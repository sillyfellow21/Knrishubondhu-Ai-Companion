import 'package:equatable/equatable.dart';
import '../../domain/entities/loan.dart';

abstract class LoansState extends Equatable {
  const LoansState();
  @override
  List<Object?> get props => [];
}

class LoansInitial extends LoansState {
  const LoansInitial();
}

class LoansLoading extends LoansState {
  const LoansLoading();
}

class LoansLoaded extends LoansState {
  final List<Loan> loans;
  const LoansLoaded(this.loans);
  @override
  List<Object?> get props => [loans];
}

class LoansEmpty extends LoansState {
  const LoansEmpty();
}

class LoansError extends LoansState {
  final String message;
  const LoansError(this.message);
  @override
  List<Object?> get props => [message];
}
