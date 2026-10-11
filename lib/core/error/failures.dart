import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'غير مصرح. يرجى تسجيل الدخول',
  ]) : super(statusCode: 401);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message) : super(statusCode: 403);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure(
    super.message, {
    this.errors = const {},
  }) : super(statusCode: 422);

  @override
  List<Object?> get props => [message, statusCode, errors];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'العنصر غير موجود',
  ]) : super(statusCode: 404);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
