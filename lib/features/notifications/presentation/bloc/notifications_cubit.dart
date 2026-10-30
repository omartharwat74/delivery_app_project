import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository repository;

  NotificationsCubit({required this.repository})
      : super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    try {
      final notifications = await repository.getNotifications();
      emit(NotificationsLoaded(notifications: notifications));
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      emit(NotificationsError(message: msg));
    }
  }
}
