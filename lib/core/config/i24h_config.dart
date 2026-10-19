/// Runtime configuration for the I24H mobile app.
///
/// Live stream:
/// flutter run --dart-define=I24H_LIVE_STREAM_URL=https://radio.example.com/live.mp3
///
/// Optional replay catalog JSON, each item has title, subtitle and url:
/// --dart-define='I24H_REPLAY_CATALOG_JSON=[{"title":"Émission","subtitle":"Durée · date","url":"https://.../episode.mp3"}]'
///
/// These values are bundled into the application. Never place secret credentials here.
class I24HConfig {
  I24HConfig._();

  static const String liveStreamUrl = String.fromEnvironment(
    'I24H_LIVE_STREAM_URL',
    defaultValue: '',
  );

  static const String replayCatalogJson = String.fromEnvironment(
    'I24H_REPLAY_CATALOG_JSON',
    defaultValue: '',
  );
}
