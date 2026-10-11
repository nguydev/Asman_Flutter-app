import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/constants/app_constants.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/core/helpers/floatingSuccessbar.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/core/services/location_service.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final CacheService _cacheService = Get.find<CacheService>();

  final isLoading = false.obs;

  String _getErrorMessage(dynamic e) {
    if (e is AppException) {
      return e.message;
    }
    return e.toString();
  }

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  // Register Controllers
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final vinController = TextEditingController();
  final licenseController = TextEditingController();

  // OTP Verification email holder & mode
  String verificationEmail = '';
  final isForgotPasswordMode = false.obs;
  String resetToken = '';

  // Periodic timer for 5-sec auto refresh token check
  Worker? _refreshWorker;
  dynamic _periodicTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoRefreshTokenTimer();
  }

  void _startAutoRefreshTokenTimer() {
    // Periodically check every 5 seconds to automatically refresh token if refresh token exists
    _periodicTimer = Stream.periodic(const Duration(seconds: 5)).listen((_) {
      final refreshToken = _cacheService.get<String>(AppConstants.refreshToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        _refreshTokenSilently();
      }
    });
  }

  bool _isTokenExpiredOrExpiringSoon(String? token) {
    if (token == null || token.isEmpty) {
      debugPrint('🔑 [TokenCheck] Access token is missing/empty.');
      return true;
    }
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('🔑 [TokenCheck] Access token format is invalid.');
        return true;
      }
      
      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payload = jsonDecode(payloadString);
      
      if (payload['exp'] != null) {
        final expSeconds = payload['exp'] as int;
        final expDate = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
        final now = DateTime.now().toUtc();
        final secondsRemaining = expDate.difference(now).inSeconds;

        if (now.add(const Duration(seconds: 30)).isAfter(expDate)) {
          debugPrint('🔑 [TokenCheck] Token EXPIRED or EXPIRING SOON ($secondsRemaining sec remaining). Refreshing...');
          return true;
        } else {
          debugPrint('🔑 [TokenCheck] Token VALID ($secondsRemaining sec remaining). Skip API refresh call.');
          return false;
        }
      }
    } catch (e) {
      debugPrint('🔑 [TokenCheck] Error parsing token exp: $e');
      return true;
    }
    return false;
  }

  Future<void> _refreshTokenSilently() async {
    final accessToken = _cacheService.get<String>(AppConstants.accessToken);
    
    // Only refresh if the access token is missing, expired, or about to expire in < 30 seconds
    if (!_isTokenExpiredOrExpiringSoon(accessToken)) {
      return;
    }

    final refreshToken = _cacheService.get<String>(AppConstants.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('🔑 [TokenRefresh] No refresh token found in cache.');
      return;
    }

    try {
      debugPrint('🔄 [TokenRefresh] Hitting /api/v1/auth/refresh API...');
      final response = await _apiService.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
        options: ApiService.withoutAuth,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        String? newAccessToken;
        String? newRefreshToken;

        if (data != null) {
          if (data['tokens'] != null) {
            final tokens = data['tokens'];
            newAccessToken = tokens['access']?['token'] ?? tokens['accessToken'];
            newRefreshToken = tokens['refresh']?['token'] ?? tokens['refreshToken'];
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
          debugPrint('✅ [TokenRefresh] Successfully refreshed access token!');
        }
      }
    } catch (e) {
      debugPrint('❌ [TokenRefresh] Silent refresh failed: $e');
    }
  }

  @override
  void onClose() {
    _periodicTimer?.cancel();
    _refreshWorker?.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    vinController.dispose();
    licenseController.dispose();
    super.onClose();
  }

  /// Safe helper to show a SnackBar without causing Overlay errors
  void showSnackbar(String title, String message, {bool isError = true}) {
    final context = Get.context ?? Get.overlayContext ?? Get.key.currentContext;
    if (context != null) {
      if (isError) {
        FloatingErrorBar.show(context, message: message);
      } else {
        FloatingSuccessBar.show(context, message: message);
      }
    } else {
      // Fallback fallback if context is not immediately available
      Get.rawSnackbar(
        title: title,
        message: message,
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Handle Sign In
  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showSnackbar('Error', 'Please enter your email and password', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        String? accessToken;
        String? refreshToken;

        if (data != null) {
          if (data['tokens'] != null) {
            final tokens = data['tokens'];
            if (tokens['access'] != null && tokens['access']['token'] != null) {
              accessToken = tokens['access']['token'];
            } else {
              accessToken = tokens['accessToken'];
            }

            if (tokens['refresh'] != null && tokens['refresh']['token'] != null) {
              refreshToken = tokens['refresh']['token'];
            } else {
              refreshToken = tokens['refreshToken'];
            }
          } else {
            accessToken = data['accessToken'];
            refreshToken = data['refreshToken'];
          }
        }

        if (accessToken != null && accessToken.isNotEmpty) {
          await _cacheService.put(AppConstants.accessToken, accessToken);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await _cacheService.put(AppConstants.refreshToken, refreshToken);
          }

          // Cache JWT platform role for map personalization.
          try {
            final parts = accessToken.split('.');
            if (parts.length == 3) {
              final normalized = base64Url.normalize(parts[1]);
              final payload = jsonDecode(
                utf8.decode(base64Url.decode(normalized)),
              ) as Map<String, dynamic>;
              final role = payload['role']?.toString();
              if (role != null && role.isNotEmpty) {
                await _cacheService.put(AppConstants.cacheUserRole, role);
              }
            }
          } catch (_) {}

          showSnackbar('Success', 'Successfully logged in', isError: false);

          // Ask for location after login (not at cold app start).
          await LocationService().ensurePermission();

          Get.offAllNamed(AppRoutes.mainBottomNav);
        } else {
          throw Exception('Token not found in response');
        }
      }
    } catch (e) {
      showSnackbar('Login Failed', _getErrorMessage(e), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle Register
  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final vin = vinController.text.trim();
    final license = licenseController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || vin.isEmpty || license.isEmpty) {
      showSnackbar('Error', 'All fields are required', isError: true);
      return;
    }

    if (password != confirmPassword) {
      showSnackbar('Error', 'Passwords do not match', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'vinNumber': vin,
          'licensePlate': license,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        verificationEmail = email;
        isForgotPasswordMode.value = false;
        showSnackbar('Verification Required', 'Please verify your email using the OTP sent to your mailbox.', isError: false);
        Get.toNamed(AppRoutes.otp);
      }
    } catch (e) {
      showSnackbar('Registration Failed', _getErrorMessage(e), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle Forgot Password
  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showSnackbar('Error', 'Please enter your email address', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        verificationEmail = email;
        isForgotPasswordMode.value = true;
        showSnackbar('OTP Sent', 'Password reset code sent to your email.', isError: false);
        Get.toNamed(AppRoutes.otp);
      }
    } catch (e) {
      showSnackbar('Error', _getErrorMessage(e), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP (used for both Register verify and Forgot Password verify)
  Future<void> verifyOtp(String code) async {
    final email = verificationEmail.isNotEmpty ? verificationEmail : emailController.text.trim();

    if (email.isEmpty) {
      showSnackbar('Error', 'Email address is missing for verification', isError: true);
      return;
    }

    if (code.isEmpty) {
      showSnackbar('Error', 'Please enter the OTP code', isError: true);
      return;
    }

    try {
      isLoading.value = true;

      if (isForgotPasswordMode.value) {
        // Forgot password OTP verification
        final response = await _apiService.post(
          ApiConstants.resetOtpVerify,
          data: {
            'email': email,
            'code': code,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          resetToken = data?['resetToken'] ?? '';
          showSnackbar('Verified', data?['message'] ?? 'Password reset code verified', isError: false);
          Get.offNamed(AppRoutes.resetPassword);
        }
      } else {
        // Registration email verification
        final response = await _apiService.post(
          ApiConstants.otpVerify,
          data: {
            'email': email,
            'code': code,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSnackbar('Verified', 'OTP successfully verified. Please sign in.', isError: false);
          Get.offAllNamed(AppRoutes.login);
        }
      }
    } catch (e) {
      showSnackbar('Verification Failed', _getErrorMessage(e), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset Password with token
  Future<void> resetPassword() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      showSnackbar('Error', 'Please enter new password and confirm password', isError: true);
      return;
    }

    if (password != confirmPassword) {
      showSnackbar('Error', 'Passwords do not match', isError: true);
      return;
    }

    if (resetToken.isEmpty) {
      showSnackbar('Error', 'Reset token is missing. Please verify OTP again.', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.post(
        ApiConstants.resetPassword,
        data: {
          'token': resetToken,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSnackbar('Success', 'Password has been reset successfully. Please sign in.', isError: false);
        passwordController.clear();
        confirmPasswordController.clear();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      showSnackbar('Reset Failed', _getErrorMessage(e), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    final email = verificationEmail.isNotEmpty ? verificationEmail : emailController.text.trim();

    if (email.isEmpty) {
      showSnackbar('Error', 'Email address is missing for sending OTP', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      if (isForgotPasswordMode.value) {
        final response = await _apiService.post(
          ApiConstants.forgotPassword,
          data: {'email': email},
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          showSnackbar('OTP Sent', 'Password reset OTP has been resent to $email', isError: false);
        }
      } else {
        final response = await _apiService.post(
          ApiConstants.resendOtp,
          data: {'email': email},
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          showSnackbar('OTP Sent', 'OTP has been resent to $email', isError: false);
        }
      }
    } catch (e) {
      showSnackbar('Resend Failed', _getErrorMessage(e), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _cacheService.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
