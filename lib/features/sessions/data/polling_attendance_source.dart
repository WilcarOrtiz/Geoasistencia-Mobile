import 'dart:async';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_record.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_source.dart';

class PollingAttendanceSource implements AttendanceSource {
  final ClassSessionService _service;
  final Duration interval;
  StreamController<List<AttendanceRecord>>? _controller;
  Timer? _timer;

  PollingAttendanceSource(
    this._service, {
    this.interval = const Duration(seconds: 5),
  });

  @override
  Stream<List<AttendanceRecord>> watch(String sessionId) {
    _controller = StreamController<List<AttendanceRecord>>.broadcast();

    Future<void> fetch() async {
      try {
        final records = await _service.getAttendances(sessionId);
        if (!(_controller?.isClosed ?? true)) {
          _controller!.add(records);
        }
      } catch (_) {}
    }

    fetch();
    _timer = Timer.periodic(interval, (_) => fetch());

    return _controller!.stream;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.close();
  }
}
