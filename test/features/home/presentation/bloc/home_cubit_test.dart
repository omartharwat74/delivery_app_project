import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/home/domain/repositories/home_repository.dart';
import 'package:delivery_app_project/features/home/presentation/bloc/home_cubit.dart';
import 'package:delivery_app_project/features/home/presentation/bloc/home_state.dart';

class MockHomeRepository implements HomeRepository {
  DriverModel? cachedDriver;
  bool cachedOnlineStatus = false;
  bool updateFcmCalled = false;
  bool updateLocationCalled = false;
  bool updateAvailabilityShouldFail = false;

  @override
  Future<DriverModel?> getCachedDriver() async => cachedDriver;

  @override
  Future<bool> getCachedOnlineStatus() async => cachedOnlineStatus;

  @override
  Future<Either<Failure, void>> updateFcmToken({
    required String deviceId,
    required String fcmToken,
    String? platform,
  }) async {
    updateFcmCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, DriverModel>> updateLocation({
    required double lat,
    required double lng,
  }) async {
    updateLocationCalled = true;
    final driver = cachedDriver?.copyWith(currentLat: lat, currentLng: lng) ??
        DriverModel(id: 1, name: 'Driver', phone: '010', currentLat: lat, currentLng: lng);
    return Right(driver);
  }

  @override
  Future<Either<Failure, DriverModel>> updateAvailability({
    required bool isOnline,
  }) async {
    if (updateAvailabilityShouldFail) {
      return Left(ServerFailure('Failed to update status'));
    }
    final driver = cachedDriver?.copyWith(isOnline: isOnline) ??
        DriverModel(id: 1, name: 'Driver', phone: '010', isOnline: isOnline);
    cachedDriver = driver;
    return Right(driver);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHomeRepository repository;
  late SharedPreferences prefs;
  late HomeCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'delivery_app_device_id': 'test-device-id'});
    prefs = await SharedPreferences.getInstance();
    repository = MockHomeRepository();
    cubit = HomeCubit(homeRepository: repository, sharedPreferences: prefs);
  });

  tearDown(() {
    cubit.close();
  });

  group('HomeCubit Tests', () {
    test('initial state is HomeInitial', () {
      expect(cubit.state, const HomeInitial());
      expect(cubit.state.isOnline, isFalse);
    });

    test('initHome loads cached driver and invokes FCM + Location updates silently', () async {
      repository.cachedDriver = const DriverModel(
        id: 1,
        name: 'Test Driver',
        phone: '01011112222',
        isOnline: true,
      );

      await cubit.initHome();

      expect(cubit.state, isA<HomeLoaded>());
      expect(cubit.state.isOnline, isTrue);
      expect(cubit.state.driver?.name, 'Test Driver');
      expect(repository.updateFcmCalled, isTrue);
      expect(repository.updateLocationCalled, isTrue);
    });

    test('toggleAvailability emits [HomeAvailabilityLoading, HomeAvailabilitySuccess] on success', () async {
      repository.cachedDriver = const DriverModel(
        id: 1,
        name: 'Test Driver',
        phone: '01011112222',
        isOnline: false,
      );

      final expectedStates = [
        isA<HomeAvailabilityLoading>().having((s) => s.targetOnline, 'targetOnline', isTrue),
        isA<HomeAvailabilitySuccess>().having((s) => s.isOnline, 'isOnline', isTrue),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.toggleAvailability(true);
    });

    test('toggleAvailability emits [HomeAvailabilityLoading, HomeAvailabilityError] on failure', () async {
      repository.cachedDriver = const DriverModel(
        id: 1,
        name: 'Test Driver',
        phone: '01011112222',
        isOnline: true,
      );
      repository.updateAvailabilityShouldFail = true;

      final expectedStates = [
        isA<HomeAvailabilityLoading>().having((s) => s.targetOnline, 'targetOnline', isFalse),
        isA<HomeAvailabilityError>().having((s) => s.message, 'message', 'Failed to update status'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.toggleAvailability(false);
    });
  });
}
