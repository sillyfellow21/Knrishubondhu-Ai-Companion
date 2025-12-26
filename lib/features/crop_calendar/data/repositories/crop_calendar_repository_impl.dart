import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/season_calendar.dart';
import '../../domain/repositories/crop_calendar_repository.dart';
import '../models/season_calendar_model.dart';

/// Crop Calendar Repository Implementation
class CropCalendarRepositoryImpl implements CropCalendarRepository {
  final DatabaseService databaseService;
  
  CropCalendarRepositoryImpl({
    required this.databaseService,
  });
  
  @override
  Future<Either<String, List<SeasonCalendar>>> getAllSeasons() async {
    try {
      // Try to get from cache first
      final cachedSeasons = await _getCachedSeasons();
      if (cachedSeasons.isNotEmpty) {
        Logger.info('Returning ${cachedSeasons.length} seasons from cache');
        return Right(cachedSeasons);
      }
      
      // Load from JSON file
      Logger.info('Loading seasons from JSON file');
      final jsonString = await rootBundle.loadString('assets/data/crop_calendar.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      final seasonsJson = jsonData['seasons'] as List;
      final seasons = seasonsJson
          .map((seasonJson) => SeasonCalendarModel.fromJson(seasonJson))
          .toList();
      
      // Cache to database
      await _cacheSeasons(seasons);
      
      Logger.info('Loaded ${seasons.length} seasons from JSON');
      return Right(seasons);
    } catch (e) {
      Logger.error('Error loading seasons: $e');
      return const Left('মৌসুম তথ্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }
  
  @override
  Future<Either<String, SeasonCalendar>> getSeasonById(String seasonId) async {
    try {
      final result = await getAllSeasons();
      
      return result.fold(
        (error) => Left(error),
        (seasons) {
          final season = seasons.firstWhere(
            (s) => s.id == seasonId,
            orElse: () => throw Exception('Season not found'),
          );
          return Right(season);
        },
      );
    } catch (e) {
      Logger.error('Error getting season by ID: $e');
      return const Left('মৌসুম পাওয়া যায়নি।');
    }
  }
  
  /// Get cached seasons from SQLite
  Future<List<SeasonCalendar>> _getCachedSeasons() async {
    try {
      final db = await databaseService.database;
      
      // Note: This is a simplified cache check
      // In production, you might want to add timestamp validation
      final results = await db.query('crop_calendar_cache');
      
      if (results.isEmpty) {
        return [];
      }
      
      // For simplicity, we'll just return empty and reload from JSON
      // In a full implementation, you'd parse the cached data
      return [];
    } catch (e) {
      Logger.warning('Error reading cache: $e');
      return [];
    }
  }
  
  /// Cache seasons to SQLite
  Future<void> _cacheSeasons(List<SeasonCalendarModel> seasons) async {
    try {
      final db = await databaseService.database;
      
      // Create table if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS crop_calendar_cache (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          months TEXT NOT NULL,
          icon TEXT NOT NULL,
          last_year_production TEXT NOT NULL,
          this_year_production TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
      
      // Clear old cache
      await db.delete('crop_calendar_cache');
      
      // Insert new data
      for (final season in seasons) {
        await db.insert('crop_calendar_cache', {
          'id': season.id,
          'name': season.name,
          'months': season.months,
          'icon': season.icon,
          'last_year_production': season.lastYearProduction,
          'this_year_production': season.thisYearProduction,
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
      
      Logger.info('Cached ${seasons.length} seasons to database');
    } catch (e) {
      Logger.warning('Error caching seasons: $e');
      // Don't throw - caching failure shouldn't break the flow
    }
  }
}
