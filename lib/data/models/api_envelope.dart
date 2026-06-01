/// Reflet du `ApiResponse<T>` backend Spring.
class ApiEnvelope<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiEnvelope({required this.success, this.message, this.data});

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data)? mapper,
  ) {
    return ApiEnvelope(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: mapper != null && json['data'] != null ? mapper(json['data']) : null,
    );
  }
}

/// Reflet du `PageResponse<T>` backend.
class PageEnvelope<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  PageEnvelope({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory PageEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemMapper,
  ) {
    final list = (json['content'] as List? ?? [])
        .map((e) => itemMapper(e as Map<String, dynamic>))
        .toList();
    return PageEnvelope(
      content: list,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? list.length,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? list.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      last: json['last'] as bool? ?? true,
    );
  }

  PageEnvelope<T> appendedWith(PageEnvelope<T> other) => PageEnvelope(
        content: [...content, ...other.content],
        page: other.page,
        size: other.size,
        totalElements: other.totalElements,
        totalPages: other.totalPages,
        last: other.last,
      );
}
