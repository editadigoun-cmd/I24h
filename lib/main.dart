import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/i24h_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (I24HConfig.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: I24HConfig.supabaseUrl,
        publishableKey: I24HConfig.supabasePublishableKey,
      );
      I24HConfig.backendReady = true;
    } catch (error) {
      // Keep the app launchable so the login screen can explain that backend
      // configuration needs attention. Do not silently grant access.
      debugPrint('I24H backend initialization failed: $error');
    }
  }

  runApp(const I24HApp());
}
