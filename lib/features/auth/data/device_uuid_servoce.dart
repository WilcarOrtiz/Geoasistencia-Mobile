import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static String? _deviceId;

  static String? get deviceId => _deviceId;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString('device_id');

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString('device_id', id);
      print('🆕 [DeviceService] UUID generado: $id');
    } else {
      print('✅ [DeviceService] UUID recuperado: $id');
    }

    _deviceId = id;
  }
}
