import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
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

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, RouteAware {
  late final LocationService _locationService;
  StreamSubscription<dynamic>? _positionSubscription;
  LatLng? _currentDriverLocation;
  bool _hasPromptedPermission = false;
  LatLng? _activeStoreLocation;
  LatLng? _activeCustomerLocation;
  Timer? _blockedCheckTimer;

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

    // Check ongoing active order or waiting offer from server on startup
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
      _updateFallbackPolling();
    });
  }

  /// Opens the given [location] in a map application:
  /// - On iOS: presents an elegant modal bottom sheet allowing choice between Apple Maps & Google Maps.
  /// - On Android: opens Google Maps directly.
  Future<void> _openMap(LatLng? location) async {
    if (location == null) return;

    if (Platform.isIOS) {
      _showIosMapChooser(location);
    } else {
      _launchMapExternal(
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
      );
    }
  }

  void _showIosMapChooser(LatLng location) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isAr ? 'اختر تطبيق الخرائط' : 'Choose Map Application',
                  style: TextStyle(
                    fontFamily: 'ExpoArabic',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2E)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map_outlined,
                        color: Color(0xFFA3090F)),
                  ),
                  title: Text(
                    isAr ? 'خرائط آبل (Apple Maps)' : 'Apple Maps',
                    style: TextStyle(
                      fontFamily: 'ExpoArabic',
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _launchMapExternal(
                      'https://maps.apple.com/?q=${location.latitude},${location.longitude}',
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFE5E5E5),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2E)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.navigation_outlined,
                        color: Color(0xFFA3090F)),
                  ),
                  title: Text(
                    isAr ? 'خرائط جوجل (Google Maps)' : 'Google Maps',
                    style: TextStyle(
                      fontFamily: 'ExpoArabic',
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _launchMapExternal(
                      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchMapExternal(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('[HomePage] Error launching map url: $e');
      if (mounted) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr
                ? 'تعذر فتح تطبيق الخرائط'
                : 'Unable to open map application'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _updateFallbackPolling() {
    if (!mounted) return;
    final isOnline = context.read<HomeCubit>().state.isOnline;
    final isResumed = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    if (isOnline && isResumed) {
      context.read<ActiveOrderCubit>().startFallbackPolling(
            isOnline: () => mounted && context.read<HomeCubit>().state.isOnline,
          );
    } else {
      context.read<ActiveOrderCubit>().stopFallbackPolling();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopLocationUpdates();
      if (mounted) {
        context.read<ActiveOrderCubit>().stopFallbackPolling();
      }
    } else if (state == AppLifecycleState.resumed) {
      _startLocationUpdates();
      _updateFallbackPolling();
      if (mounted) {
        context.read<AuthCubit>().loadDriverProfile();
      }
    }
  }

  void _syncBlockedPolling(bool isBlocked) {
    if (isBlocked) {
      if (_blockedCheckTimer == null || !_blockedCheckTimer!.isActive) {
        _blockedCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
          if (!mounted) return;
          context.read<AuthCubit>().loadDriverProfile();
        });
      }
    } else {
      _blockedCheckTimer?.cancel();
      _blockedCheckTimer = null;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      AppRouter.routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // iOS viewWillAppear equivalent: called whenever HomePage becomes top route again
    _onViewWillAppear();
  }

  void _onViewWillAppear() {
    if (!mounted) return;
    context.read<AuthCubit>().loadDriverProfile();
    _updateFallbackPolling();
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    _blockedCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationUpdates();
    try {
      context.read<ActiveOrderCubit>().stopFallbackPolling();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current is AuthUnauthenticated ||
              current is AuthError ||
              (current is AuthAuthenticated && current.driver != null),
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
            } else if (state is AuthAuthenticated && state.driver != null) {
              context.read<HomeCubit>().updateDriver(state.driver!);
              final isBlocked = state.driver!.status.toLowerCase() == 'blocked';
              _syncBlockedPolling(isBlocked);
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
            // No navigation needed: offer card renders directly on HomePage map overlay!
          },
        ),
        BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            _updateFallbackPolling();
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
                    LatLng? customerLocation;
                    List<LatLng>? routePoints;

                    final hasActiveSheet =
                        activeOrderState is ActiveOrderOfferReceived ||
                            activeOrderState is ActiveOrderInProgress;

                    // TODO: [TESTING] Hardcoded location for Madinaty testing
                    final effectiveDriverPos = _currentDriverLocation ??
                        const LatLng(30.095, 31.63);

                    if (activeOrderState is ActiveOrderOfferReceived) {
                      final order = activeOrderState.offer.order;
                      final sLat = order.store?.lat;
                      final sLng = order.store?.long;
                      if (sLat != null && sLng != null) {
                        storeLocation = LatLng(sLat, sLng);
                      }

                      final cLat = order.address?.lat;
                      final cLng = order.address?.long;
                      if (cLat != null && cLng != null) {
                        customerLocation = LatLng(cLat, cLng);
                      }
                    } else if (activeOrderState is ActiveOrderInProgress) {
                      final order = activeOrderState.order;
                      final sLat = order.store?.lat;
                      final sLng = order.store?.long;
                      if (sLat != null && sLng != null) {
                        storeLocation = LatLng(sLat, sLng);
                      }

                      final cLat = order.address?.lat;
                      final cLng = order.address?.long;
                      if (cLat != null && cLng != null) {
                        customerLocation = LatLng(cLat, cLng);
                      }

                      // When driver accepted and heading to restaurant (assigned):
                      // Draw route on map between delivery driver and store/restaurant
                      if (order.isAssigned && storeLocation != null) {
                        routePoints = [effectiveDriverPos, storeLocation];
                      }
                      // When driver picked up and heading to customer (on_the_way):
                      // Draw route on map between delivery driver and customer/user
                      else if (order.isOnTheWay && customerLocation != null) {
                        routePoints = [effectiveDriverPos, customerLocation];
                      }
                    }

                    _activeStoreLocation = storeLocation;
                    _activeCustomerLocation = customerLocation;

                    return DriverMapView(
                      driverLocation: effectiveDriverPos,
                      storeLocation: storeLocation,
                      customerLocation: customerLocation,
                      routePoints: routePoints,
                      onMapCreated: (_) {},
                      mapPadding: EdgeInsets.only(
                        top: 80.0,
                        bottom: hasActiveSheet ? 340.0 : 24.0,
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
                  child: Builder(
                    builder: (context) {
                      final homeDriver = context.watch<HomeCubit>().state.driver;
                      final authDriver = context.watch<AuthCubit>().currentDriver;
                      final isBlocked =
                          (homeDriver?.status.toLowerCase() == 'blocked') ||
                              (authDriver?.status.toLowerCase() == 'blocked');

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: isBlocked ? 48.0 : 12.0,
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
                                  _updateFallbackPolling();
                                }
                              },
                              builder: (context, state) {
                                final isOnline = state.isOnline;
                                final isLoading =
                                    state is HomeAvailabilityLoading;

                                return Opacity(
                                  opacity: isBlocked ? 0.5 : 1.0,
                                  child: GestureDetector(
                                    onTap: (isLoading || isBlocked)
                                        ? null
                                        : () => context
                                            .read<HomeCubit>()
                                            .toggleAvailability(!isOnline),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      width: 60,
                                      height: 32,
                                      padding: const EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
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
                                            duration: const Duration(
                                                milliseconds: 300),
                                            alignment: isOnline
                                                ? AlignmentDirectional.centerEnd
                                                : AlignmentDirectional
                                                    .centerStart,
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
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Blocked Warning Banner Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Builder(
                  builder: (context) {
                    final homeDriver = context.watch<HomeCubit>().state.driver;
                    final authDriver = context.watch<AuthCubit>().currentDriver;
                    final isBlocked =
                        (homeDriver?.status.toLowerCase() == 'blocked') ||
                            (authDriver?.status.toLowerCase() == 'blocked');

                    if (!isBlocked) return const SizedBox.shrink();

                    final l10n = AppLocalizations.of(context)!;

                    return SafeArea(
                      bottom: false,
                      child: GestureDetector(
                        onTap: () {
                          context.read<AuthCubit>().loadDriverProfile();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.accountBlockedHomeBanner,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Active Order Card Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ActiveOrderCard(
                  driverLocation: _currentDriverLocation,
                  // Opens the store/restaurant location in Map
                  onOpenStoreMap: () => _openMap(_activeStoreLocation),
                  // Opens the customer/delivery location in Map
                  onOpenCustomerMap: () => _openMap(_activeCustomerLocation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
