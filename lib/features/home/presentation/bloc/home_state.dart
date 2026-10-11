import 'package:equatable/equatable.dart';
import '../../../auth/data/models/driver_model.dart';

abstract class HomeState extends Equatable {
  final bool isOnline;
  final DriverModel? driver;

  const HomeState({
    this.isOnline = false,
    this.driver,
  });

  @override
  List<Object?> get props => [isOnline, driver];
}

class HomeInitial extends HomeState {
  const HomeInitial({super.isOnline = false, super.driver});
}

class HomeLoaded extends HomeState {
  const HomeLoaded({required super.isOnline, super.driver});
}

class HomeAvailabilityLoading extends HomeState {
  final bool targetOnline;

  const HomeAvailabilityLoading({
    required super.isOnline,
    super.driver,
    required this.targetOnline,
  });

  @override
  List<Object?> get props => [isOnline, driver, targetOnline];
}

class HomeAvailabilitySuccess extends HomeState {
  final String? message;

  const HomeAvailabilitySuccess({
    required super.isOnline,
    super.driver,
    this.message,
  });

  @override
  List<Object?> get props => [isOnline, driver, message];
}

class HomeAvailabilityError extends HomeState {
  final String message;

  const HomeAvailabilityError({
    required super.isOnline,
    super.driver,
    required this.message,
  });

  @override
  List<Object?> get props => [isOnline, driver, message];
}
