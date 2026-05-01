import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAllPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();

    final denied = statuses.values.any(
      (s) => s.isDenied || s.isPermanentlyDenied,
    );

    if (denied) {
      await openAppSettings();
      return false;
    }

    return true;
  }

  static String label(Permission p) {
    switch (p) {
      case Permission.bluetoothAdvertise:
        return 'Bluetooth (emitir)';
      case Permission.bluetoothScan:
        return 'Bluetooth (escanear)';
      case Permission.bluetoothConnect:
        return 'Bluetooth (conectar)';
      case Permission.locationWhenInUse:
        return 'Ubicación';
      default:
        return p.toString();
    }
  }
}
