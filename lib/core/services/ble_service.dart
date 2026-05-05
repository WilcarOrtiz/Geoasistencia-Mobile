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
    final codeBytes = utf8.encode(codeClassSession);
    final manufacturerData = Uint8List(2 + codeBytes.length);
    manufacturerData[0] = _companyId & 0xFF;
    manufacturerData[1] = (_companyId >> 8) & 0xFF;
    manufacturerData.setRange(2, manufacturerData.length, codeBytes);

    final advertiseData = AdvertiseData(
      includeDeviceName: true, // ← activa el nombre
      localName: codeClassSession, // ← el nombre ES el código de sesión
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
  static Future<String> scanForCode(String codeClassSession) async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      throw Exception('Bluetooth está apagado.');
    }

    final completer = Completer<String>();
    StreamSubscription? scanSub;

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 12));

    scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final deviceName = result.advertisementData.localName;

        // ← Solo acepta el beacon cuyo nombre coincide con el código de su grupo
        if (deviceName == codeClassSession && !completer.isCompleted) {
          FlutterBluePlus.stopScan();
          scanSub?.cancel();
          completer.complete(codeClassSession);
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
