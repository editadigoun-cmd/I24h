/// Public build-time configuration for the I24H mobile application.
///
/// Pass the Supabase project URL and publishable key with --dart-define.
/// Publishable keys are intended for client applications; never put a
/// Supabase service-role key or payment-provider secret in the mobile app.
class I24HConfig {
  I24HConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'I24H_SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'I24H_SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String liveStreamUrl = String.fromEnvironment(
    'I24H_LIVE_STREAM_URL',
    defaultValue: '',
  );

  /// Retained for local/manual media testing only. Production replays should
  /// be loaded from the database, not embedded in the application binary.
  static const String replayCatalogJson = String.fromEnvironment(
    'I24H_REPLAY_CATALOG_JSON',
    defaultValue: '',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.startsWith('https://') &&
      supabasePublishableKey.isNotEmpty;
}
