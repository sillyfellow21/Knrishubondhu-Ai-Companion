import 'package:equatable/equatable.dart';
import '../../domain/entities/land.dart';

/// Lands Screen State
abstract class LandsState extends Equatable {
  const LandsState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class LandsInitial extends LandsState {
  const LandsInitial();
}

/// Loading state
class LandsLoading extends LandsState {
  const LandsLoading();
}

/// Success state with lands list
class LandsLoaded extends LandsState {
  final List<Land> lands;
  
  const LandsLoaded(this.lands);
  
  @override
  List<Object?> get props => [lands];
}

/// Empty state (no lands)
class LandsEmpty extends LandsState {
  const LandsEmpty();
}

/// Error state
class LandsError extends LandsState {
  final String message;
  
  const LandsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
