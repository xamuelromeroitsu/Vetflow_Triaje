import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  await dotenv.load(fileName: '.env');

  final url = dotenv.env['SUPABASE_URL']?.trim();
  final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();
  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    throw StateError(
      'Configura SUPABASE_URL y SUPABASE_ANON_KEY en vetflow_triaje/.env.',
    );
  }
  if (anonKey == 'REPLACE_WITH_SUPABASE_ANON_KEY') {
    throw StateError(
      'Reemplaza SUPABASE_ANON_KEY en vetflow_triaje/.env por la clave '
      'pública anon/publishable del proyecto.',
    );
  }

  await Supabase.initialize(url: url, publishableKey: anonKey);
}
