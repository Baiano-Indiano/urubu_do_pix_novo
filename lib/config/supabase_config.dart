import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://okprgkawjuqtuhqtqknj.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9rcHJna2F3anVxdHVocXRxa25qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1MTQxNzgsImV4cCI6MjA2MzA5MDE3OH0.Fm6Lg-pxvnlUu8X_k0q1wMIck_UMHvPrgpvCSqoVCss';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: true,
    );
  }
}
