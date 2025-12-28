import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/land.dart';
import '../../domain/repositories/land_repository.dart';
import '../models/land_model.dart';

/// Land Repository Implementation
class LandRepositoryImpl implements LandRepository {
  final DatabaseService databaseService;
  final SupabaseService supabaseService;
  final Uuid uuid;

  LandRepositoryImpl({
    required this.databaseService,
    required this.supabaseService,
    required this.uuid,
  });

  @override
  Future<Either<String, List<Land>>> getAllLands() async {
    try {
      final db = await databaseService.database;

      // Get current user
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করা নেই।');
      }

      // Get lands from SQLite
      final results = await db.query(
        'lands',
        where: 'user_id = ?',
        whereArgs: [user.id],
        orderBy: 'created_at DESC',
      );

      final lands = results.map((map) => LandModel.fromDatabase(map)).toList();

      Logger.info('Retrieved ${lands.length} lands from database');

      // Sync with Supabase in background
      syncLands();

      return Right(lands);
    } catch (e) {
      Logger.error('Error getting all lands: $e');
      return const Left('জমির তথ্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }

  @override
  Future<Either<String, Land>> getLandById(String landId) async {
    try {
      final db = await databaseService.database;

      final results = await db.query(
        'lands',
        where: 'id = ?',
        whereArgs: [landId],
        limit: 1,
      );

      if (results.isEmpty) {
        return const Left('জমি পাওয়া যায়নি।');
      }

      final land = LandModel.fromDatabase(results.first);
      Logger.info('Retrieved land: ${land.name}');
      return Right(land);
    } catch (e) {
      Logger.error('Error getting land by ID: $e');
      return const Left('জমির তথ্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }

  @override
  Future<Either<String, Land>> addLand({
    required String name,
    required String location,
    required double area,
    String? soilType,
    String? notes,
  }) async {
    try {
      final db = await databaseService.database;

      // Get current user
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করা নেই।');
      }

      final now = DateTime.now();
      final land = LandModel(
        id: uuid.v4(),
        userId: user.id,
        name: name,
        location: location,
        area: area,
        soilType: soilType,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      // Insert into SQLite
      await db.insert('lands', land.toDatabase());

      Logger.info('Land added to SQLite: ${land.name}');

      // Sync to Supabase
      try {
        final supabaseData = land.toSupabase();
        Logger.info('Syncing land to Supabase: $supabaseData');
        await supabaseService.upsertData('lands', supabaseData,
            onConflict: 'id');
        Logger.info('Land synced to Supabase successfully');
      } catch (e, stackTrace) {
        Logger.error('Failed to sync land to Supabase: $e',
            error: e, stackTrace: stackTrace);
        // Continue - will sync later
      }

      return Right(land);
    } catch (e) {
      Logger.error('Error adding land: $e');
      return const Left('জমি যোগ করতে ব্যর্থ হয়েছে।');
    }
  }

  @override
  Future<Either<String, Land>> updateLand({
    required String landId,
    String? name,
    String? location,
    double? area,
    String? soilType,
    String? notes,
  }) async {
    try {
      final db = await databaseService.database;

      // Get existing land
      final results = await db.query(
        'lands',
        where: 'id = ?',
        whereArgs: [landId],
        limit: 1,
      );

      if (results.isEmpty) {
        return const Left('জমি পাওয়া যায়নি।');
      }

      final existingLand = LandModel.fromDatabase(results.first);
      final updatedLand = LandModel(
        id: existingLand.id,
        userId: existingLand.userId,
        name: name ?? existingLand.name,
        location: location ?? existingLand.location,
        area: area ?? existingLand.area,
        soilType: soilType ?? existingLand.soilType,
        notes: notes ?? existingLand.notes,
        createdAt: existingLand.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update in SQLite
      await db.update(
        'lands',
        updatedLand.toDatabase(),
        where: 'id = ?',
        whereArgs: [landId],
      );

      Logger.info('Land updated in SQLite: ${updatedLand.name}');

      // Sync to Supabase
      try {
        final supabaseData = updatedLand.toSupabase();
        Logger.info('Syncing land update to Supabase: $supabaseData');
        await supabaseService.upsertData('lands', supabaseData,
            onConflict: 'id');
        Logger.info('Land update synced to Supabase successfully');
      } catch (e, stackTrace) {
        Logger.error('Failed to sync land update to Supabase: $e',
            error: e, stackTrace: stackTrace);
      }

      return Right(updatedLand);
    } catch (e) {
      Logger.error('Error updating land: $e');
      return const Left('জমির তথ্য আপডেট করতে ব্যর্থ হয়েছে।');
    }
  }

  @override
  Future<Either<String, void>> deleteLand(String landId) async {
    try {
      final db = await databaseService.database;

      // Delete from SQLite
      await db.delete(
        'lands',
        where: 'id = ?',
        whereArgs: [landId],
      );

      Logger.info('Land deleted from SQLite: $landId');

      // Delete from Supabase
      try {
        Logger.info('Deleting land from Supabase: $landId');
        await supabaseService.deleteData('lands', 'id', landId);
        Logger.info('Land deleted from Supabase successfully');
      } catch (e, stackTrace) {
        Logger.error('Failed to delete land from Supabase: $e',
            error: e, stackTrace: stackTrace);
      }

      return const Right(null);
    } catch (e) {
      Logger.error('Error deleting land: $e');
      return const Left('জমি মুছে ফেলতে ব্যর্থ হয়েছে।');
    }
  }

  @override
  Future<Either<String, void>> syncLands() async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Left('ব্যবহারকারী লগইন করা নেই।');
      }

      final db = await databaseService.database;

      // First, upload local lands to Supabase that might not be synced
      final localLands = await db.query(
        'lands',
        where: 'user_id = ?',
        whereArgs: [user.id],
      );

      for (final landData in localLands) {
        try {
          final land = LandModel.fromDatabase(landData);
          await supabaseService.upsertData('lands', land.toSupabase(),
              onConflict: 'id');
        } catch (e) {
          Logger.warning('Failed to upload land to Supabase during sync: $e');
        }
      }

      // Then, download lands from Supabase
      final supabaseLands = await supabaseService.queryData(
        'lands',
        filters: {'user_id': user.id},
      );

      // Sync each land to SQLite
      for (final landData in supabaseLands) {
        final land = LandModel.fromSupabase(landData);

        // Check if exists
        final existing = await db.query(
          'lands',
          where: 'id = ?',
          whereArgs: [land.id],
          limit: 1,
        );

        if (existing.isEmpty) {
          // Insert
          await db.insert('lands', land.toDatabase());
        } else {
          // Update if newer
          final existingLand = LandModel.fromDatabase(existing.first);
          if (land.updatedAt.isAfter(existingLand.updatedAt)) {
            await db.update(
              'lands',
              land.toDatabase(),
              where: 'id = ?',
              whereArgs: [land.id],
            );
          }
        }
      }

      Logger.info('Lands synced successfully (bidirectional)');
      return const Right(null);
    } catch (e) {
      Logger.error('Error syncing lands: $e');
      return const Left('সিঙ্ক করতে ব্যর্থ হয়েছে।');
    }
  }
}
