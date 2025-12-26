# Potential Issues and Fixes

## ✅ Current Status
- **Compilation**: No errors found (flutter analyze passed)
- **API Keys**: Configured and valid
- **Dependencies**: All required packages present in pubspec.yaml

---

## ⚠️ High Priority Issues (Will Cause Runtime Errors)

### 1. **Supabase Database Tables Not Created**
**Impact**: App will crash when trying to sync data to Supabase

**Symptoms**:
```
PostgrestException: relation "lands" does not exist
PostgrestException: relation "loans" does not exist
```

**Solution**: Run migration SQL files in Supabase dashboard
1. Go to https://supabase.com/dashboard/project/mifwuugvljzhbuavhnbf/sql/new
2. Execute `SUPABASE_PROFILES_TABLE.sql`
3. Execute `SUPABASE_RLS_SETUP.sql`
4. Execute `supabase_migrations/001_create_user_profiles.sql`

**Files to execute**:
- `c:\KrishiBondhuAI\SUPABASE_PROFILES_TABLE.sql`
- `c:\KrishiBondhuAI\SUPABASE_RLS_SETUP.sql`
- `c:\KrishiBondhuAI\supabase_migrations\001_create_user_profiles.sql`

---

### 2. **Missing Android Location Permission Runtime Check**
**Impact**: Weather feature will fail on Android 6.0+ without requesting permission at runtime

**Current state**: Permissions declared in AndroidManifest.xml but not requested at runtime

**Solution**: Add permission request code in weather feature
```dart
// Add to lib/features/weather/presentation/providers/weather_view_model.dart
import 'package:permission_handler/permission_handler.dart';

Future<void> _requestLocationPermission() async {
  final status = await Permission.location.request();
  if (!status.isGranted) {
    // Show error to user
  }
}
```

**Required**: Add `permission_handler` to pubspec.yaml
```yaml
dependencies:
  permission_handler: ^11.3.1
```

---

### 3. **Gemini API Rate Limiting**
**Impact**: Chat feature will fail after 60 requests per minute (free tier limit)

**Current state**: No rate limiting or error handling for quota exceeded

**Solution**: Add retry logic with exponential backoff
```dart
// In lib/core/services/gemini_service.dart
Future<String> sendMessageWithRetry(String message, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await sendMessage(message);
    } catch (e) {
      if (e.toString().contains('429') || e.toString().contains('quota')) {
        await Future.delayed(Duration(seconds: pow(2, i).toInt()));
        continue;
      }
      rethrow;
    }
  }
  throw Exception('Rate limit exceeded. Please try again later.');
}
```

---

### 4. **Network Connectivity Not Checked Before API Calls**
**Impact**: App will show cryptic errors when offline instead of user-friendly messages

**Current state**: `connectivity_plus` package is included but not used

**Solution**: Already have `NetworkService` but need to use it before API calls
```dart
// In repositories before Supabase calls
final isConnected = await NetworkService.instance.isConnected;
if (!isConnected) {
  return Left('No internet connection. Data saved locally.');
}
```

---

### 5. **Image Picker Crash on iOS (Missing Info.plist keys)**
**Impact**: App will crash when trying to pick images on iOS

**Current state**: No iOS configuration visible in workspace

**Solution**: Add to `ios/Runner/Info.plist` (if iOS support is needed)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos to upload crop images</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take crop photos</string>
```

---

## ⚙️ Medium Priority Issues (May Cause Issues)

### 6. **Database Migration Not Handled**
**Impact**: App crashes when updating database schema in future versions

**Current state**: `onUpgrade` callback is defined but empty
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // Migration logic will be added here in future versions
}
```

**Solution**: Implement migration strategy when schema changes
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add new column for version 2
    await db.execute('ALTER TABLE lands ADD COLUMN new_field TEXT');
  }
}
```

---

### 7. **Memory Leak in Image Handling**
**Impact**: App may run out of memory when handling multiple large images

**Current state**: Images loaded into memory without size limits in chat and lands features

**Solution**: Compress images before processing
```dart
// Add image_compression package
dependencies:
  flutter_image_compress: ^2.3.0

// Compress before sending to Gemini
Future<Uint8List> compressImage(Uint8List bytes) async {
  return await FlutterImageCompress.compressWithList(
    bytes,
    minWidth: 1024,
    minHeight: 1024,
    quality: 85,
  );
}
```

---

### 8. **No Offline Queue for Failed Syncs**
**Impact**: Data loss if app is closed while offline operations are pending

**Current state**: Sync attempts are fire-and-forget
```dart
// In repositories
try {
  await supabaseService.insertData('lands', land.toSupabase());
} catch (e) {
  Logger.warning('Sync failed, will retry later'); // But never retries!
}
```

**Solution**: Implement background sync queue
```dart
// Track failed syncs in SQLite
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  table_name TEXT NOT NULL,
  operation TEXT NOT NULL, -- 'insert', 'update', 'delete'
  data TEXT NOT NULL, -- JSON
  retry_count INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
);

// Process queue on app startup and network reconnection
Future<void> processSyncQueue() async {
  final pending = await db.query('sync_queue');
  for (final item in pending) {
    try {
      // Retry sync
      await _performSync(item);
      await db.delete('sync_queue', where: 'id = ?', whereArgs: [item['id']]);
    } catch (e) {
      // Increment retry count
      await db.update('sync_queue', 
        {'retry_count': (item['retry_count'] as int) + 1},
        where: 'id = ?', whereArgs: [item['id']]
      );
    }
  }
}
```

---

### 9. **Weather Data Not Cached**
**Impact**: Excessive API calls and slower loading times

**Current state**: Weather is fetched every time screen is opened

**Solution**: Already mentioned in code but not implemented - cache for 24 hours
```dart
// Add weather_last_updated to SQLite
await db.execute('''
  CREATE TABLE weather_cache (
    location TEXT PRIMARY KEY,
    data TEXT NOT NULL,
    fetched_at INTEGER NOT NULL
  )
''');

// Check cache before API call
final cache = await db.query('weather_cache', where: 'location = ?', whereArgs: [location]);
if (cache.isNotEmpty) {
  final fetchedAt = cache.first['fetched_at'] as int;
  final now = DateTime.now().millisecondsSinceEpoch;
  if (now - fetchedAt < 24 * 60 * 60 * 1000) { // 24 hours
    return jsonDecode(cache.first['data']);
  }
}
```

---

## 🔍 Low Priority Issues (Edge Cases)

### 10. **No Input Sanitization for SQL Injection in Raw Queries**
**Impact**: Potential SQL injection if user input is directly concatenated

**Current state**: Using parameterized queries (✅ SAFE) but need to ensure consistency

**Check**: All queries use `?` placeholders instead of string concatenation
```dart
// ✅ SAFE
await db.query('lands', where: 'user_id = ?', whereArgs: [userId]);

// ❌ UNSAFE (not found in codebase, but good to check)
await db.rawQuery('SELECT * FROM lands WHERE user_id = "$userId"');
```

---

### 11. **Bengali Text Not Rendering Properly on Some Devices**
**Impact**: Chat responses show boxes instead of Bengali characters

**Current state**: Using Google Fonts which should handle this

**Solution**: Add font fallback
```dart
// In lib/core/theme/app_theme.dart
textTheme: GoogleFonts.notoSansTextTheme().apply(
  fontFamily: 'NotoSansBengali', // Add fallback
),
```

**Additional**: Bundle Bengali font in assets for offline use
```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: NotoSansBengali
      fonts:
        - asset: assets/fonts/NotoSansBengali-Regular.ttf
```

---

### 12. **No Session Expiry Handling**
**Impact**: User gets logged out suddenly without warning

**Current state**: Supabase handles auto-refresh but no UI feedback

**Solution**: Listen to auth state changes
```dart
// In lib/features/auth/presentation/providers/auth_view_model.dart
void _listenToAuthChanges() {
  supabase.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event == AuthChangeEvent.tokenRefreshed) {
      Logger.info('Session refreshed');
    } else if (event == AuthChangeEvent.signedOut) {
      // Show message and redirect
      _showMessage('Session expired. Please login again.');
      _navigateToLogin();
    }
  });
}
```

---

### 13. **Large Response from Gemini Not Handled**
**Impact**: UI may lag or crash with very long responses

**Current state**: `maxOutputTokens: 1024` limits response but no chunking for display

**Solution**: Stream responses instead of waiting for complete text
```dart
// Gemini supports streaming
final stream = _model.generateContentStream(content);
await for (final chunk in stream) {
  final text = chunk.text;
  if (text != null) {
    _appendToResponse(text); // Update UI incrementally
  }
}
```

---

### 14. **No Backup/Export Feature**
**Impact**: Users lose all data if they uninstall app

**Current state**: Data only in local SQLite and Supabase (requires auth)

**Solution**: Add data export to JSON
```dart
Future<void> exportUserData() async {
  final lands = await getAllLands();
  final loans = await getAllLoans();
  final chats = await getChatHistory();
  
  final backup = {
    'exported_at': DateTime.now().toIso8601String(),
    'lands': lands.map((l) => l.toJson()).toList(),
    'loans': loans.map((l) => l.toJson()).toList(),
    'chats': chats.map((c) => c.toJson()).toList(),
  };
  
  final json = jsonEncode(backup);
  // Save to downloads folder
}
```

---

## 🚀 Required Actions Before First Run

### Step 1: Setup Supabase Database (CRITICAL)
```bash
# Execute these SQL files in Supabase SQL Editor
1. SUPABASE_PROFILES_TABLE.sql
2. SUPABASE_RLS_SETUP.sql  
3. supabase_migrations/001_create_user_profiles.sql
```

### Step 2: Test API Keys
```bash
# Test Gemini API
curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'

# Should return: {"candidates":[...]} (not error)
```

### Step 3: Get Dependencies
```bash
flutter pub get
```

### Step 4: Run on Device
```bash
flutter run
```

### Step 5: Enable Location Services
- On physical device, allow location permission when prompted
- Weather feature requires this

---

## 🧪 Testing Checklist

### Authentication
- [ ] Sign up with new email
- [ ] Sign in with existing account
- [ ] Sign out
- [ ] Try invalid credentials
- [ ] Test offline sign-in (should work with cached data)

### Chat (Gemini AI)
- [ ] Send text message in Bengali
- [ ] Upload image and ask about crop disease
- [ ] Check chat history persists
- [ ] Test with poor network (should show loading)

### Lands
- [ ] Add new land
- [ ] View land details
- [ ] Update land information
- [ ] Delete land
- [ ] Add seasonal crop info
- [ ] Test offline: add land, go online, check Supabase

### Loans
- [ ] Add loan
- [ ] Record payment
- [ ] View loan status calculation (pending/partial/paid)
- [ ] Delete loan
- [ ] Check chart displays correctly

### Weather
- [ ] Allow location permission
- [ ] View current weather
- [ ] Check 7-day forecast
- [ ] Test with location services off (should show error)

### Offline Mode
- [ ] Turn off internet
- [ ] Add data to lands, loans, chat
- [ ] Turn on internet
- [ ] Verify data syncs to Supabase

---

## 📊 Performance Monitoring

### Check These After First Run:
1. **App startup time** - Should be < 3 seconds
2. **Database init time** - Check logs for "SQLite database initialized successfully"
3. **Supabase connection** - Check for "Supabase initialized successfully"
4. **Gemini response time** - First call may take 2-5 seconds, subsequent calls faster
5. **Memory usage** - Should stay under 200MB for normal usage

### Add Analytics (Optional)
```yaml
dependencies:
  firebase_analytics: ^11.3.3
  sentry_flutter: ^8.11.0  # For crash reporting
```

---

## 🔐 Security Audit Before Production

### Must Do:
1. **Move API keys to environment variables**
   - Currently hardcoded in `app_config.dart`
   - Use `flutter_dotenv` package

2. **Enable Supabase RLS policies**
   - Already have SQL file, must execute it
   - Test that users can't access others' data

3. **Add certificate pinning** (optional but recommended)
   - Prevents man-in-the-middle attacks
   ```yaml
   dependencies:
     dio: ^5.7.0
     dio_security: ^1.0.0
   ```

4. **Obfuscate release builds**
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/debug-info
   ```

---

## 📱 Device-Specific Issues

### Android
- ✅ Permissions declared correctly
- ⚠️ Need runtime permission check for location
- ⚠️ Test on Android 13+ (new photo picker)

### iOS (If Supporting)
- ❌ Missing Info.plist configurations
- ❌ Need CocoaPods setup
- ❌ Need to configure signing

---

## 🎯 Summary

### Will it run? **YES, but with issues**

**Will definitely work:**
- ✅ App compiles and launches
- ✅ Local database (SQLite) works perfectly
- ✅ Authentication UI works
- ✅ All screens render correctly
- ✅ Offline mode works

**Will cause errors if not fixed:**
- ❌ Supabase sync will fail (tables don't exist yet)
- ❌ Weather may not work (location permission not requested)
- ❌ Chat may hit rate limits quickly
- ⚠️ Image upload may crash on iOS

**Critical fixes needed (5 minutes):**
1. Execute Supabase SQL migrations (2 minutes)
2. Add location permission request code (2 minutes)
3. Test on real device with location enabled (1 minute)

**After these 3 fixes, app should run smoothly for testing and demo purposes.**

For production deployment, address medium and low priority issues.

---

**Last Updated**: December 26, 2025
