// core/services/ble_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:quick_blue/quick_blue.dart';

class BleService {
  static const _serviceUuid = '0000ABCD-0000-1000-8000-00805F9B34FB';
  static const _characteristicUuid = '0000ABCE-0000-1000-8000-00805F9B34FB';

  // ── DOCENTE: emitir código ──────────────────────────────
  static Future<void> startAdvertising(String codeClassSession) async {
    await QuickBlue.startAdvertising(
      serviceUuid: _serviceUuid,
      localName: 'GeoAsistencia',
    );

    // Cuando un estudiante se conecte y lea la característica,
    // respondemos con el código
    QuickBlue.setReadHandler((deviceId, characteristicId, value) {
      // handled below
    });

    QuickBlue.setRequestHandler((
      deviceId,
      requestId,
      offset,
      characteristicId,
    ) {
      if (characteristicId == _characteristicUuid) {
        QuickBlue.sendResponse(
          deviceId,
          requestId,
          utf8.encode(codeClassSession),
        );
      }
    });
  }

  static Future<void> stopAdvertising() async {
    await QuickBlue.stopAdvertising();
  }

  // ── ESTUDIANTE: escanear y leer código ─────────────────
  static Future<String> scanForCode() async {
    final completer = Completer<String>();

    // 1. Escanear dispositivos que anuncien nuestro servicio
    FlutterBluePlus.startScan(
      withServices: [Guid(_serviceUuid)],
      timeout: const Duration(seconds: 10),
    );

    StreamSubscription? scanSub;
    scanSub = FlutterBluePlus.scanResults.listen((results) async {
      if (results.isEmpty) return;

      final device = results.first.device;
      await FlutterBluePlus.stopScan();
      scanSub?.cancel();

      // 2. Conectar y leer la característica
      await device.connect(timeout: const Duration(seconds: 5));
      final services = await device.discoverServices();

      for (final service in services) {
        if (service.uuid.toString().toUpperCase() == _serviceUuid) {
          for (final char in service.characteristics) {
            if (char.uuid.toString().toUpperCase() == _characteristicUuid) {
              final value = await char.read();
              final code = utf8.decode(value);
              await device.disconnect();
              if (!completer.isCompleted) completer.complete(code);
            }
          }
        }
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        scanSub?.cancel();
        FlutterBluePlus.stopScan();
        throw Exception('No se encontró sesión activa cerca');
      },
    );
  }
}
