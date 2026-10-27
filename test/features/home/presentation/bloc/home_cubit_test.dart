import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
import 'package:delivery_app_project/core/services/location_service.dart';
import 'package:delivery_app_project/core/services/notification_service.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/home/domain/repositories/home_repository.dart';
import 'package:delivery_app_project/features/home/presentation/bloc/home_cubit.dart';
import 'package:delivery_app_project/features/home/presentation/bloc/home_state.dart';

class MockLocationService implements LocationService {
  Position? positionToReturn;
  bool shouldGrantPermission = true;

  @override
  Future<bool> checkAndRequestPermission() async => shouldGrantPermission;

  @override
  Future<Position?> getCurrentPosition() async => positionToReturn;

  @override
  Future<Position?> getLastKnownPosition() async => positionToReturn;
}

class MockNotificationService implements NotificationService {
  String? tokenToReturn = 'real_device_fcm_token_xyz';

  @override
  Future<String?> getFcmToken() async => tokenToReturn;

  @override
  Future<NotificationSettings?> requestPermission() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessage => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  Future<void> initialize({
    void Function(String token)? onTokenRefresh,
    void Function()? onOrderOfferChime,
  }) async {}
}

class MockHomeRepository implements HomeRepository {
  DriverModel? cachedDriver;
  bool cachedOnlineStatus = false;
  bool updateFcmCalled = false;
  String? lastFcmToken;
  bool updateLocationCalled = false;
  double? lastLat;
  double? lastLng;
  bool updateAvailabilityShouldFail = false;
  Failure? updateAvailabilityFailure;

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
    lastFcmToken = fcmToken;
    return const Right(null);
  }

  @override
  Future<Either<Failure, DriverModel>> updateLocation({
    required double lat,
    required double lng,
  }) async {
    updateLocationCalled = true;
    lastLat = lat;
    lastLng = lng;
    final driver = cachedDriver?.copyWith(currentLat: lat, currentLng: lng) ??
        DriverModel(id: 1, name: 'Driver', phone: '010', currentLat: lat, currentLng: lng);
    return Right(driver);
  }

  @override
  Future<Either<Failure, DriverModel>> updateAvailability({
    required bool isOnline,
  }) async {
    if (updateAvailabilityFailure != null) {
      return Left(updateAvailabilityFailure!);
    }
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
  late MockLocationService locationService;
  late MockNotificationService notificationService;
  late SharedPreferences prefs;
  late AuthEventBus authEventBus;
  late HomeCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'delivery_app_device_id': 'test-device-id'});
    prefs = await SharedPreferences.getInstance();
    repository = MockHomeRepository();
    locationService = MockLocationService();
    notificationService = MockNotificationService();
    authEventBus = AuthEventBus();

    locationService.positionToReturn = Position(
      latitude: 31.2001,
      longitude: 29.9187,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    cubit = HomeCubit(
      homeRepository: repository,
      sharedPreferences: prefs,
      locationService: locationService,
      notificationService: notificationService,
      authEventBus: authEventBus,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('HomeCubit Tests', () {
    test('initial state is HomeInitial', () {
      expect(cubit.state, const HomeInitial());
      expect(cubit.state.isOnline, isFalse);
    });

    test('initHome loads cached driver and invokes FCM + Location updates with real device data', () async {
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
      expect(repository.lastFcmToken, 'real_device_fcm_token_xyz');
      expect(repository.updateLocationCalled, isTrue);
      expect(repository.lastLat, 31.2001);
      expect(repository.lastLng, 29.9187);
    });

    test('initHome skips location update cleanly when location is denied/null', () async {
      locationService.positionToReturn = null;
      repository.cachedDriver = const DriverModel(id: 1, name: 'Driver', phone: '010');

      await cubit.initHome();

      expect(cubit.state, isA<HomeLoaded>());
      expect(repository.updateLocationCalled, isFalse);
      expect(repository.updateFcmCalled, isTrue);
    });

    test('initHome skips FCM token update cleanly when token is null', () async {
      notificationService.tokenToReturn = null;
      repository.cachedDriver = const DriverModel(id: 1, name: 'Driver', phone: '010');

      await cubit.initHome();

      expect(cubit.state, isA<HomeLoaded>());
      expect(repository.updateFcmCalled, isFalse);
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

    test('toggleAvailability emits [HomeAvailabilityLoading, HomeAvailabilityError] on failure and retains current state', () async {
      repository.cachedDriver = const DriverModel(
        id: 1,
        name: 'Test Driver',
        phone: '01011112222',
        isOnline: true,
      );
      await cubit.initHome();
      repository.updateAvailabilityShouldFail = true;

      final expectedStates = [
        isA<HomeAvailabilityLoading>().having((s) => s.targetOnline, 'targetOnline', isFalse),
        isA<HomeAvailabilityError>()
            .having((s) => s.message, 'message', 'Failed to update status')
            .having((s) => s.isOnline, 'isOnline', isTrue),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.toggleAvailability(false);
    });

    test('toggleAvailability retains current state on 422 failure without booked shift', () async {
      repository.cachedDriver = const DriverModel(
        id: 1,
        name: 'Test Driver',
        phone: '01011112222',
        isOnline: false,
      );
      await cubit.initHome();
      repository.updateAvailabilityFailure = const ValidationFailure(
        'لا يمكنك بدء الشيفت بدون موعد عمل محجوز لهذا اليوم.',
      );

      final expectedStates = [
        isA<HomeAvailabilityLoading>().having((s) => s.targetOnline, 'targetOnline', isTrue),
        isA<HomeAvailabilityError>()
            .having((s) => s.message, 'message', 'لا يمكنك بدء الشيفت بدون موعد عمل محجوز لهذا اليوم.')
            .having((s) => s.isOnline, 'isOnline', isFalse),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.toggleAvailability(true);
    });

    test('toggleAvailability retains current state on 422 failure when busy with order', () async {
      repository.cachedDriver = const DriverModel(
        id: 1,
        name: 'Test Driver',
        phone: '01011112222',
        isOnline: true,
        isBusy: true,
      );
      await cubit.initHome();
      repository.updateAvailabilityFailure = const ValidationFailure(
        'لا يمكنك إنهاء الشيفت أو تسجيل الخروج أثناء تنفيذ طلب.',
      );

      final expectedStates = [
        isA<HomeAvailabilityLoading>().having((s) => s.targetOnline, 'targetOnline', isFalse),
        isA<HomeAvailabilityError>()
            .having((s) => s.message, 'message', 'لا يمكنك إنهاء الشيفت أو تسجيل الخروج أثناء تنفيذ طلب.')
            .having((s) => s.isOnline, 'isOnline', isTrue),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.toggleAvailability(false);
    });

    test('toggleAvailability retains current state on 403 blocked failure', () async {
      repository.cachedDriver = const DriverModel(
        id: 1,
        name: 'Test Driver',
        phone: '01011112222',
        isOnline: false,
      );
      repository.updateAvailabilityFailure = const ForbiddenFailure('This account has been blocked.');

      final expectedStates = [
        isA<HomeAvailabilityLoading>().having((s) => s.targetOnline, 'targetOnline', isTrue),
        isA<HomeAvailabilityError>()
            .having((s) => s.message, 'message', 'This account has been blocked.')
            .having((s) => s.isOnline, 'isOnline', isFalse),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.toggleAvailability(true);
    });

    test('toggleAvailability suppresses error when failure is UnauthorizedFailure (401)', () async {
      repository.cachedDriver = const DriverModel(
        id: 1,
        name: 'Test Driver',
        phone: '01011112222',
        isOnline: true,
      );
      repository.updateAvailabilityFailure = const UnauthorizedFailure('Unauthenticated');

      // Only loading should be emitted, error is suppressed to prevent UI popups during global logout
      final expectedStates = [
        isA<HomeAvailabilityLoading>().having((s) => s.targetOnline, 'targetOnline', isFalse),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.toggleAvailability(false);
    });

    test('authEventBus unauthorized event halts cubit operations and aborts subsequent updates', () async {
      authEventBus.emitUnauthorized();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      repository.cachedDriver = const DriverModel(id: 1, name: 'Driver', phone: '010');
      await cubit.initHome();

      // State remains HomeInitial because cubit aborted on unauthorized
      expect(cubit.state, const HomeInitial());
      expect(repository.updateLocationCalled, isFalse);
    });
  });
}
