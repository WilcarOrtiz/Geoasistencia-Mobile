enum OpenSessionStatus { idle, loading, active, error }

class OpenSessionState {
  final OpenSessionStatus status;
  final String? code;
  final String? sessionId;
  final String? error;

  const OpenSessionState({
    this.status = OpenSessionStatus.idle,
    this.code,
    this.sessionId,
    this.error,
  });

  OpenSessionState copyWith({
    OpenSessionStatus? status,
    String? code,
    String? sessionId,
    String? error,
  }) => OpenSessionState(
    status: status ?? this.status,
    code: code ?? this.code,
    sessionId: sessionId ?? this.sessionId,
    error: error ?? this.error,
  );
}
