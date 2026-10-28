import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/marker_icon_helper.dart';

/// Clean, modular map widget for the Driver Home screen.
///
/// Features:
/// - Reactive Dark / Light mode map styling matching [AppColors.darkMapStyle].
/// - Displays driver position with custom scooter [BitmapDescriptor].
/// - Smooth marker position animation on location stream updates.
/// - Optional [storeLocation] marker and [routePoints] polyline.
/// - Initial camera centering with respect for user manual map gestures.
class DriverMapView extends StatefulWidget {
  final LatLng? driverLocation;
  final LatLng? storeLocation;
  final List<LatLng>? routePoints;
  final EdgeInsets mapPadding;
  final void Function(GoogleMapController controller)? onMapCreated;

  const DriverMapView({
    super.key,
    this.driverLocation,
    this.storeLocation,
    this.routePoints,
    this.mapPadding = const EdgeInsets.only(top: 80, bottom: 120),
    this.onMapCreated,
  });

  /// Default fallback location in Egypt (Cairo)
  static const LatLng fallbackCairo = LatLng(30.0444, 31.2357);

  @override
  State<DriverMapView> createState() => _DriverMapViewState();
}

class _DriverMapViewState extends State<DriverMapView>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  BitmapDescriptor? _scooterIcon;

  // Animated marker position
  AnimationController? _markerAnimController;
  Animation<double>? _markerAnimation;
  LatLng? _animatedDriverLatLng;
  LatLng? _prevDriverLatLng;
  LatLng? _targetDriverLatLng;

  bool _hasMovedCameraToInitial = false;
  bool _userInteractedWithMap = false;
  bool _hasFittedStoreBounds = false;

  @override
  void initState() {
    super.initState();
    _animatedDriverLatLng = widget.driverLocation;
    _targetDriverLatLng = widget.driverLocation;

    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _markerAnimation = CurvedAnimation(
      parent: _markerAnimController!,
      curve: Curves.easeInOut,
    )..addListener(() {
        if (_prevDriverLatLng != null && _targetDriverLatLng != null) {
          final t = _markerAnimation!.value;
          final lat = lerpDouble(
            _prevDriverLatLng!.latitude,
            _targetDriverLatLng!.latitude,
            t,
          );
          final lng = lerpDouble(
            _prevDriverLatLng!.longitude,
            _targetDriverLatLng!.longitude,
            t,
          );
          if (lat != null && lng != null && mounted) {
            setState(() {
              _animatedDriverLatLng = LatLng(lat, lng);
            });
          }
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadScooterIcon();
  }

  Future<void> _loadScooterIcon() async {
    final pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final icon = await MarkerIconHelper.getScooterMarkerIcon(
      logicalSize: 48.0,
      pixelRatio: pixelRatio,
    );
    if (mounted) {
      setState(() {
        _scooterIcon = icon;
      });
    }
  }

  @override
  void didUpdateWidget(DriverMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newLoc = widget.driverLocation;
    final oldLoc = oldWidget.driverLocation;

    if (newLoc != null && newLoc != oldLoc) {
      if (_animatedDriverLatLng == null) {
        _animatedDriverLatLng = newLoc;
        _targetDriverLatLng = newLoc;
      } else {
        _prevDriverLatLng = _animatedDriverLatLng;
        _targetDriverLatLng = newLoc;
        _markerAnimController?.forward(from: 0.0);
      }

      // Move camera to initial location on first fix unless user already moved the map
      if (!_hasMovedCameraToInitial && !_userInteractedWithMap && _controller != null) {
        _hasMovedCameraToInitial = true;
        _controller?.animateCamera(
          CameraUpdate.newLatLngZoom(newLoc, 16.0),
        );
      }
    }

    // Handle store location changes
    if (widget.storeLocation != null &&
        widget.storeLocation != oldWidget.storeLocation) {
      _fitBoundsIfStoreAvailable();
    }
  }

  void _fitBoundsIfStoreAvailable() {
    if (widget.storeLocation == null || _controller == null) return;
    final driverLoc = widget.driverLocation ?? _animatedDriverLatLng;
    if (driverLoc == null) return;

    final storeLoc = widget.storeLocation!;
    final southwest = LatLng(
      min(driverLoc.latitude, storeLoc.latitude),
      min(driverLoc.longitude, storeLoc.longitude),
    );
    final northeast = LatLng(
      max(driverLoc.latitude, storeLoc.latitude),
      max(driverLoc.longitude, storeLoc.longitude),
    );

    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    _hasFittedStoreBounds = true;
    _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70.0),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    widget.onMapCreated?.call(controller);

    final initialLoc = widget.driverLocation ?? _animatedDriverLatLng;
    if (initialLoc != null && !_hasMovedCameraToInitial && !_userInteractedWithMap) {
      _hasMovedCameraToInitial = true;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(initialLoc, 16.0),
      );
    }

    if (widget.storeLocation != null && !_hasFittedStoreBounds) {
      _fitBoundsIfStoreAvailable();
    }
  }

  @override
  void dispose() {
    _markerAnimController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If running in headless unit/widget tests without a platform view factory,
    // render a safe mock container so tests don't throw MissingPluginException.
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return Container(
        color: AppColors.scaffoldBackground(context),
        child: const Center(
          child: Text('Map View Test Environment'),
        ),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mapStyle = isDarkMode ? AppColors.darkMapStyle : null;
    final centerTarget =
        widget.driverLocation ?? _animatedDriverLatLng ?? DriverMapView.fallbackCairo;

    final markers = <Marker>{};

    // 1. Driver Scooter Marker
    final effectiveDriverPos = _animatedDriverLatLng ?? widget.driverLocation;
    if (effectiveDriverPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver_scooter_marker'),
          position: effectiveDriverPos,
          icon: _scooterIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          anchor: const Offset(0.5, 0.5),
          flat: true,
          // Side-profile icon remains upright (rotation: 0) to avoid flipping upside down
          rotation: 0.0,
          zIndexInt: 2,
        ),
      );
    }

    // 2. Store Marker (optional, prepared for active order)
    if (widget.storeLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('store_marker'),
          position: widget.storeLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Store'),
          anchor: const Offset(0.5, 1.0),
          zIndexInt: 1,
        ),
      );
    }

    // 3. Route Polyline (optional, prepared for active order)
    // TODO(API): Directions API integration to calculate routePoints between driver and store/customer
    final polylines = <Polyline>{};
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_route_polyline'),
          points: widget.routePoints!,
          color: AppColors.primary,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    return Container(
      color: AppColors.scaffoldBackground(context),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: centerTarget,
          zoom: widget.driverLocation != null ? 16.0 : 14.0,
        ),
        onMapCreated: _onMapCreated,
        onCameraMoveStarted: () {
          // If the driver manually interacts with the map, stop auto-re-centering
          _userInteractedWithMap = true;
        },
        markers: markers,
        polylines: polylines,
        padding: widget.mapPadding,
        style: mapStyle,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
      ),
    );
  }
}
