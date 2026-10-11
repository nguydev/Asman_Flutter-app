import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapConstants {
  MapConstants._();

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}
