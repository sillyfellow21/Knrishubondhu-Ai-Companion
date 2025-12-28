import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';

/// Provider for Supabase Service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});
