abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode, super.data});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'غير مصرح. يرجى تسجيل الدخول',
    dynamic data,
  ]) : super(statusCode: 401, data: data);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(
    super.message, {
    super.data,
  }) : super(statusCode: 403);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;

  const ValidationException(
    super.message, {
    this.errors = const {},
    super.data,
  }) : super(statusCode: 422);
}

class NotFoundException extends ApiException {
  const NotFoundException([
    super.message = 'العنصر غير موجود',
    dynamic data,
  ]) : super(statusCode: 404, data: data);
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت',
  ]) : super(statusCode: null);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => message;
}
