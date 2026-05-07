import 'dart:async';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final _peripheral = FlutterBlePeripheral();

  static Future<void> startAdvertising(String codeClassSession) async {
    final advertiseData = AdvertiseData(
      serviceUuid: codeClassSession,
      includeDeviceName: false,
    );
    final advertiseSettings = AdvertiseSettings(
      advertiseMode: AdvertiseMode.advertiseModeBalanced,
      txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh,
      timeout: 0,
    );
    await _peripheral.start(
      advertiseData: advertiseData,
      advertiseSettings: advertiseSettings,
    );
  }

  static Future<void> stopAdvertising() async => await _peripheral.stop();

  static Future<String> scanForCode(String codeClassSession) async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      throw Exception('Bluetooth está apagado.');
    }

    // Limpia scan anterior colgado
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final completer = Completer<String>();
    StreamSubscription? scanSub;

    scanSub = FlutterBluePlus.onScanResults.listen(
      (results) {
        // Guard: si ya completó, ignorar todo
        if (completer.isCompleted) return;
        if (results.isEmpty) return;

        for (final result in results) {
          final services = result.advertisementData.serviceUuids;

          final found = services.any(
            (s) => s.toString().toLowerCase() == codeClassSession.toLowerCase(),
          );

          if (found) {
            // 1. Cancelar sub primero para que no vuelva a entrar
            scanSub?.cancel();
            scanSub = null;
            // 2. Completar
            completer.complete(codeClassSession);
            // 3. Detener scan en background (sin await, ya estamos fuera)
            FlutterBluePlus.stopScan().ignore();
            return;
          }
        }
      },
      onError: (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      cancelOnError: true,
    );

    // Iniciar scan DESPUÉS de suscribirse para no perder eventos
    await FlutterBluePlus.startScan(
      withServices: [Guid(codeClassSession)],
      androidScanMode: AndroidScanMode.lowLatency,
      timeout: const Duration(seconds: 15),
    );

    try {
      return await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          scanSub?.cancel();
          FlutterBluePlus.stopScan().ignore();
          throw Exception(
            'No se encontró sesión activa cerca.\n'
            'Asegúrate de que:\n'
            '• El docente haya iniciado el llamado a lista\n'
            '• Tengas Bluetooth activado\n'
            '• Estés cerca del docente',
          );
        },
      );
    } catch (e) {
      // Limpieza garantizada si algo falla
      scanSub?.cancel();
      FlutterBluePlus.stopScan().ignore();
      rethrow;
    }
  }
}
