import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_app_project/features/home/presentation/widgets/driver_map_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriverMapView Widget Tests', () {
    testWidgets('renders fallback placeholder in test environment safely', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverMapView(),
          ),
        ),
      );

      expect(find.byType(DriverMapView), findsOneWidget);
      expect(find.text('Map View Test Environment'), findsOneWidget);
    });

    testWidgets('accepts driverLocation, storeLocation, and routePoints without throwing', (tester) async {
      const driverLoc = LatLng(30.05, 31.25);
      const storeLoc = LatLng(30.06, 31.26);
      const routePoints = [driverLoc, storeLoc];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverMapView(
              driverLocation: driverLoc,
              storeLocation: storeLoc,
              routePoints: routePoints,
            ),
          ),
        ),
      );

      final mapView = tester.widget<DriverMapView>(find.byType(DriverMapView));
      expect(mapView.driverLocation, equals(driverLoc));
      expect(mapView.storeLocation, equals(storeLoc));
      expect(mapView.routePoints, equals(routePoints));
    });
  });
}
