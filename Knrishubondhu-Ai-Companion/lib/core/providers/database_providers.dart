import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Provider for Database Service instance
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Provider to initialize database
final initializeDatabaseProvider = FutureProvider<void>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  await dbService.database; // This initializes the database
});
