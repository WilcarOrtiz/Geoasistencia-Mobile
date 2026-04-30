class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int limit;
  final int page;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.limit,
    required this.page,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List).map((e) => fromItem(e)).toList(),
      total: json['total'],
      limit: json['limit'],
      page: json['page'],
    );
  }
}
