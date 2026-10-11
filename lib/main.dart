import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'core/services/cache_service.dart';
import 'core/di/dependency_injection.dart';
import 'app.dart';

Future<void> _initGoogleMapsAndroid() async {
  if (kIsWeb || !Platform.isAndroid) return;

  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    // Hybrid Composition is required on many Android devices (incl. MIUI)
    // so the map texture is not shown as a solid grey/black surface.
    mapsImplementation.useAndroidViewSurface = true;
    await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initGoogleMapsAndroid();
  await dotenv.load(fileName: '.env');

  // Initialize cache service
  await CacheService().init();

  // Initialize dependency injection
  await DependencyInjection.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}
