/// Runtime configuration for the I24H mobile app.
///
/// Supply the live stream URL at build time, for example:
/// flutter run --dart-define=I24H_LIVE_STREAM_URL=https://radio.example.com/live.mp3
///
/// Do not put secret credentials in dart-define; values are bundled into the app.
class I24HConfig {
  I24HConfig._();

  static const String liveStreamUrl = String.fromEnvironment(
    'I24H_LIVE_STREAM_URL',
    defaultValue: '',
  );
}
