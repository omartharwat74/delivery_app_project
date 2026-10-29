import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:delivery_app_project/features/home/presentation/widgets/driver_map_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Polyline Decoding Tests', () {
    test('decodePolyline decodes standard encoded polyline correctly', () {
      // Google / OSRM official test vector:
      // (38.5, -120.2), (40.7, -120.95), (43.252, -126.453)
      // Encoded: "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final points = decodePolyline(encoded);

      expect(points.length, 3);
      expect(points[0].latitude, closeTo(38.5, 0.0001));
      expect(points[0].longitude, closeTo(-120.2, 0.0001));
      expect(points[1].latitude, closeTo(40.7, 0.0001));
      expect(points[1].longitude, closeTo(-120.95, 0.0001));
      expect(points[2].latitude, closeTo(43.252, 0.0001));
      expect(points[2].longitude, closeTo(-126.453, 0.0001));
    });

    test('decodePolyline handles empty string', () {
      expect(decodePolyline(''), isEmpty);
    });
  });

  group('OSRM Routing getRoutePolyline Tests', () {
    const start = LatLng(30.0444, 31.2357);
    const end = LatLng(30.0500, 31.2400);

    test('successfully fetches and decodes route from OSRM', () async {
      final mockClient = MockClient((request) async {
        // Verify OSRM coordinate order: {startLng},{startLat};{endLng},{endLat}
        expect(request.url.toString(), contains('31.2357,30.0444;31.24,30.05'));
        expect(request.url.queryParameters['overview'], 'full');
        expect(request.url.queryParameters['geometries'], 'polyline');

        final body = jsonEncode({
          'code': 'Ok',
          'routes': [
            {
              'geometry': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
              'distance': 1500.0,
              'duration': 180.0,
            }
          ],
        });
        return http.Response(body, 200);
      });

      final result = await getRoutePolyline(start, end, client: mockClient);

      expect(result.length, 3);
      expect(result[0].latitude, closeTo(38.5, 0.0001));
      expect(result[0].longitude, closeTo(-120.2, 0.0001));
    });

    test('falls back to straight line [start, end] when OSRM returns non-200 status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final result = await getRoutePolyline(start, end, client: mockClient);

      expect(result.length, 2);
      expect(result[0], equals(start));
      expect(result[1], equals(end));
    });

    test('falls back to straight line [start, end] when OSRM throws network exception', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Connection timeout');
      });

      final result = await getRoutePolyline(start, end, client: mockClient);

      expect(result.length, 2);
      expect(result[0], equals(start));
      expect(result[1], equals(end));
    });

    test('falls back to straight line [start, end] when OSRM response has no routes', () async {
      final mockClient = MockClient((request) async {
        final body = jsonEncode({
          'code': 'NoRoute',
          'routes': [],
        });
        return http.Response(body, 200);
      });

      final result = await getRoutePolyline(start, end, client: mockClient);

      expect(result.length, 2);
      expect(result[0], equals(start));
      expect(result[1], equals(end));
    });
  });

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
