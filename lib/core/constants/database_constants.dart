/// Database table names
class DatabaseTables {
  static const String users = 'users';
  static const String lands = 'lands';
  static const String loans = 'loans';
  static const String chatHistory = 'chat_history';
  static const String weatherCache = 'weather_cache';
}

/// Database column names for Users table
class UsersColumns {
  static const String id = 'id';
  static const String supabaseId = 'supabase_id';
  static const String email = 'email';
  static const String fullName = 'full_name';
  static const String phoneNumber = 'phone_number';
  static const String avatarUrl = 'avatar_url';
  static const String role = 'role';
  static const String isSynced = 'is_synced';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Database column names for Lands table
class LandsColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String name = 'name';
  static const String location = 'location';
  static const String areaInAcres = 'area_in_acres';
  static const String soilType = 'soil_type';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String crops = 'crops';
  static const String imageUrl = 'image_url';
  static const String isSynced = 'is_synced';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Database column names for Loans table
class LoansColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String loanType = 'loan_type';
  static const String amount = 'amount';
  static const String interestRate = 'interest_rate';
  static const String durationMonths = 'duration_months';
  static const String status = 'status';
  static const String appliedDate = 'applied_date';
  static const String approvedDate = 'approved_date';
  static const String disbursedDate = 'disbursed_date';
  static const String repaymentStartDate = 'repayment_start_date';
  static const String bankName = 'bank_name';
  static const String loanOfficer = 'loan_officer';
  static const String notes = 'notes';
  static const String isSynced = 'is_synced';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Database column names for Chat History table
class ChatHistoryColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String sessionId = 'session_id';
  static const String message = 'message';
  static const String sender = 'sender';
  static const String messageType = 'message_type';
  static const String metadata = 'metadata';
  static const String isSynced = 'is_synced';
  static const String createdAt = 'created_at';
}

/// Database column names for Weather Cache table
class WeatherCacheColumns {
  static const String id = 'id';
  static const String location = 'location';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String temperature = 'temperature';
  static const String humidity = 'humidity';
  static const String windSpeed = 'wind_speed';
  static const String weatherCondition = 'weather_condition';
  static const String description = 'description';
  static const String iconCode = 'icon_code';
  static const String forecastData = 'forecast_data';
  static const String cachedAt = 'cached_at';
  static const String expiresAt = 'expires_at';
}

/// Loan status values
class LoanStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String disbursed = 'disbursed';
  static const String completed = 'completed';
  static const String defaulted = 'defaulted';
}

/// User roles
class UserRoles {
  static const String farmer = 'farmer';
  static const String admin = 'admin';
  static const String loanOfficer = 'loan_officer';
}

/// Chat message senders
class ChatSender {
  static const String user = 'user';
  static const String ai = 'ai';
  static const String system = 'system';
}

/// Chat message types
class ChatMessageType {
  static const String text = 'text';
  static const String image = 'image';
  static const String voice = 'voice';
  static const String file = 'file';
}
