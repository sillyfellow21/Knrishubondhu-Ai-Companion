class InputValidator {
  // Validate Bengali/English name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'নাম লিখুন';
    }
    if (value.trim().length < 2) {
      return 'নাম কমপক্ষে ২ অক্ষরের হতে হবে';
    }
    if (value.trim().length > 50) {
      return 'নাম সর্বোচ্চ ৫০ অক্ষরের হতে হবে';
    }
    return null;
  }
  
  // Validate phone number (Bangladesh)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ফোন নম্বর লিখুন';
    }
    
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length != 11 && cleaned.length != 13) {
      return 'সঠিক ফোন নম্বর লিখুন (১১ সংখ্যা)';
    }
    
    if (cleaned.length == 11 && !cleaned.startsWith('01')) {
      return 'ফোন নম্বর ০১ দিয়ে শুরু হতে হবে';
    }
    
    if (cleaned.length == 13 && !cleaned.startsWith('880')) {
      return 'কান্ট্রি কোড ৮৮০ হতে হবে';
    }
    
    return null;
  }
  
  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ইমেইল লিখুন';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'সঠিক ইমেইল লিখুন';
    }
    
    return null;
  }
  
  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'পাসওয়ার্ড লিখুন';
    }
    if (value.length < 6) {
      return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
    }
    if (value.length > 50) {
      return 'পাসওয়ার্ড সর্বোচ্চ ৫০ অক্ষরের হতে হবে';
    }
    return null;
  }
  
  // Validate amount (money)
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'পরিমাণ লিখুন';
    }
    
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'সঠিক সংখ্যা লিখুন';
    }
    
    if (amount < 0) {
      return 'পরিমাণ ০-এর কম হতে পারবে না';
    }
    
    if (amount > 100000000) {
      return 'পরিমাণ খুব বেশি';
    }
    
    return null;
  }
  
  // Validate land area
  static String? validateLandArea(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'জমির পরিমাণ লিখুন';
    }
    
    final area = double.tryParse(value.trim());
    if (area == null) {
      return 'সঠিক সংখ্যা লিখুন';
    }
    
    if (area <= 0) {
      return 'জমির পরিমাণ ০-এর বেশি হতে হবে';
    }
    
    if (area > 10000) {
      return 'জমির পরিমাণ খুব বেশি';
    }
    
    return null;
  }
  
  // Sanitize text input (remove dangerous characters)
  static String sanitizeText(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>{}]'), '') // Remove HTML/script tags
        .replaceAll(RegExp(r'[\r\n]+'), ' ') // Replace newlines with space
        .replaceAll(RegExp(r'\s+'), ' '); // Remove extra spaces
  }
  
  // Sanitize for SQL (basic protection, though using parameterized queries is better)
  static String sanitizeForSQL(String input) {
    return input
        .replaceAll("'", "''")
        .replaceAll(';', '')
        .replaceAll('--', '');
  }
}
