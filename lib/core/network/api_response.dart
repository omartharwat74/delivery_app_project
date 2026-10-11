class ApiResponse<T> {
  final int status;
  final String msg;
  final T? data;

  const ApiResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  bool get isSuccess => status >= 200 && status < 300;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(dynamic data)? fromJsonT,
  ]) {
    final status = json['status'] as int? ?? 200;
    final msg = json['msg'] as String? ?? '';
    final rawData = json['data'];

    T? parsedData;
    if (rawData != null && fromJsonT != null) {
      parsedData = fromJsonT(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    }

    return ApiResponse<T>(
      status: status,
      msg: msg,
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson([Object? Function(T? value)? toJsonT]) {
    return {
      'status': status,
      'msg': msg,
      'data': toJsonT != null ? toJsonT(data) : data,
    };
  }

  @override
  String toString() => 'ApiResponse(status: $status, msg: $msg, data: $data)';
}
