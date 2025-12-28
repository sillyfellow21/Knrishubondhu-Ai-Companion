# 💾 SQLite Database Setup Guide - KrishiBondhu AI

## 📋 Database Overview

KrishiBondhu AI uses SQLite (sqflite) for local data storage with the following tables:

- **users** - User profile information
- **lands** - Agricultural land details
- **loans** - Loan applications and tracking
- **chat_history** - AI chat conversations
- **weather_cache** - Cached weather data

---

## 🗄️ Database Schema

### 1. Users Table

```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  supabase_id TEXT UNIQUE,
  email TEXT NOT NULL,
  full_name TEXT,
  phone_number TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'farmer',
  is_synced INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
```

**Fields:**
- `id`: Local unique identifier (UUID)
- `supabase_id`: Supabase auth user ID
- `email`: User email address
- `full_name`: User's full name
- `phone_number`: Contact number
- `avatar_url`: Profile picture URL
- `role`: User role (farmer, admin, loan_officer)
- `is_synced`: Sync status with Supabase (0 = not synced, 1 = synced)
- `created_at`: Creation timestamp (milliseconds)
- `updated_at`: Last update timestamp (milliseconds)

---

### 2. Lands Table

```sql
CREATE TABLE lands (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  location TEXT,
  area_in_acres REAL,
  soil_type TEXT,
  latitude REAL,
  longitude REAL,
  crops TEXT,
  image_url TEXT,
  is_synced INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)
```

**Fields:**
- `id`: Unique land identifier
- `user_id`: Owner's user ID
- `name`: Land name/title
- `location`: Location description
- `area_in_acres`: Land area in acres
- `soil_type`: Type of soil (e.g., loamy, clay, sandy)
- `latitude`, `longitude`: GPS coordinates
- `crops`: JSON string of crops grown
- `image_url`: Land photo URL

---

### 3. Loans Table

```sql
CREATE TABLE loans (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  loan_type TEXT NOT NULL,
  amount REAL NOT NULL,
  interest_rate REAL,
  duration_months INTEGER,
  status TEXT DEFAULT 'pending',
  applied_date INTEGER NOT NULL,
  approved_date INTEGER,
  disbursed_date INTEGER,
  repayment_start_date INTEGER,
  bank_name TEXT,
  loan_officer TEXT,
  notes TEXT,
  is_synced INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)
```

**Fields:**
- `loan_type`: Type of loan (agricultural, equipment, etc.)
- `amount`: Loan amount
- `interest_rate`: Interest rate percentage
- `duration_months`: Loan duration
- `status`: pending, approved, rejected, disbursed, completed, defaulted
- `applied_date`: Application timestamp
- `approved_date`: Approval timestamp
- `disbursed_date`: Disbursement timestamp
- `repayment_start_date`: When repayment starts
- `bank_name`: Lending institution
- `loan_officer`: Officer handling the loan

---

### 4. Chat History Table

```sql
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
```

**Fields:**
- `session_id`: Chat session identifier
- `message`: Message content
- `sender`: user, ai, or system
- `message_type`: text, image, voice, file
- `metadata`: JSON string for additional data

---

### 5. Weather Cache Table

```sql
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
```

**Fields:**
- `location`: Location name
- `latitude`, `longitude`: GPS coordinates
- `temperature`: Temperature in Celsius
- `humidity`: Humidity percentage
- `wind_speed`: Wind speed in km/h
- `weather_condition`: Weather condition (e.g., Clear, Rainy)
- `forecast_data`: JSON string of forecast data
- `cached_at`: Cache timestamp
- `expires_at`: Cache expiry timestamp

---

## 🔧 Usage Examples

### Initialize Database

```dart
import 'package:krishibondhu_ai/core/services/database_service.dart';

final dbService = DatabaseService.instance;

// Database is automatically initialized on first access
await dbService.database;
```

### Users Operations

```dart
// Insert user
await dbService.insertUser({
  'id': uuid.v4(),
  'supabase_id': supabaseUser.id,
  'email': 'farmer@example.com',
  'full_name': 'রহিম মিয়া',
  'phone_number': '+8801711111111',
  'role': 'farmer',
  'is_synced': 0,
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Get user by ID
final user = await dbService.getUserById('user-id');

// Get user by Supabase ID
final user = await dbService.getUserBySupabaseId(supabaseId);

// Update user
await dbService.updateUser('user-id', {
  'full_name': 'করিম মিয়া',
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Delete user
await dbService.deleteUser('user-id');
```

### Lands Operations

```dart
// Insert land
await dbService.insertLand({
  'id': uuid.v4(),
  'user_id': userId,
  'name': 'ধান জমি',
  'location': 'রাজশাহী',
  'area_in_acres': 2.5,
  'soil_type': 'loamy',
  'latitude': 24.3745,
  'longitude': 88.6042,
  'crops': jsonEncode(['rice', 'wheat']),
  'is_synced': 0,
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Get all lands for a user
final lands = await dbService.getLandsByUserId(userId);

// Get specific land
final land = await dbService.getLandById('land-id');

// Update land
await dbService.updateLand('land-id', {
  'area_in_acres': 3.0,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Delete land
await dbService.deleteLand('land-id');
```

### Loans Operations

```dart
// Insert loan
await dbService.insertLoan({
  'id': uuid.v4(),
  'user_id': userId,
  'loan_type': 'agricultural',
  'amount': 50000.0,
  'interest_rate': 8.5,
  'duration_months': 12,
  'status': 'pending',
  'applied_date': DateTime.now().millisecondsSinceEpoch,
  'bank_name': 'কৃষি বাংলা ব্যাংক',
  'is_synced': 0,
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Get all loans for a user
final loans = await dbService.getLoansByUserId(userId);

// Get loans by status
final pendingLoans = await dbService.getLoansByStatus('pending');

// Update loan status
await dbService.updateLoan('loan-id', {
  'status': 'approved',
  'approved_date': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});
```

### Chat History Operations

```dart
// Insert chat message
await dbService.insertChatMessage({
  'id': uuid.v4(),
  'user_id': userId,
  'session_id': sessionId,
  'message': 'আমার ধান ক্ষেতে পোকার আক্রমণ হয়েছে',
  'sender': 'user',
  'message_type': 'text',
  'is_synced': 0,
  'created_at': DateTime.now().millisecondsSinceEpoch,
});

// Get chat history for a session
final chatHistory = await dbService.getChatHistoryBySessionId(sessionId);

// Get user's recent chats
final recentChats = await dbService.getChatHistoryByUserId(
  userId,
  limit: 50,
);

// Delete old chat history (older than 30 days)
final thirtyDaysAgo = DateTime.now()
    .subtract(Duration(days: 30))
    .millisecondsSinceEpoch;
await dbService.deleteOldChatHistory(thirtyDaysAgo);
```

### Weather Cache Operations

```dart
// Insert weather cache
await dbService.insertWeatherCache({
  'location': 'Rajshahi',
  'latitude': 24.3745,
  'longitude': 88.6042,
  'temperature': 32.5,
  'humidity': 70.0,
  'wind_speed': 12.0,
  'weather_condition': 'Clear',
  'description': 'Clear sky',
  'icon_code': '01d',
  'forecast_data': jsonEncode(forecastList),
  'cached_at': DateTime.now().millisecondsSinceEpoch,
  'expires_at': DateTime.now()
      .add(Duration(hours: 1))
      .millisecondsSinceEpoch,
});

// Get cached weather (if not expired)
final weather = await dbService.getWeatherCacheByLocation(
  24.3745,
  88.6042,
);

// Delete expired cache
await dbService.deleteExpiredWeatherCache();
```

### Sync Operations

```dart
// Get all unsynced records
final unsyncedUsers = await dbService.getUnsyncedRecords('users');
final unsyncedLands = await dbService.getUnsyncedRecords('lands');

// Mark as synced after uploading to Supabase
await dbService.markAsSynced('users', userId);

// Batch mark multiple records as synced
await dbService.markMultipleAsSynced('lands', ['id1', 'id2', 'id3']);
```

### Batch Operations

```dart
// Execute multiple operations in a transaction
await dbService.batch((batch) {
  batch.insert('users', userData);
  batch.insert('lands', landData);
  batch.update('loans', loanData, where: 'id = ?', whereArgs: [loanId]);
});
```

### Database Maintenance

```dart
// Clear all data
await dbService.clearAllData();

// Close database
await dbService.close();

// Delete database file
await dbService.deleteDatabase();

// Get database size
final size = await dbService.getDatabaseSize();
print('Database size: ${size / 1024} KB');
```

---

## 🔄 Migration Guide

When updating database schema in future versions:

1. Update `databaseVersion` in `app_config.dart`
2. Add migration logic in `_onUpgrade` method:

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add new column
    await db.execute('ALTER TABLE users ADD COLUMN location TEXT');
  }
  
  if (oldVersion < 3) {
    // Create new table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }
}
```

---

## 🔐 Best Practices

1. ✅ Always use transactions for multiple operations
2. ✅ Use indexes for frequently queried columns (already added)
3. ✅ Store timestamps as integers (milliseconds since epoch)
4. ✅ Use foreign keys with ON DELETE CASCADE for data integrity
5. ✅ Cache frequently accessed data in memory
6. ✅ Clean up expired cache regularly
7. ✅ Use `is_synced` flag for offline-first sync strategy
8. ✅ Store JSON data as TEXT for complex structures

---

## 📊 Performance Tips

- Use `LIMIT` and `OFFSET` for pagination
- Create indexes on frequently searched columns
- Use `batch()` for multiple operations
- Avoid storing large binary data (use file system instead)
- Regularly delete old/expired data
- Use `PRAGMA foreign_keys = ON` for referential integrity

---

✅ **SQLite Setup Complete! Database ready for use.**
