// DOCENTE  → anuncia como periférico BLE con flutter_ble_peripheral
//            el código de sesión va en el campo manufacturerData del beacon.
//
// ALUMNO   → escanea con flutter_blue_plus, lee manufacturerData del beacon,
//            extrae el código.  Solo recibe el código si está físicamente cerca
//            (~10 m), que es la verificación de proximidad requerida.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  // Company ID arbitrario para el manufacturer data (0xFFFF = sin registro)
  static const int _companyId = 0xFFFF;

  // ── DOCENTE: emitir código ──────────────────────────────────────────────────

  static final _peripheral = FlutterBlePeripheral();

  /// Inicia el advertising BLE con el código de sesión embebido en
  /// manufacturerData.  El alumno lo lee durante el scan sin necesidad
  /// de conectarse (más rápido, más robusto).
  static Future<void> startAdvertising(String codeClassSession) async {
    // Codificamos el UUID (36 bytes UTF-8) en los datos del fabricante
    final codeBytes = utf8.encode(codeClassSession);

    // ManufacturerData = [companyId LSB, companyId MSB, ...codeBytes]
    final manufacturerData = Uint8List(2 + codeBytes.length);
    manufacturerData[0] = _companyId & 0xFF;
    manufacturerData[1] = (_companyId >> 8) & 0xFF;
    manufacturerData.setRange(2, manufacturerData.length, codeBytes);

    final advertiseData = AdvertiseData(
      includeDeviceName: false, // no desperdiciar bytes con el nombre
      manufacturerData: manufacturerData,
    );

    await _peripheral.start(advertiseData: advertiseData);
  }

  static Future<void> stopAdvertising() async {
    await _peripheral.stop();
  }

  // ── ALUMNO: escanear y leer código ─────────────────────────────────────────

  /// Escanea dispositivos BLE cercanos y extrae el code_class_session del
  /// manufacturerData.  Lanza excepción si no lo encuentra en 15 segundos.
  static Future<String> scanForCode() async {
    // Verificar que Bluetooth esté encendido
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      throw Exception('Bluetooth está apagado. Actívalo e intenta de nuevo.');
    }

    final completer = Completer<String>();
    StreamSubscription? scanSub;

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 12));

    scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        // Buscamos nuestro companyId en los manufacturer data del beacon
        final mfrData = result.advertisementData.manufacturerData;
        final payload = mfrData[_companyId];

        if (payload != null && payload.isNotEmpty) {
          try {
            final code = utf8.decode(payload);
            // Validación básica: debe tener formato UUID v4 (36 chars con guiones)
            if (_isValidUuid(code) && !completer.isCompleted) {
              FlutterBluePlus.stopScan();
              scanSub?.cancel();
              completer.complete(code);
            }
          } catch (_) {
            // No era texto UTF-8 válido, ignorar este beacon
          }
        }
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        scanSub?.cancel();
        FlutterBluePlus.stopScan();
        throw Exception(
          'No se encontró sesión activa cerca.\n'
          'Asegúrate de que:\n'
          '• El docente haya iniciado el llamado a lista\n'
          '• Tengas Bluetooth activado\n'
          '• Estés cerca del docente',
        );
      },
    );
  }

  static bool _isValidUuid(String s) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(s);
  }
}
