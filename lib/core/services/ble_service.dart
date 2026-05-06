import 'dart:async';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final _peripheral = FlutterBlePeripheral();

  // ── DOCENTE: emitir código ──────────────────────────────────────────────────

  /// El código de sesión SE USA DIRECTAMENTE como ServiceUUID.
  /// iOS lo expone completo y sin truncar durante el scan.
  static Future<void> startAdvertising(String codeClassSession) async {
    final advertiseData = AdvertiseData(
      serviceUuid: codeClassSession, // ← UUID completo como service
      includeDeviceName: false, // ya no necesitamos el nombre
    );

    await _peripheral.start(advertiseData: advertiseData);
  }

  static Future<void> stopAdvertising() async {
    await _peripheral.stop();
  }

  // ── ALUMNO: escanear y leer código ─────────────────────────────────────────

  static Future<String> scanForCode(String codeClassSession) async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      throw Exception('Bluetooth está apagado.');
    }

    final completer = Completer<String>();
    StreamSubscription? scanSub;

    // Filtra directamente por el serviceUUID → más eficiente, menos batería
    await FlutterBluePlus.startScan(
      withServices: [Guid(codeClassSession)],
      timeout: const Duration(seconds: 15),
    );

    scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final services = result.advertisementData.serviceUuids;

        print('📡 DEVICE: ${result.device.remoteId}');
        print('📡 SERVICES: $services');
        print('📡 RSSI: ${result.rssi}');

        final found = services.any(
          (s) => s.toString().toLowerCase() == codeClassSession.toLowerCase(),
        );

        if (found && !completer.isCompleted) {
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
}
