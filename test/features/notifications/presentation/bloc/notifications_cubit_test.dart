import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/features/notifications/data/models/notification_model.dart';
import 'package:delivery_app_project/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:delivery_app_project/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:delivery_app_project/features/notifications/presentation/bloc/notifications_state.dart';

class FakeNotificationsRepository implements NotificationsRepository {
  bool shouldThrow = false;
  List<NotificationModel> notifications = [];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return notifications;
  }
}

void main() {
  late FakeNotificationsRepository repository;
  late NotificationsCubit cubit;

  setUp(() {
    repository = FakeNotificationsRepository();
    cubit = NotificationsCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is NotificationsInitial', () {
    expect(cubit.state, const NotificationsInitial());
  });

  test('loadNotifications emits Loading and then Loaded with notifications', () async {
    repository.notifications = [
      const NotificationModel(
        id: 1,
        title: 'Title',
        body: 'Body',
        isAdmin: true,
        createdAt: '2026-06-06T12:00:00Z',
      ),
    ];

    expectLater(
      cubit.stream,
      emitsInOrder([
        const NotificationsLoading(),
        NotificationsLoaded(notifications: repository.notifications),
      ]),
    );

    await cubit.loadNotifications();
  });

  test('loadNotifications emits Loading and then Error on failure', () async {
    repository.shouldThrow = true;

    expectLater(
      cubit.stream,
      emitsInOrder([
        const NotificationsLoading(),
        isA<NotificationsError>(),
      ]),
    );

    await cubit.loadNotifications();
  });
}
