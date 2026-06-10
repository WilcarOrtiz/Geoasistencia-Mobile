import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_record.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_source.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación de [AttendanceSource] basada en WebSocket (Socket.io).
///
/// Flujo:
/// 1. Conecta al namespace /attendance del backend.
/// 2. Envía "join_session" con el sessionId para unirse al room.
/// 3. Escucha "attendance_update" y empuja los datos al stream.
/// 4. Al hacer dispose, envía "leave_session" y desconecta.
///
/// Si la conexión falla o se pierde, reintenta automáticamente
/// (reconnection: true en las opciones de Socket.io).
class WebSocketAttendanceSource implements AttendanceSource {
  final ClassSessionService _service;
  io.Socket? _socket;
  StreamController<List<AttendanceRecord>>? _controller;
  String? _currentSessionId;

  WebSocketAttendanceSource(this._service);

  @override
  Stream<List<AttendanceRecord>> watch(String sessionId) {
    _currentSessionId = sessionId;
    _controller = StreamController<List<AttendanceRecord>>.broadcast();

    _connect(sessionId);

    return _controller!.stream;
  }

  void _connect(String sessionId) {
    final baseUrl = dotenv.env['API_URL'] ?? '';

    // Extraer solo el origen (protocolo + host + puerto si lo hay)
    final uri = Uri.parse(baseUrl);
    final wsUrl =
        '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';

    debugPrint('[WS] Conectando a: $wsUrl/attendance');
    final token =
        Supabase.instance.client.auth.currentSession?.accessToken ?? '';

    _socket = io.io(
      '$wsUrl/attendance',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[WS] Conectado al namespace /attendance');
      // Unirse al room de la sesión
      _socket!.emit('join_session', {'sessionId': sessionId});
    });

    _socket!.on('joined', (data) {
      debugPrint('[WS] Unido al room de sesión: $data');
      // Cargar datos iniciales via HTTP para no esperar el primer evento WS
      _fetchInitial(sessionId);
    });

    _socket!.on('attendance_update', (data) {
      try {
        final records = _parseRecords(data);
        if (!(_controller?.isClosed ?? true)) {
          _controller!.add(records);
        }
      } catch (e) {
        debugPrint('[WS] Error al parsear attendance_update: $e');
      }
    });

    _socket!.onError((error) {
      debugPrint('[WS] Error de socket: $error');
    });

    _socket!.onDisconnect((_) {
      debugPrint('[WS] Desconectado del socket');
    });

    _socket!.onReconnect((_) {
      debugPrint('[WS] Reconectado, re-uniéndose al room');
      _socket!.emit('join_session', {'sessionId': sessionId});
    });
  }

  Future<void> _fetchInitial(String sessionId) async {
    try {
      final records = await _service.getAttendances(sessionId);
      if (!(_controller?.isClosed ?? true)) {
        _controller!.add(records);
      }
    } catch (e) {
      debugPrint('[WS] Error cargando datos iniciales: $e');
    }
  }

  List<AttendanceRecord> _parseRecords(dynamic data) {
    List<dynamic> list;

    if (data is Map && data['records'] != null) {
      list = data['records'] as List<dynamic>;
    } else if (data is List) {
      list = data;
    } else if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map && decoded['records'] != null) {
        list = decoded['records'] as List<dynamic>;
      } else {
        list = decoded as List<dynamic>;
      }
    } else {
      return [];
    }

    return list
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  void dispose() {
    if (_currentSessionId != null && _socket != null) {
      _socket!.emit('leave_session', {'sessionId': _currentSessionId});
    }
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _controller?.close();
    _controller = null;
    debugPrint('[WS] WebSocketAttendanceSource disposed');
  }
}
