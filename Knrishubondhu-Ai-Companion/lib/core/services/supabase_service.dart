import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Supabase Service - Centralized service for all Supabase operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  /// Get Supabase client instance
  SupabaseClient get client => Supabase.instance.client;

  /// Get Auth instance
  GoTrueClient get auth => client.auth;

  /// Get Database (Postgres) instance
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// Get Storage instance
  SupabaseStorageClient get storage => client.storage;

  /// Get Realtime instance
  RealtimeClient get realtime => client.realtime;

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      Logger.info('Initializing Supabase...');

      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
        debug: AppConfig.isDebugMode,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // More secure flow
          autoRefreshToken: true,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 3,
        ),
      );

      Logger.info('Supabase initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize Supabase',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ==================== Auth Methods ====================

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await auth.signUp(
        email: email,
        password: password,
        data: data,
      );
    } catch (e) {
      Logger.error('Sign up failed', error: e);
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      Logger.error('Sign in failed', error: e);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
      Logger.info('User signed out');
    } catch (e) {
      Logger.error('Sign out failed', error: e);
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current session
  Session? get currentSession => auth.currentSession;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await auth.resetPasswordForEmail(email);
      Logger.info('Password reset email sent');
    } catch (e) {
      Logger.error('Password reset failed', error: e);
      rethrow;
    }
  }

  /// Update user profile
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );
    } catch (e) {
      Logger.error('Update user failed', error: e);
      rethrow;
    }
  }

  // ==================== Database Methods ====================

  /// Insert data into a table
  Future<List<Map<String, dynamic>>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await from(table).insert(data).select();
    } catch (e) {
      Logger.error('Insert failed', error: e);
      rethrow;
    }
  }

  /// Upsert data into a table (insert or update)
  Future<List<Map<String, dynamic>>> upsert({
    required String table,
    required Map<String, dynamic> data,
    String? onConflict,
  }) async {
    try {
      return await from(table).upsert(data, onConflict: onConflict).select();
    } catch (e) {
      Logger.error('Upsert failed', error: e);
      rethrow;
    }
  }

  /// Select data from a table
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
  }) async {
    try {
      return await from(table).select(columns);
    } catch (e) {
      Logger.error('Select failed', error: e);
      rethrow;
    }
  }

  /// Update data in a table
  Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required String matchColumn,
    required dynamic matchValue,
  }) async {
    try {
      return await from(table)
          .update(data)
          .eq(matchColumn, matchValue)
          .select();
    } catch (e) {
      Logger.error('Update failed', error: e);
      rethrow;
    }
  }

  /// Delete data from a table
  Future<void> delete({
    required String table,
    required String matchColumn,
    required dynamic matchValue,
  }) async {
    try {
      await from(table).delete().eq(matchColumn, matchValue);
    } catch (e) {
      Logger.error('Delete failed', error: e);
      rethrow;
    }
  }

  // ==================== Helper Methods for Backward Compatibility ====================

  /// Insert data (backward compatibility wrapper)
  Future<void> insertData(String table, Map<String, dynamic> data) async {
    await insert(table: table, data: data);
  }

  /// Upsert data (backward compatibility wrapper) - insert or update
  Future<void> upsertData(String table, Map<String, dynamic> data,
      {String? onConflict}) async {
    await upsert(table: table, data: data, onConflict: onConflict);
  }

  /// Update data (backward compatibility wrapper)
  Future<void> updateData(String table, Map<String, dynamic> data,
      String matchColumn, dynamic matchValue) async {
    await update(
        table: table,
        data: data,
        matchColumn: matchColumn,
        matchValue: matchValue);
  }

  /// Delete data (backward compatibility wrapper)
  Future<void> deleteData(
      String table, String matchColumn, dynamic matchValue) async {
    await delete(
        table: table, matchColumn: matchColumn, matchValue: matchValue);
  }

  /// Query data (backward compatibility wrapper)
  Future<List<Map<String, dynamic>>> queryData(String table,
      {Map<String, dynamic>? filters}) async {
    try {
      var query = from(table).select();
      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }
      return await query;
    } catch (e) {
      Logger.error('Query failed', error: e);
      rethrow;
    }
  }

  /// Subscribe to realtime changes
  RealtimeChannel subscribeToTable({
    required String table,
    required void Function(PostgresChangePayload payload) onInsert,
    void Function(PostgresChangePayload payload)? onUpdate,
    void Function(PostgresChangePayload payload)? onDelete,
  }) {
    final channel = client.channel('public:$table');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: onInsert,
        )
        .subscribe();

    if (onUpdate != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        callback: onUpdate,
      );
    }

    if (onDelete != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        callback: onDelete,
      );
    }

    return channel;
  }

  // ==================== Storage Methods ====================

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    try {
      await storage.from(bucket).uploadBinary(
            path,
            Uint8List.fromList(fileBytes),
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      return getPublicUrl(bucket: bucket, path: path);
    } catch (e) {
      Logger.error('Upload file failed', error: e);
      rethrow;
    }
  }

  /// Download file from storage
  Future<List<int>> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      return await storage.from(bucket).download(path);
    } catch (e) {
      Logger.error('Download file failed', error: e);
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await storage.from(bucket).remove([path]);
      Logger.info('File deleted successfully');
    } catch (e) {
      Logger.error('Delete file failed', error: e);
      rethrow;
    }
  }

  /// Get public URL for a file
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return storage.from(bucket).getPublicUrl(path);
  }

  /// List files in a bucket
  Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
  }) async {
    try {
      return await storage.from(bucket).list(path: path);
    } catch (e) {
      Logger.error('List files failed', error: e);
      rethrow;
    }
  }

  /// Create a signed URL (for private files)
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600, // 1 hour default
  }) async {
    try {
      return await storage.from(bucket).createSignedUrl(path, expiresIn);
    } catch (e) {
      Logger.error('Create signed URL failed', error: e);
      rethrow;
    }
  }

  // ==================== Utility Methods ====================

  /// Check connection status
  Future<bool> checkConnection() async {
    try {
      await client.from('_health').select().limit(1);
      return true;
    } catch (e) {
      Logger.error('Connection check failed', error: e);
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    realtime.disconnect();
    Logger.info('Supabase service disposed');
  }
}
