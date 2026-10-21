/// Public build-time configuration for the I24H mobile application.
///
/// The Supabase URL and publishable key are public client configuration.
/// Never put a Supabase service-role key or payment-provider secret in the app.
/// Build-time defines can override these defaults for staging or another project.
class I24HConfig {
  I24HConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'I24H_SUPABASE_URL',
    defaultValue: 'https://pwujpjjoxxqupckurrad.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'I24H_SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_u7eKQeWIvlrbMlsHO_uiSw_op8UW9ew',
  );

  static const String liveVideoUrl = String.fromEnvironment(
    'I24H_LIVE_VIDEO_URL',
    defaultValue: '',
  );

  /// Separate audio-only rendition required to genuinely save mobile data.
  static const String liveAudioUrl = String.fromEnvironment(
    'I24H_LIVE_AUDIO_URL',
    defaultValue: '',
  );

  /// Legacy audio setting kept for existing replay/test builds.
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

  static bool backendReady = false;
  static String? backendError;

  static bool get hasSupabaseConfig =>
      supabaseUrl.startsWith('https://') &&
      supabasePublishableKey.startsWith('sb_publishable_') &&
      supabasePublishableKey.length > 20;
}
