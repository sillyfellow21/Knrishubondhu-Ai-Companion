import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// SQLite Database Service - Centralized service for all local database operations
class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  static DatabaseService get instance => _instance ??= DatabaseService._();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      Logger.info('Initializing SQLite database...');

      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConfig.databaseName);

      final database = await openDatabase(
        path,
        version: AppConfig.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );

      Logger.info('SQLite database initialized successfully');
      return database;
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize database',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Configure database settings
  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create tables on first database creation
  Future<void> _onCreate(Database db, int version) async {
    Logger.info('Creating database tables...');

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        supabase_id TEXT UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT,
        full_name TEXT,
        phone_number TEXT,
        avatar_url TEXT,
        role TEXT DEFAULT 'farmer',
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create lands table
    await db.execute('''
      CREATE TABLE lands (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        area REAL NOT NULL DEFAULT 0,
        soil_type TEXT,
        notes TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create loans table
    await db.execute('''
      CREATE TABLE loans (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        lender_name TEXT NOT NULL,
        amount REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        purpose TEXT NOT NULL,
        loan_date TEXT NOT NULL,
        due_date TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create user_profiles table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        area TEXT NOT NULL,
        land_amount REAL NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create chat_history table
    await db.execute('''
      CREATE TABLE chat_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        message TEXT NOT NULL,
        sender TEXT NOT NULL,
        message_type TEXT DEFAULT 'text',
        metadata TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create weather_cache table
    await db.execute('''
      CREATE TABLE weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        temperature REAL,
        humidity REAL,
        wind_speed REAL,
        weather_condition TEXT,
        description TEXT,
        icon_code TEXT,
        forecast_data TEXT,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        UNIQUE(latitude, longitude)
      )
    ''');

    // Create indexes for better query performance
    await db
        .execute('CREATE INDEX idx_users_supabase_id ON users(supabase_id)');
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_lands_user_id ON lands(user_id)');
    await db.execute('CREATE INDEX idx_loans_user_id ON loans(user_id)');
    await db.execute('CREATE INDEX idx_loans_status ON loans(status)');
    await db.execute(
        'CREATE INDEX idx_chat_history_user_id ON chat_history(user_id)');
    await db.execute(
        'CREATE INDEX idx_chat_history_session_id ON chat_history(session_id)');
    await db.execute(
        'CREATE INDEX idx_weather_cache_location ON weather_cache(location)');
    await db.execute(
        'CREATE INDEX idx_weather_cache_expires ON weather_cache(expires_at)');

    Logger.info('Database tables created successfully');
  }

  /// Handle database version upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Logger.info('Upgrading database from version $oldVersion to $newVersion');

    // Migration from version 1 to 2: Recreate lands table with correct schema
    if (oldVersion < 2) {
      // Drop old lands table and recreate with correct schema
      await db.execute('DROP TABLE IF EXISTS lands');
      await db.execute('''
        CREATE TABLE lands (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          location TEXT NOT NULL,
          area REAL NOT NULL DEFAULT 0,
          soil_type TEXT,
          notes TEXT,
          synced INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_lands_user_id ON lands(user_id)');
      Logger.info('Lands table migrated to version 2');
    }

    // Migration from version 2 to 4: Recreate loans table with correct schema
    if (oldVersion < 4) {
      // Drop old loans table and recreate with correct schema
      await db.execute('DROP TABLE IF EXISTS loans');
      await db.execute('''
        CREATE TABLE loans (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          lender_name TEXT NOT NULL,
          amount REAL NOT NULL,
          paid_amount REAL NOT NULL DEFAULT 0,
          purpose TEXT NOT NULL,
          loan_date TEXT NOT NULL,
          due_date TEXT,
          status TEXT NOT NULL DEFAULT 'pending',
          synced INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_loans_user_id ON loans(user_id)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_loans_status ON loans(status)');
      Logger.info('Loans table migrated to version 4');
    }
  }

  // ==================== Generic CRUD Methods ====================

  /// Insert a record into a table
  Future<int> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final db = await database;
      final id = await db.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      Logger.info('Inserted record into $table with id: $id');
      return id;
    } catch (e) {
      Logger.error('Insert failed for table $table', error: e);
      rethrow;
    }
  }

  /// Query records from a table
  Future<List<Map<String, dynamic>>> query({
    required String table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      return await db.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      Logger.error('Query failed for table $table', error: e);
      rethrow;
    }
  }

  /// Query a single record from a table
  Future<Map<String, dynamic>?> queryOne({
    required String table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final results = await query(
        table: table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      Logger.error('QueryOne failed for table $table', error: e);
      rethrow;
    }
  }

  /// Update a record in a table
  Future<int> update({
    required String table,
    required Map<String, dynamic> data,
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    try {
      final db = await database;
      final count = await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );
      Logger.info('Updated $count record(s) in $table');
      return count;
    } catch (e) {
      Logger.error('Update failed for table $table', error: e);
      rethrow;
    }
  }

  /// Delete a record from a table
  Future<int> delete({
    required String table,
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    try {
      final db = await database;
      final count = await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      Logger.info('Deleted $count record(s) from $table');
      return count;
    } catch (e) {
      Logger.error('Delete failed for table $table', error: e);
      rethrow;
    }
  }

  /// Delete all records from a table
  Future<int> deleteAll(String table) async {
    try {
      final db = await database;
      final count = await db.delete(table);
      Logger.info('Deleted all records from $table');
      return count;
    } catch (e) {
      Logger.error('DeleteAll failed for table $table', error: e);
      rethrow;
    }
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      Logger.error('Raw query failed', error: e);
      rethrow;
    }
  }

  /// Execute raw SQL statement
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawInsert(sql, arguments);
    } catch (e) {
      Logger.error('Raw insert failed', error: e);
      rethrow;
    }
  }

  /// Execute raw SQL update
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawUpdate(sql, arguments);
    } catch (e) {
      Logger.error('Raw update failed', error: e);
      rethrow;
    }
  }

  /// Execute raw SQL delete
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawDelete(sql, arguments);
    } catch (e) {
      Logger.error('Raw delete failed', error: e);
      rethrow;
    }
  }

  // ==================== Users Table Methods ====================

  Future<int> insertUser(Map<String, dynamic> user) async {
    return await insert(table: 'users', data: user);
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    return await queryOne(
      table: 'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getUserBySupabaseId(String supabaseId) async {
    return await queryOne(
      table: 'users',
      where: 'supabase_id = ?',
      whereArgs: [supabaseId],
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return await queryOne(
      table: 'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> updateUser(String id, Map<String, dynamic> data) async {
    return await update(
      table: 'users',
      data: data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(String id) async {
    return await delete(
      table: 'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Lands Table Methods ====================

  Future<int> insertLand(Map<String, dynamic> land) async {
    return await insert(table: 'lands', data: land);
  }

  Future<Map<String, dynamic>?> getLandById(String id) async {
    return await queryOne(
      table: 'lands',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getLandsByUserId(String userId) async {
    return await query(
      table: 'lands',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> updateLand(String id, Map<String, dynamic> data) async {
    return await update(
      table: 'lands',
      data: data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLand(String id) async {
    return await delete(
      table: 'lands',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Loans Table Methods ====================

  Future<int> insertLoan(Map<String, dynamic> loan) async {
    return await insert(table: 'loans', data: loan);
  }

  Future<Map<String, dynamic>?> getLoanById(String id) async {
    return await queryOne(
      table: 'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getLoansByUserId(String userId) async {
    return await query(
      table: 'loans',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'applied_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getLoansByStatus(String status) async {
    return await query(
      table: 'loans',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'applied_date DESC',
    );
  }

  Future<int> updateLoan(String id, Map<String, dynamic> data) async {
    return await update(
      table: 'loans',
      data: data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLoan(String id) async {
    return await delete(
      table: 'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Chat History Table Methods ====================

  Future<int> insertChatMessage(Map<String, dynamic> message) async {
    return await insert(table: 'chat_history', data: message);
  }

  Future<List<Map<String, dynamic>>> getChatHistoryBySessionId(
      String sessionId) async {
    return await query(
      table: 'chat_history',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getChatHistoryByUserId(
    String userId, {
    int? limit,
  }) async {
    return await query(
      table: 'chat_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<int> deleteChatHistory(String sessionId) async {
    return await delete(
      table: 'chat_history',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<int> deleteOldChatHistory(int olderThanTimestamp) async {
    return await delete(
      table: 'chat_history',
      where: 'created_at < ?',
      whereArgs: [olderThanTimestamp],
    );
  }

  // ==================== Weather Cache Table Methods ====================

  Future<int> insertWeatherCache(Map<String, dynamic> weather) async {
    return await insert(table: 'weather_cache', data: weather);
  }

  Future<Map<String, dynamic>?> getWeatherCacheByLocation(
    double latitude,
    double longitude,
  ) async {
    // Get weather cache that hasn't expired
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await queryOne(
      table: 'weather_cache',
      where: 'latitude = ? AND longitude = ? AND expires_at > ?',
      whereArgs: [latitude, longitude, now],
    );

    return result;
  }

  Future<int> updateWeatherCache(
    double latitude,
    double longitude,
    Map<String, dynamic> data,
  ) async {
    return await update(
      table: 'weather_cache',
      data: data,
      where: 'latitude = ? AND longitude = ?',
      whereArgs: [latitude, longitude],
    );
  }

  Future<int> deleteExpiredWeatherCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return await delete(
      table: 'weather_cache',
      where: 'expires_at < ?',
      whereArgs: [now],
    );
  }

  Future<int> deleteAllWeatherCache() async {
    return await deleteAll('weather_cache');
  }

  // ==================== Sync Methods ====================

  /// Get all unsynced records from a table
  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String table) async {
    return await query(
      table: table,
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  /// Mark a record as synced
  Future<int> markAsSynced(String table, String id) async {
    return await update(
      table: table,
      data: {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark multiple records as synced
  Future<void> markMultipleAsSynced(String table, List<String> ids) async {
    final db = await database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        table,
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
    Logger.info('Marked ${ids.length} records as synced in $table');
  }

  // ==================== Batch Operations ====================

  /// Execute multiple operations in a transaction
  Future<void> batch(Function(Batch batch) operations) async {
    final db = await database;
    final batch = db.batch();
    operations(batch);
    await batch.commit(noResult: true);
  }

  // ==================== Database Maintenance ====================

  /// Get database size in bytes
  Future<int> getDatabaseSize() async {
    final db = await database;
    final path = db.path;
    final file = await databaseFactory.openDatabase(path);
    return file.path.length;
  }

  /// Clear all data from all tables
  Future<void> clearAllData() async {
    final db = await database;
    final batch = db.batch();

    batch.delete('users');
    batch.delete('lands');
    batch.delete('loans');
    batch.delete('chat_history');
    batch.delete('weather_cache');

    await batch.commit(noResult: true);
    Logger.info('All data cleared from database');
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    Logger.info('Database connection closed');
  }

  /// Delete database file
  Future<void> deleteDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConfig.databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      Logger.info('Database deleted');
    } catch (e) {
      Logger.error('Failed to delete database', error: e);
      rethrow;
    }
  }
}
