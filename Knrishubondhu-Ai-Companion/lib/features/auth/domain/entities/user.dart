import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.role = 'farmer',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, fullName, phoneNumber, avatarUrl, role, createdAt];
}
