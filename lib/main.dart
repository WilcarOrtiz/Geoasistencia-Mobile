import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/app.dart';
import 'package:geoasistencia/core/network/dio_client.dart';
import 'package:geoasistencia/core/utils/storage.dart';
import 'package:geoasistencia/features/auth/data/device_uuid_servoce.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await StorageService.init();
  await StorageService.clear();
  await DeviceService.init();
  DioClient.init();

  runApp(const ProviderScope(child: App()));
}
