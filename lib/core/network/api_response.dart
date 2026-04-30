class ApiResponse<T> {
  final bool ok;
  final String message;
  final T? data;

  ApiResponse({required this.ok, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      ok: json['ok'],
      message: json['message'],
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
    );
  }
}
