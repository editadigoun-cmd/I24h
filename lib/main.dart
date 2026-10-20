import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/i24h_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!I24HConfig.hasSupabaseConfig) {
    I24HConfig.backendError =
        'Configuration Supabase absente ou invalide dans cette version de l’application.';
  } else {
    try {
      await Supabase.initialize(
        url: I24HConfig.supabaseUrl,
        publishableKey: I24HConfig.supabasePublishableKey,
      );
      I24HConfig.backendReady = true;
      I24HConfig.backendError = null;
    } catch (error, stackTrace) {
      I24HConfig.backendReady = false;
      I24HConfig.backendError = error.toString();
      debugPrint('I24H backend initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  runApp(const I24HApp());
}
