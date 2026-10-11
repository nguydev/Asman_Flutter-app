class ApiConstants {
  /// Override at run time, e.g.:
  /// `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4001`
  static const String baseUrl = 'https://asman.xdtunnel.icu';

  static String get socketOrigin {
    final uri = Uri.parse(baseUrl);
    final path = uri.path.replaceFirst(RegExp(r'/api(/v\d+)?/?$'), '');
    return uri.replace(path: path, query: null, fragment: null).toString();
  }

  /// ─── Auth Marker ───────────────────────────
  static const String requiresAuthHeader = 'X-Requires-Auth';
  static const Map<String, dynamic> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// AUTH ──────────────────────────────────────────────
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String refresh = '/api/v1/auth/refresh';
  static const String otpVerify = '/api/v1/auth/email/verify/otp';
  static const String resendOtp = '/api/v1/auth/email/verify/resend';
  static const String forgotPassword = '/api/v1/auth/password/forgot';
  static const String resetOtpVerify = '/api/v1/auth/password/reset/otp';
  static const String resetPassword = '/api/v1/auth/password/reset';
  static const String changePassword = '/api/v1/auth/password/change';
  static const String accountDelete = '/api/v1/auth/account-delete';

  /// USER ──────────────────────────────────────────────
  static const String userProfile = '/api/v1/auth/me';
  static const String getProfile = '/api/v1/users/me';
  static const String userOnboarding = '/api/v1/auth/me/onboarding';
  static const String trainerProfile = '/api/v1/trainer';
  static const String trainerRequest = '/api/v1/trainer-request';
  static const String trainerRequestAll = '/api/v1/trainer-request/all';
  static String acceptTrainerRequest(String requestId, String type) =>
      '/api/v1/trainer-request/$requestId/$type';
  static String trainerKnowledgePack(String trainerId) =>
      '/api/v1/trainer/$trainerId/knowledge-pack';
  static String trainerDetails(String trainerId) =>
      '/api/v1/trainer/$trainerId';
  static String trainers(int page, int limit) =>
      '/api/v1/trainer?page=$page&limit=$limit';

  /// EXERCISE BLOCK ──────────────────────────────────────────────
  static String trainerBlocks(
    String trainerId,
    int page,
    int limit, {
    bool approvedOnly = true,
  }) =>
      '/api/v1/trainer/$trainerId/blocks?approvedOnly=$approvedOnly&page=$page&limit=$limit';

  static String trainerBlocksGenerate(String trainerId) =>
      '/api/v1/trainer/$trainerId/blocks/generate';

  static String trainerBlocksCreate(String trainerId) =>
      '/api/v1/trainer/$trainerId/blocks';

  static String trainerBlockById(String trainerId, String blockId) =>
      '/api/v1/trainer/$trainerId/blocks/$blockId';

  static String blockById(String blockId) => '/api/v1/block/$blockId';

  /// INVOICE ──────────────────────────────────────────────
  static const String invoice = '/api/v1/invoice';
  static const String trainerInvoices = '/api/v1/invoice/trainer';
  static String sendInvoice(String invoiceId) =>
      '/api/v1/invoice/$invoiceId/send';

  /// CATEGORY ──────────────────────────────────────────────
  static const String categoryMy = '/api/v1/category/my';
  static const String categoryCreate = '/api/v1/category/create';
  static String categoryById(String categoryId) =>
      '/api/v1/category/$categoryId';

  /// CONTENT ──────────────────────────────────────────────
  static const String myContent = '/api/v1/content/my-content';
  static const String content = '/api/v1/content/content';
  static String contentById(String contentId) =>
      '/api/v1/content/content/$contentId';

  /// PRIVACY ──────────────────────────────────────────────
  static const String privacyPolicy = '/api/v1/privacy';
  static const String termsAndCondition = '/api/v1/terms';
  static const String aboutUs = '/api/v1/about';
  static const String legal = '/api/v1/legal';

  /// DEVICE ──────────────────────────────────────────────
  static const String userDevices = '/api/v1/devices';
  static const String pairDevice = '/api/v1/devices/pair';
  static String deviceStatus(String deviceId) =>
      '/api/v1/devices/$deviceId/status';
  static String unpairDevice(String deviceId) => '/api/v1/devices/$deviceId';
  static String deviceMetrics(String deviceId) =>
      '/api/v1/devices/$deviceId/metrics';

  /// SOS ─────────────────────────────────────────────────
  static const String sosTrigger = '/api/v1/sos/trigger';
  static const String mapLocations = '/api/v1/map/locations';
  static const String mapOverview = '/api/v1/map/overview';
  static String mapOrganizationFocus(String organizationId) =>
      '/api/v1/map/overview?organizationId=$organizationId';
  static const String organizations = '/api/v1/organizations';
  static const String sosContacts = '/api/v1/sos/contacts';
  static String deleteSosContact(String id) => '/api/v1/sos/contacts/$id';

  /// FILES ──────────────────────────────────────────────
  static const String filesList = '/api/v1/files';
  static const String filesUploadUrl = '/api/v1/files/upload-url';
  static String fileComplete(String id) => '/api/v1/files/$id/complete';
  static String fileDownloadUrl(String id) => '/api/v1/files/$id/download-url';
  static String fileDelete(String id) => '/api/v1/files/$id';

  /// VAULT ──────────────────────────────────────────────
  static const String vault = '/api/v1/vault';
  static String deleteVaultItem(String id) => '/api/v1/vault/$id';

  ///
  static const String searchHistoryKey = '/searchHistoryKey';
}
