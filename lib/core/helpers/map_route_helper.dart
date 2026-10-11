import 'package:dio/dio.dart';
import 'package:flutter_task/core/constants/map_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRouteHelper {
  MapRouteHelper._();

  static Future<List<LatLng>> getRoutePoints(
    LatLng origin,
    LatLng destination,
  ) async {
    final apiKey = MapConstants.googleMapsApiKey;
    if (apiKey.isEmpty) {
      return [origin, destination];
    }

    try {
      final response = await Dio().get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': apiKey,
        },
      );

      final routes = response.data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        return [origin, destination];
      }

      final encoded =
          routes.first['overview_polyline']?['points'] as String?;
      if (encoded == null || encoded.isEmpty) {
        return [origin, destination];
      }

      return _decodePolyline(encoded);
    } catch (_) {
      return [origin, destination];
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
