import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/constants/app_constants.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  static const Duration _splashDuration = Duration(seconds: 2);
  final CacheService _cacheService = Get.find<CacheService>();

  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  Future<void> _startSplash() async {
    final startTime = DateTime.now();
    final refreshToken = _cacheService.get<String>(AppConstants.refreshToken);
    bool isSessionRestored = false;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final refreshResponse = await dio_pkg.Dio(dio_pkg.BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {'X-Auth-Transport': 'bearer'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )).post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        if (refreshResponse.statusCode == 200 || refreshResponse.statusCode == 201) {
          final data = refreshResponse.data;
          String? newAccessToken;
          String? newRefreshToken;

          if (data != null) {
            if (data['tokens'] != null) {
              final tokens = data['tokens'];
              if (tokens['access'] != null) {
                newAccessToken = tokens['access']['token'];
              }
              if (tokens['refresh'] != null) {
                newRefreshToken = tokens['refresh']['token'];
              }
            } else {
              newAccessToken = data['accessToken'];
              newRefreshToken = data['refreshToken'];
            }
          }

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            await _cacheService.put(AppConstants.accessToken, newAccessToken);
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await _cacheService.put(AppConstants.refreshToken, newRefreshToken);
            }
            isSessionRestored = true;
          }
        }
      } catch (_) {
        await _cacheService.clear();
      }
    }

    final elapsed = DateTime.now().difference(startTime);
    final remaining = _splashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    _navigateNext(isSessionRestored);
  }

  void _navigateNext(bool isSessionRestored) {
    if (isSessionRestored) {
      Get.offAllNamed(AppRoutes.mainBottomNav);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
