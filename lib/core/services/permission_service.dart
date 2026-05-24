import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  //TODO: Permisos según plataforma
  static List<Permission> get _btPerms => Platform.isIOS
      ? [Permission.bluetooth]
      : [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
        ];

  static Future<bool> bluetoothGranted() async {
    if (Platform.isIOS) {
      try {
        final state = await FlutterBluePlus.adapterState
            .firstWhere((s) => s != BluetoothAdapterState.unknown)
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () => BluetoothAdapterState.unauthorized,
            );
        return state != BluetoothAdapterState.unauthorized;
      } catch (_) {
        return false;
      }
    }

    for (final p in _btPerms) {
      if (!(await p.status).isGranted) return false;
    }
    return true;
  }

  static Future<bool> locationGranted() async {
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.whileInUse || p == LocationPermission.always;
  }

  static Future<bool> allGranted() async =>
      await bluetoothGranted() && await locationGranted();

  static Future<_PermStatus> requestBluetooth() async {
    for (final p in _btPerms) {
      final s = await p.status;
      if (s.isPermanentlyDenied) return _PermStatus.permanentlyDenied;
      if (!s.isGranted) {
        final r = await p.request();
        if (r.isPermanentlyDenied) return _PermStatus.permanentlyDenied;
        if (r.isDenied) return _PermStatus.denied;
      }
    }
    return _PermStatus.granted;
  }

  //TODO: solicitud de ubicaicon
  static Future<_PermStatus> requestLocation() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.deniedForever) {
      return _PermStatus.permanentlyDenied;
    }
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.deniedForever)
      return _PermStatus.permanentlyDenied;
    if (p == LocationPermission.denied) return _PermStatus.denied;
    return _PermStatus.granted;
  }

  //TODO: estado de servicios (encedid - apagado)
  static Future<bool> isBluetoothOn() async {
    try {
      final state = await FlutterBluePlus.adapterState
          .firstWhere((s) => s != BluetoothAdapterState.unknown)
          .timeout(const Duration(seconds: 3));
      return state == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isGpsOn() async => Geolocator.isLocationServiceEnabled();

  static Future<({bool bt, bool gps})> servicesStatus() async =>
      (bt: await isBluetoothOn(), gps: await isGpsOn());
}

enum _PermStatus { granted, denied, permanentlyDenied }

typedef PermStatus = _PermStatus;
