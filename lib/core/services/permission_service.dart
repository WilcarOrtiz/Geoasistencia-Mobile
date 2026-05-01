import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static List<Permission> get _bluetoothPermissions => Platform.isIOS
      ? [Permission.bluetooth]
      : [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
        ];

  // ── ¿Ya están todos concedidos? ────────────────────────────────────────────

  static Future<bool> allGranted() async {
    for (final p in _bluetoothPermissions) {
      if (!(await p.status).isGranted) return false;
    }
    final locPerm = await Geolocator.checkPermission();
    return locPerm == LocationPermission.whileInUse ||
        locPerm == LocationPermission.always;
  }

  // ── Solicitar permisos ────────────────────────────────────────────────────

  static Future<PermissionResult> requestAllPermissions() async {
    // Paso 1: Bluetooth
    for (final p in _bluetoothPermissions) {
      final status = await p.status;
      if (status.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied;
      }
      if (!status.isGranted) {
        final result = await p.request();
        if (result.isPermanentlyDenied)
          return PermissionResult.permanentlyDenied;
        if (result.isDenied) return PermissionResult.denied;
      }
    }

    // Pausa: iOS necesita cerrar el diálogo de BT antes de abrir el de ubicación
    if (Platform.isIOS) {
      await Future.delayed(const Duration(milliseconds: 800));
    }

    // Paso 2: Ubicación con geolocator
    LocationPermission locPerm = await Geolocator.checkPermission();

    if (locPerm == LocationPermission.deniedForever) {
      return PermissionResult.permanentlyDenied;
    }

    if (locPerm == LocationPermission.denied) {
      locPerm = await Geolocator.requestPermission();
    }

    if (locPerm == LocationPermission.deniedForever) {
      return PermissionResult.permanentlyDenied;
    }

    if (locPerm == LocationPermission.denied) {
      return PermissionResult.denied;
    }

    return PermissionResult.granted;
  }

  // ── Estado de servicios ───────────────────────────────────────────────────

  static Future<bool> isBluetoothOn() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  static Future<bool> isGpsOn() async {
    return Geolocator.isLocationServiceEnabled();
  }

  static Future<Map<String, bool>> servicesStatus() async {
    return {'bluetooth': await isBluetoothOn(), 'gps': await isGpsOn()};
  }
}

enum PermissionResult { granted, denied, permanentlyDenied }
