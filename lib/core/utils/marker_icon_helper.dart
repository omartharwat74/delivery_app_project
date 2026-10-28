import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_assets.dart';

class MarkerIconHelper {
  MarkerIconHelper._();

  static BitmapDescriptor? _cachedScooterIcon;
  static double? _cachedPixelRatio;
  static double? _cachedSize;

  /// Loads and rasterizes the scooter SVG into a crisp [BitmapDescriptor]
  /// with a fixed square dimension of 48x48 dp across all devices,
  /// preserving the SVG's aspect ratio centered inside the square frame.
  static Future<BitmapDescriptor> getScooterMarkerIcon({
    double logicalSize = 48.0,
    double pixelRatio = 2.0,
  }) async {
    if (_cachedScooterIcon != null &&
        _cachedPixelRatio == pixelRatio &&
        _cachedSize == logicalSize) {
      return _cachedScooterIcon!;
    }

    try {
      final targetPhysicalSize = (logicalSize * pixelRatio).round();

      final pictureInfo = await vg.loadPicture(
        const SvgAssetLoader(AppAssets.scooterMarker),
        null,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Fit the SVG inside square canvas preserving aspect ratio (BoxFit.contain)
      final scale = math.min(
        targetPhysicalSize / pictureInfo.size.width,
        targetPhysicalSize / pictureInfo.size.height,
      );

      final dx = (targetPhysicalSize - pictureInfo.size.width * scale) / 2.0;
      final dy = (targetPhysicalSize - pictureInfo.size.height * scale) / 2.0;

      canvas.translate(dx, dy);
      canvas.scale(scale, scale);
      canvas.drawPicture(pictureInfo.picture);
      final picture = recorder.endRecording();
      pictureInfo.picture.dispose();

      final image = await picture.toImage(targetPhysicalSize, targetPhysicalSize);
      picture.dispose();

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData != null) {
        final icon = BitmapDescriptor.bytes(
          byteData.buffer.asUint8List(),
          width: logicalSize,
          height: logicalSize,
          imagePixelRatio: pixelRatio,
        );
        _cachedScooterIcon = icon;
        _cachedPixelRatio = pixelRatio;
        _cachedSize = logicalSize;
        return icon;
      }
    } catch (e, stack) {
      debugPrint('Failed to rasterize scooter SVG marker: $e\n$stack');
    }

    // Fallback if SVG rasterization fails
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
  }

  @visibleForTesting
  static void clearCache() {
    _cachedScooterIcon = null;
    _cachedPixelRatio = null;
    _cachedSize = null;
  }
}
