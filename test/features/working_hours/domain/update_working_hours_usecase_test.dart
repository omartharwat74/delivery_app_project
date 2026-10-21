import 'package:dartz/dartz.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/working_hours/domain/entities/working_hours_entity.dart';
import 'package:delivery_app_project/features/working_hours/domain/repositories/working_hours_repository.dart';
import 'package:delivery_app_project/features/working_hours/domain/usecases/update_working_hours_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class MockWorkingHoursRepository implements WorkingHoursRepository {
  bool shouldFail = false;
  Failure failure = const ServerFailure('Server Error');

  String? lastWorkDate;
  String? lastStartsAt;
  String? lastEndsAt;

  static const sampleEntity = WorkingHoursEntity(
    shift: ShiftEntity(startsAt: '08:00', endsAt: '16:00'),
    days: [
      WorkingHourDay(
        workDate: '2026-09-15',
        startsAt: '10:00',
        endsAt: '16:00',
        isLocked: false,
      ),
    ],
    windowFrom: '2026-09-14',
    windowTo: '2026-09-20',
  );

  @override
  Future<Either<Failure, WorkingHoursEntity>> getWorkingHours() async {
    return const Right(sampleEntity);
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> addWorkingHours({
    required String workDate,
    required String startsAt,
    required String endsAt,
  }) async {
    return const Right(sampleEntity);
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> deleteWorkingHours({
    required String workDate,
  }) async {
    return const Right(sampleEntity);
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> updateWorkingHours({
    required String workDate,
    required String startsAt,
    required String endsAt,
  }) async {
    lastWorkDate = workDate;
    lastStartsAt = startsAt;
    lastEndsAt = endsAt;

    if (shouldFail) {
      return Left(failure);
    }
    return const Right(sampleEntity);
  }
}

void main() {
  late MockWorkingHoursRepository mockRepository;
  late UpdateWorkingHoursUseCase useCase;

  setUp(() {
    mockRepository = MockWorkingHoursRepository();
    useCase = UpdateWorkingHoursUseCase(mockRepository);
  });

  group('UpdateWorkingHoursUseCase', () {
    const params = UpdateWorkingHoursParams(
      workDate: '2026-09-15',
      startsAt: '10:00',
      endsAt: '16:00',
    );

    test('calls repository.updateWorkingHours with correct params and returns Right(entity)', () async {
      final result = await useCase(params);

      expect(mockRepository.lastWorkDate, '2026-09-15');
      expect(mockRepository.lastStartsAt, '10:00');
      expect(mockRepository.lastEndsAt, '16:00');
      expect(result.isRight(), isTrue);

      result.fold(
        (_) => fail('Expected Right'),
        (entity) {
          expect(entity.shift.startsAt, '08:00');
          expect(entity.days.first.startsAt, '10:00');
        },
      );
    });

    test('returns Left(ValidationFailure) when repository fails with 422', () async {
      mockRepository.shouldFail = true;
      mockRepository.failure = const ValidationFailure('لا يمكن تعديل الموعد إذا تبقّى أقل من 6 ساعات على بدايته.');

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'لا يمكن تعديل الموعد إذا تبقّى أقل من 6 ساعات على بدايته.'),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(NotFoundFailure) when repository fails with 404', () async {
      mockRepository.shouldFail = true;
      mockRepository.failure = const NotFoundFailure('لا يوجد موعد لهذا اليوم.');

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'لا يوجد موعد لهذا اليوم.'),
        (_) => fail('Expected Left'),
      );
    });
  });
}
