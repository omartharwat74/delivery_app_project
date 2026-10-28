import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../orders/presentation/bloc/active_order_cubit.dart';
import '../../../orders/presentation/bloc/active_order_state.dart';
import '../../../orders/presentation/widgets/active_order_card.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/driver_map_view.dart';
import '../widgets/home_drawer.dart';

class HomePage extends StatefulWidget {
  final LocationService? locationService;
  const HomePage({super.key, this.locationService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final LocationService _locationService;
  StreamSubscription<dynamic>? _positionSubscription;
  LatLng? _currentDriverLocation;
  bool _hasPromptedPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationService = widget.locationService ??
        (sl.isRegistered<LocationService>()
            ? sl<LocationService>()
            : LocationServiceImpl());

    context.read<HomeCubit>().initHome(
      onOrderOfferChime: () =>
          context.read<ActiveOrderCubit>().checkCurrentOffer(),
    );
    context.read<ActiveOrderCubit>().restoreActiveOrderOrOffer();

    // Check cached location from driver model first
    final driver = context.read<HomeCubit>().state.driver;
    if (driver != null) {
      final lat = driver.currentLat;
      final lng = driver.currentLng;
      if (lat != null && lng != null) {
        _currentDriverLocation = LatLng(lat, lng);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLocationUpdates();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopLocationUpdates();
    } else if (state == AppLifecycleState.resumed) {
      _startLocationUpdates();
    }
  }

  Future<void> _startLocationUpdates() async {
    if (_positionSubscription != null || !mounted) return;

    // 1. If we don't have an initial location, check last known position
    if (_currentDriverLocation == null) {
      final lastPos = await _locationService.getLastKnownPosition();
      if (lastPos != null && mounted) {
        setState(() {
          _currentDriverLocation = LatLng(lastPos.latitude, lastPos.longitude);
        });
      }
    }

    if (!mounted) return;

    // 2. Check permission status
    final status = await _locationService.getPermissionStatus();
    if (!mounted) return;

    if (status == LocationPermissionStatus.granted) {
      _subscribeToLocationStream();
      return;
    }

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    if (status == LocationPermissionStatus.serviceDisabled) {
      _showLocationSnackBar(
        message: l10n.locationServiceDisabled,
        actionLabel: l10n.enableGps,
        onAction: () => _locationService.openLocationSettings(),
      );
      return;
    }

    if (status == LocationPermissionStatus.deniedForever) {
      _showLocationSnackBar(
        message: l10n.locationPermissionPermanentlyDenied,
        actionLabel: l10n.openSettings,
        onAction: () => _locationService.openAppSettings(),
      );
      return;
    }

    if (status == LocationPermissionStatus.denied && !_hasPromptedPermission) {
      _hasPromptedPermission = true;
      final requestedStatus = await _locationService.requestPermission();
      if (!mounted) return;

      if (requestedStatus == LocationPermissionStatus.granted) {
        _subscribeToLocationStream();
      } else if (requestedStatus == LocationPermissionStatus.deniedForever) {
        _showLocationSnackBar(
          message: l10n.locationPermissionPermanentlyDenied,
          actionLabel: l10n.openSettings,
          onAction: () => _locationService.openAppSettings(),
        );
      } else {
        _showLocationSnackBar(
          message: l10n.locationPermissionDenied,
        );
      }
    }
  }

  void _subscribeToLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = _locationService.getPositionStream().listen(
      (position) {
        if (!mounted) return;
        setState(() {
          _currentDriverLocation =
              LatLng(position.latitude, position.longitude);
        });
      },
      onError: (_) {
        // Non-fatal stream error
      },
    );
  }

  void _showLocationSnackBar({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  void _stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current is AuthUnauthenticated || current is AuthError,
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              while (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              context.go(RouteNames.login);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        BlocListener<ActiveOrderCubit, ActiveOrderState>(
          listenWhen: (previous, current) =>
              previous is ActiveOrderIdle && current is ActiveOrderOfferReceived,
          listener: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.trackingNewOrderBody),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        drawer: const HomeDrawer(),
        body: SizedBox.expand(
          child: Stack(
            children: [
              // Background Real Google Map View
              Positioned.fill(
                child: BlocBuilder<ActiveOrderCubit, ActiveOrderState>(
                  builder: (context, activeOrderState) {
                    LatLng? storeLocation;
                    final hasActiveSheet =
                        activeOrderState is ActiveOrderOfferReceived ||
                            activeOrderState is ActiveOrderInProgress;

                    if (activeOrderState is ActiveOrderInProgress) {
                      final store = activeOrderState.order.store;
                      if (store != null) {
                        final lat = store.lat;
                        final lng = store.long;
                        if (lat != null && lng != null) {
                          storeLocation = LatLng(lat, lng);
                        }
                      }
                    }

                    return DriverMapView(
                      driverLocation: _currentDriverLocation,
                      storeLocation: storeLocation,
                      mapPadding: EdgeInsets.only(
                        top: 80.0,
                        bottom: hasActiveSheet ? 260.0 : 24.0,
                      ),
                    );
                  },
                ),
              ),

              // Floating Overlays (Menu Button & Online Switch)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Hamburger Menu Button
                        Builder(
                          builder: (drawerCtx) => Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12.0),
                                onTap: () =>
                                    Scaffold.of(drawerCtx).openDrawer(),
                                child: const Center(
                                  child: Icon(
                                    Icons.menu,
                                    color: Color(0xFFA3090F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Online/Offline Toggle
                        BlocConsumer<HomeCubit, HomeState>(
                          listener: (context, state) {
                            if (state is HomeAvailabilityError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else if (state is HomeAvailabilitySuccess) {
                              // Keep driver profile in AuthCubit synchronized
                              context.read<AuthCubit>().loadDriverProfile();
                            }
                          },
                          builder: (context, state) {
                            final isOnline = state.isOnline;
                            final isLoading = state is HomeAvailabilityLoading;

                            return GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => context
                                      .read<HomeCubit>()
                                      .toggleAvailability(!isOnline),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 60,
                                height: 32,
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedAlign(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      alignment: isOnline
                                          ? AlignmentDirectional.centerEnd
                                          : AlignmentDirectional.centerStart,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isOnline
                                              ? const Color(0xFF0C9D61)
                                              : const Color(0xFFD1D1D1),
                                        ),
                                        child: isLoading
                                            ? const Center(
                                                child: SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Active Order Card Overlay
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ActiveOrderCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
