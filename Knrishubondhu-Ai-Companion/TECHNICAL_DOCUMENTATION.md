# KrishiBondhu AI - Technical Documentation

## 📋 Table of Contents
- [Architecture Overview](#architecture-overview)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Core Features Implementation](#core-features-implementation)
- [Data Flow](#data-flow)
- [State Management](#state-management)
- [Database Schema](#database-schema)
- [API Integration](#api-integration)

---

## 🏗️ Architecture Overview

### Clean Architecture Pattern

The project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Screens, Widgets, ViewModels)    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Domain Layer                    │
│  (Entities, Use Cases, Repositories)    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Data Layer                     │
│  (Models, Repository Impl, Data Sources)│
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│        External Services                 │
│  (Supabase, Gemini AI, Weather API)    │
└─────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Presentation Layer** (`lib/features/*/presentation/`)
- **Screens**: UI pages that users interact with
- **Widgets**: Reusable UI components
- **Providers**: State management using Riverpod
- **ViewModels**: Business logic for UI (StateNotifier)

#### 2. **Domain Layer** (`lib/features/*/domain/`)
- **Entities**: Core business objects (immutable)
- **Use Cases**: Single responsibility business operations
- **Repositories**: Abstract interfaces for data operations

#### 3. **Data Layer** (`lib/features/*/data/`)
- **Models**: Data transfer objects with serialization
- **Repository Implementations**: Concrete data access logic
- **Data Sources**: Direct interaction with databases/APIs

---

## 🛠️ Technology Stack

### Frontend
- **Flutter 3.x**: Cross-platform UI framework
- **Dart 3.x**: Programming language

### State Management
- **Riverpod 2.5.1**: Reactive state management
- **StateNotifier**: For complex state handling

### Backend Services
- **Supabase**: Backend-as-a-Service
  - Authentication (email/password)
  - PostgreSQL database
  - Real-time subscriptions
  - Row Level Security (RLS)

### AI & APIs
- **Perenual Plant API** (PRIMARY): 
  - 10,000+ plant species database
  - Verified agricultural data
  - Plant care guides and requirements
  - Free tier: 300 requests/day
- **Google Gemini AI** (OPTIONAL FALLBACK - Currently Disabled): 
  - Text generation (gemini-1.5-flash)
  - Vision analysis for crop disease detection
  - Bengali language support
- **OpenWeatherMap API**: Real-time weather data and forecasts

### Local Storage
- **SQLite (sqflite)**: Local database for offline support
- **SharedPreferences**: Simple key-value storage

### Navigation
- **GoRouter**: Declarative routing

### Utilities
- **dartz**: Functional programming (Either for error handling)
- **uuid**: Unique ID generation
- **intl**: Internationalization and date formatting
- **geolocator**: GPS location services

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point
├── core/                          # Shared resources
│   ├── config/
│   │   └── app_config.dart       # Configuration constants
│   ├── services/
│   │   ├── database_service.dart  # SQLite management
│   │   ├── supabase_service.dart  # Supabase wrapper
│   │   ├── gemini_service.dart    # AI service
│   │   └── weather_service.dart   # Weather API
│   ├── router/
│   │   └── app_router.dart        # Navigation config
│   ├── providers/
│   │   ├── database_providers.dart
│   │   └── supabase_providers.dart
│   ├── theme/
│   │   └── app_theme.dart         # Material Design theme
│   ├── widgets/                   # Shared widgets
│   └── utils/
│       ├── logger.dart            # Logging utility
│       └── validators.dart        # Input validation
│
├── features/                      # Feature modules
│   ├── auth/                     # Authentication
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_usecase.dart
│   │   │       ├── sign_up_usecase.dart
│   │   │       └── sign_out_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── chat/                     # AI Chatbot
│   ├── lands/                    # Land Management
│   ├── loans/                    # Loan Tracking
│   ├── weather/                  # Weather Dashboard
│   ├── crop_calendar/            # Crop Planning
│   ├── forum/                    # Community Forum
│   └── profile/                  # User Profile
│
└── assets/
    └── data/
        └── crop_calendar.json    # Crop data
```

---

## 🎯 Core Features Implementation

### 1. **Authentication System**

#### Architecture
```
SignInScreen → AuthViewModel → SignInUseCase → AuthRepository → SupabaseService
                                                      ↓
                                                DatabaseService (local cache)
```

#### Key Files
- **Service**: `lib/core/services/supabase_service.dart`
- **Repository**: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- **Use Cases**: `lib/features/auth/domain/usecases/`
- **UI**: `lib/features/auth/presentation/screens/`

#### Flow
1. User enters email/password
2. `AuthViewModel` calls `SignInUseCase`
3. Use case invokes `AuthRepository.signIn()`
4. Repository communicates with Supabase Auth
5. On success, user data is cached locally in SQLite
6. Session token is stored for auto-login

#### Code Example
```dart
// Use Case
class SignInUseCase {
  final AuthRepository repository;
  
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signIn(
      email: email,
      password: password,
    );
  }
}

// Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseService supabaseService;
  final DatabaseService databaseService;
  
  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Call Supabase Auth
      final response = await supabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      // Convert to domain entity
      final user = UserModel.fromSupabaseUser(response.user!);
      
      // Cache locally
      await databaseService.insertUser(user.toDatabase());
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }
}
```

---

### 2. **AI Chatbot (Gemini Integration)**

#### Architecture
```
ChatScreen → ChatViewModel → SendMessageUseCase → ChatRepository → GeminiService
                                                         ↓
                                                   DatabaseService (chat history)
```

#### Key Components
- **Service**: `lib/core/services/gemini_service.dart`
- **Repository**: `lib/features/chat/data/repositories/chat_repository_impl.dart`
- **Provider**: `lib/features/chat/presentation/providers/chat_providers.dart`

### 2. **AI Chatbot**

#### Architecture (Updated v1.0.2)
```
ChatScreen → ChatViewModel → SendMessageUseCase → ChatRepository → PerenualService (PRIMARY)
                                                                  ↓
                                                             GeminiService (FALLBACK)
                                                                  ↓
                                                            DatabaseService (Chat History)
```

#### AI Service Priority Flow
1. **Detect plant-related query** using keyword matching (30+ Bengali/English terms)
2. **Translate Bengali → English** using built-in dictionary
3. **Query Perenual API** for verified plant data
4. **Generate 7-step cultivation guide**:
   - Soil preparation (pH, organic matter)
   - Planting guidelines (spacing, depth)
   - Watering schedule (frequency)
   - Sunlight requirements (hours/day)
   - Fertilizer application (NPK ratios)
   - Pest control methods
   - Harvesting tips
5. **Add special care** for specific crops (tomato, rice, corn)
6. **Fallback to Gemini AI** if Perenual fails or for non-plant queries (currently disabled)

#### Perenual Service Implementation
```dart
class PerenualService {
  static const String _baseUrl = 'https://perenual.com/api';
  
  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    final uri = Uri.parse('$_baseUrl/species-list').replace(
      queryParameters: {
        'key': AppConfig.perenualApiKey,
        'q': query,
      },
    );
    
    final response = await http.get(uri);
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }
}
```

#### Gemini Service Implementation (Optional Fallback)
```dart
class GeminiService {
  late final GenerativeModel _model;
  
  void initialize() {
    if (!AppConfig.isGeminiConfigured) {
      Logger.info('Gemini not configured, using Perenual only');
      return;
    }
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppConfig.geminiApiKey,
      systemInstruction: Content.text(_farmingExpertPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
  }
  
  Future<String> sendMessage(String message) async {
    final response = await _chatSession!.sendMessage(
      Content.text(message)
    );
    return response.text ?? 'দুঃখিত, উত্তর দিতে পারছি না।';
  }
}
```

#### Plant Name Translation
```dart
String _translatePlantName(String query) {
  final translations = {
    'টমেটো': 'tomato',
    'ধান': 'rice',
    'ভুট্টা': 'corn',
    'আলু': 'potato',
    // ... 30+ more crops
  };
  
  for (var entry in translations.entries) {
    if (query.toLowerCase().contains(entry.key)) {
      return entry.value;
    }
  }
  return query;
}
```

#### Chat History Storage
- **Text-based chat**: Uses Perenual Plant API (primary) or gemini-1.5-flash (fallback)
- **Image analysis**: Uses gemini-1.5-flash with vision (when enabled)
- **Context-aware**: Bengali language support with expert cultivation guides
- **Chat history**: Persisted in SQLite and synced to Supabase

---

### 3. **Land Management**

#### Architecture
```
LandsScreen → LandsViewModel → GetAllLandsUseCase → LandRepository → SupabaseService
                                                              ↓
                                                        DatabaseService (SQLite)
```

#### Data Synchronization Strategy

**Offline-First Architecture**:
1. All operations write to local SQLite first
2. Background sync with Supabase when online
3. Conflict resolution: Last-write-wins based on `updated_at` timestamp

```dart
class LandRepositoryImpl implements LandRepository {
  @override
  Future<Either<String, List<Land>>> getAllLands() async {
    // 1. Get from local SQLite
    final db = await databaseService.database;
    final user = supabaseService.currentUser;
    
    final results = await db.query(
      'lands',
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
    
    final lands = results.map((map) => 
      LandModel.fromDatabase(map)
    ).toList();
    
    // 2. Trigger background sync (fire and forget)
    syncLands();
    
    return Right(lands);
  }
  
  @override
  Future<Either<String, Land>> addLand({...}) async {
    // 1. Insert into SQLite immediately
    await db.insert('lands', land.toDatabase());
    
    // 2. Try to sync to Supabase (non-blocking)
    try {
      await supabaseService.insertData('lands', land.toSupabase());
    } catch (e) {
      Logger.warning('Sync failed, will retry later');
    }
    
    return Right(land);
  }
  
  @override
  Future<Either<String, void>> syncLands() async {
    // Bi-directional sync
    final supabaseLands = await supabaseService.queryData('lands');
    
    for (final landData in supabaseLands) {
      final land = LandModel.fromSupabase(landData);
      final existing = await db.query('lands', 
        where: 'id = ?', whereArgs: [land.id]);
      
      if (existing.isEmpty) {
        await db.insert('lands', land.toDatabase());
      } else {
        // Conflict resolution: use newer data
        final existingLand = LandModel.fromDatabase(existing.first);
        if (land.updatedAt.isAfter(existingLand.updatedAt)) {
          await db.update('lands', land.toDatabase());
        }
      }
    }
  }
}
```

---

### 4. **Weather Dashboard**

#### Architecture
```
WeatherScreen → WeatherViewModel → GetWeatherUseCase → WeatherRepository → WeatherService (Open-Meteo API)
```

#### Key Features
- GPS-based location detection
- 7-day forecast
- Weather caching (24-hour validity)
- Bengali weather descriptions

#### Implementation
```dart
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,relative_humidity_2m,weather_code',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'Asia/Dhaka',
        'forecast_days': '7',
      },
    );
    
    final response = await http.get(uri).timeout(
      const Duration(seconds: 10),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Weather API error: ${response.statusCode}');
    }
  }
}
```

---

### 5. **Loan Tracking**

#### Features
- Add/update/delete loans
- Automatic status calculation (pending/partial/paid)
- Visual charts using fl_chart
- Payment tracking with history

#### State Management
```dart
class LoansViewModel extends StateNotifier<LoansState> {
  final GetAllLoansUseCase getAllLoansUseCase;
  final AddLoanUseCase addLoanUseCase;
  final UpdateLoanUseCase updateLoanUseCase;
  
  Future<void> loadLoans() async {
    state = state.copyWith(isLoading: true);
    
    final result = await getAllLoansUseCase();
    
    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error,
      ),
      (loans) => state = state.copyWith(
        isLoading: false,
        loans: loans,
        errorMessage: null,
      ),
    );
  }
  
  Future<void> updateLoanPayment({
    required String loanId,
    required double paidAmount,
  }) async {
    final result = await updateLoanUseCase(
      loanId: loanId,
      paidAmount: paidAmount,
    );
    
    result.fold(
      (error) => _showError(error),
      (_) => loadLoans(), // Refresh list
    );
  }
}
```

---

## 🔄 Data Flow

### Complete Data Flow Example: Adding a Land

```
User Action (Add Land Button)
       ↓
[LandFormScreen] User fills form
       ↓
[AddLandViewModel] Validates input
       ↓
[AddLandUseCase] Business logic
       ↓
[LandRepository] Data access
       ↓
┌──────────────────────┬──────────────────────┐
│                      │                      │
[DatabaseService]  [SupabaseService]     [State Update]
SQLite Insert      API POST /lands       Riverpod Notify
       │                    │                  │
       ↓                    ↓                  ↓
Local Storage         Cloud Storage      UI Refresh
```

### Error Handling Pattern

Using `Either` from `dartz` package:

```dart
// Success: Right(data)
// Failure: Left(error)

Future<Either<String, Land>> addLand() async {
  try {
    final land = await _performInsert();
    return Right(land);  // Success
  } catch (e) {
    return Left('Error: ${e.toString()}');  // Failure
  }
}

// Usage in ViewModel
final result = await addLandUseCase();
result.fold(
  (error) => showErrorSnackBar(error),
  (land) => showSuccessSnackBar('Land added'),
);
```

---

## 📊 State Management

### Riverpod Architecture

```dart
// 1. Provider (Dependency Injection)
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

// 2. Repository Provider
final landRepositoryProvider = Provider<LandRepository>((ref) {
  return LandRepositoryImpl(
    databaseService: ref.read(databaseServiceProvider),
    supabaseService: ref.read(supabaseServiceProvider),
    uuid: ref.read(uuidProvider),
  );
});

// 3. Use Case Provider
final getAllLandsUseCaseProvider = Provider<GetAllLandsUseCase>((ref) {
  return GetAllLandsUseCase(ref.read(landRepositoryProvider));
});

// 4. ViewModel Provider (StateNotifier)
final landsViewModelProvider = 
    StateNotifierProvider<LandsViewModel, LandsState>((ref) {
  return LandsViewModel(
    getAllLoansUseCase: ref.read(getAllLandsUseCaseProvider),
    addLandUseCase: ref.read(addLandUseCaseProvider),
  );
});
```

### State Class Example

```dart
@freezed
class LandsState with _$LandsState {
  const factory LandsState({
    @Default(false) bool isLoading,
    @Default([]) List<Land> lands,
    String? errorMessage,
    Land? selectedLand,
  }) = _LandsState;
}
```

---

## 🗄️ Database Schema

### SQLite (Local Storage)

#### Users Table
```sql
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
```

#### Lands Table
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

#### Loans Table
```sql
CREATE TABLE loans (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  lender_name TEXT NOT NULL,
  amount REAL NOT NULL,
  paid_amount REAL DEFAULT 0,
  purpose TEXT,
  loan_date INTEGER NOT NULL,
  due_date INTEGER,
  status TEXT DEFAULT 'pending',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  synced INTEGER DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)
```

#### Chat History Table
```sql
CREATE TABLE chat_history (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  message TEXT NOT NULL,
  response TEXT NOT NULL,
  image_path TEXT,
  created_at INTEGER NOT NULL,
  synced INTEGER DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)
```

### Supabase (Cloud Storage)

Same schema as SQLite but with PostgreSQL data types and RLS policies.

#### Row Level Security Policies

```sql
-- Users can only access their own data
CREATE POLICY "Users can view own lands"
  ON lands FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lands"
  ON lands FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lands"
  ON lands FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own lands"
  ON lands FOR DELETE
  USING (auth.uid() = user_id);
```

---

## 🔌 API Integration

### 1. Supabase API

**Authentication**
```dart
// Sign up
final response = await supabase.auth.signUp(
  email: email,
  password: password,
  data: {'full_name': fullName},
);

// Sign in
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);
```

**Database Operations**
```dart
// Insert
await supabase.from('lands').insert({
  'id': uuid,
  'user_id': userId,
  'name': name,
  'area': area,
});

// Query
final data = await supabase
  .from('lands')
  .select()
  .eq('user_id', userId)
  .order('created_at', ascending: false);

// Update
await supabase
  .from('lands')
  .update({'name': newName})
  .eq('id', landId);

// Delete
await supabase
  .from('lands')
  .delete()
  .eq('id', landId);
```

### 2. Perenual Plant API (v1.0.2+)

**Primary Data Source for Plant Information**

```dart
class PerenualService {
  static const String _baseUrl = 'https://perenual.com/api';
  static const String apiKey = AppConfig.perenualApiKey;
  
  /// Search plants by name
  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    final uri = Uri.parse('$_baseUrl/species-list').replace(
      queryParameters: {
        'key': apiKey,
        'q': query,
        'page': '1',
      },
    );
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key');
    }
    throw Exception('API error: ${response.statusCode}');
  }
  
  /// Get plant details by ID
  Future<Map<String, dynamic>> getPlantDetails(int plantId) async {
    final uri = Uri.parse('$_baseUrl/species/details/$plantId').replace(
      queryParameters: {'key': apiKey},
    );
    
    final response = await http.get(uri);
    return json.decode(response.body);
  }
  
  /// Get plant care guide
  Future<Map<String, dynamic>> getPlantCareGuide(int plantId) async {
    final uri = Uri.parse('$_baseUrl/species-care-guide-list').replace(
      queryParameters: {
        'key': apiKey,
        'species_id': plantId.toString(),
      },
    );
    
    final response = await http.get(uri);
    return json.decode(response.body);
  }
}
```

**API Response Structure:**
```json
{
  "data": [
    {
      "id": 123,
      "common_name": "Tomato",
      "scientific_name": "Solanum lycopersicum",
      "watering": "Average",
      "sunlight": ["Full sun"],
      "cycle": "Annual",
      "watering_period": "Weekly"
    }
  ]
}
```

### 3. Gemini AI API (Optional Fallback)

### 3. Gemini AI API (Optional Fallback)

**Note:** Currently disabled in v1.0.2. Perenual is primary source.

```dart
// Text generation (when enabled)
final model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: AppConfig.geminiApiKey,
  systemInstruction: Content.text(farmingExpertPrompt),
);

final content = [Content.text(prompt)];
final response = await model.generateContent(content);
final text = response.text;

// Image analysis (when enabled)
final imageBytes = await file.readAsBytes();
final content = [
  Content.multi([
    TextPart(prompt),
    DataPart('image/jpeg', imageBytes),
  ])
];

final response = await model.generateContent(content);
```

### 4. OpenWeatherMap API

### 4. OpenWeatherMap API

```dart
class WeatherService {
  static const String apiKey = 'YOUR_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$_baseUrl/weather').replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': apiKey,
        'units': 'metric',
      },
    );
    
    final response = await http.get(uri);
    return jsonDecode(response.body);
  }
  
  Future<Map<String, dynamic>> get7DayForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$_baseUrl/forecast').replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': apiKey,
        'units': 'metric',
        'cnt': '56', // 7 days * 8 (3-hour intervals)
      },
    );
    
    final response = await http.get(uri);
    return jsonDecode(response.body);
  }
}
```

**API Response Structure:**
```json
{
  "main": {
    "temp": 28.5,
    "humidity": 65
  },
  "weather": [{
    "description": "scattered clouds",
    "icon": "02d"
  }],
  "wind": {
    "speed": 3.5
  }
}
```

---

## 🔐 Security Considerations

### 1. API Key Management
- Stored in `app_config.dart` (excluded from git via .gitignore in production)
- Never hardcode in UI or exposed files

### 2. Authentication
- JWT tokens managed by Supabase
- Auto-refresh on expiry
- Secure session storage

### 3. Row Level Security (RLS)
- Enforced at database level
- Users can only access their own data
- SQL injection protection

### 4. Input Validation
- Client-side validation using validators
- Server-side validation via Supabase policies

---

## 🚀 Performance Optimizations

### 1. Offline-First Strategy
- Immediate UI response from local database
- Background sync with cloud
- No blocking network calls

### 2. Lazy Loading
- Images loaded on demand
- Chat history paginated
- Weather cache (24-hour validity)

### 3. State Management
- Selective widget rebuilds using Riverpod
- Immutable state objects
- Provider disposal when not needed

### 4. Database Optimization
- Indexed foreign keys
- Efficient queries with WHERE clauses
- Batch operations for sync

---

## 📱 Build and Deployment

### Development Build
```bash
flutter run
```

### Release Build (Android)
```bash
flutter build apk --release
flutter build appbundle --release
```

### Environment Configuration
```dart
// app_config.dart
class AppConfig {
  static const String supabaseUrl = env.SUPABASE_URL;
  static const String supabaseAnonKey = env.SUPABASE_ANON_KEY;
  static const String geminiApiKey = env.GEMINI_API_KEY;
  static const bool isDebugMode = kDebugMode;
}
```

---

## 🧪 Testing

### Unit Tests
```dart
test('LandRepository adds land successfully', () async {
  final repository = LandRepositoryImpl(
    databaseService: mockDatabase,
    supabaseService: mockSupabase,
    uuid: mockUuid,
  );
  
  final result = await repository.addLand(
    name: 'Test Land',
    location: 'Dhaka',
    area: 5.0,
  );
  
  expect(result.isRight(), true);
});
```

### Widget Tests
```dart
testWidgets('Login screen displays correctly', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: LoginScreen()),
  );
  
  expect(find.text('Login'), findsOneWidget);
  expect(find.byType(TextField), findsNWidgets(2));
});
```

---

## 📖 Code Conventions

### Naming Conventions
- **Classes**: PascalCase (`LandRepository`)
- **Files**: snake_case (`land_repository.dart`)
- **Variables**: camelCase (`userName`)
- **Constants**: camelCase (`maxLength`)
- **Private members**: `_prefixWithUnderscore`

### File Organization
```dart
// 1. Imports (grouped)
import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/entities/land.dart';
import '../../../core/utils/logger.dart';

// 2. Class definition
class LandRepository {
  // 3. Private fields
  final DatabaseService _databaseService;
  
  // 4. Constructor
  LandRepository(this._databaseService);
  
  // 5. Public methods
  Future<List<Land>> getAllLands() async { }
  
  // 6. Private methods
  void _log(String message) { }
}
```

### Documentation
```dart
/// Repository for managing land data.
///
/// Provides CRUD operations for lands with both local
/// and cloud storage synchronization.
class LandRepository {
  /// Fetches all lands for the current user.
  ///
  /// Returns [Right] with list of lands on success,
  /// [Left] with error message on failure.
  Future<Either<String, List<Land>>> getAllLands() async { }
}
```

---

## 🔧 Troubleshooting

### Common Issues

1. **Supabase Connection Error**
   - Check API keys in `app_config.dart`
   - Verify RLS policies are set correctly
   - Ensure user is authenticated

2. **Perenual API Issues** *(v1.0.2+)*
   - Verify API key is valid (format: `sk-xxxx`)
   - Free tier: 300 requests/day limit
   - Check plant name spelling (use English names)
   - Review Bengali translation dictionary

3. **Gemini AI Not Responding** *(Optional Fallback)*
   - Verify API key is valid
   - Check if Gemini is enabled in config
   - Check internet connection
   - Review rate limits

4. **OpenWeatherMap API Errors**
   - Verify API key activation (can take 2 hours)
   - Free tier: 1,000 calls/day
   - Check location coordinates

5. **SQLite Errors**
   - Clear app data
   - Check database version migrations
   - Verify foreign key constraints

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Perenual Plant API](https://perenual.com/docs/api) *(v1.0.2+)*
- [OpenWeatherMap API](https://openweathermap.org/api)
- [Gemini AI Documentation](https://ai.google.dev/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 📝 Version History

### v1.0.2+3 (December 31, 2025) - Current
- ✅ Integrated Perenual Plant API as primary data source
- ✅ Added 30+ Bengali to English plant translations
- ✅ Implemented 7-step detailed cultivation guides
- ✅ Made Gemini AI optional fallback (currently disabled)
- ✅ Switched to OpenWeatherMap API
- ✅ Enhanced API key security with .gitignore

### v1.0.1 (December 28, 2025)
- Initial production release
- Core features: Auth, Chat, Weather, Lands, Loans
- Clean Architecture implementation
- Offline-first with SQLite + Supabase sync

---

**Last Updated**: December 31, 2025  
**Version**: 1.0.2+3  
**Status**: ✅ Production Ready
