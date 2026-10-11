import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/constants/app_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

/// Socket.IO client for `/location` — matches backend `LocationGateway` + SOS.
class LocationSocketService {
  static final LocationSocketService _instance =
      LocationSocketService._internal();
  factory LocationSocketService() => _instance;
  LocationSocketService._internal();

  socket_io.Socket? _socket;
  final CacheService _cacheService = Get.find<CacheService>();
  final ApiService _apiService = Get.find<ApiService>();

  final isConnected = false.obs;
  final lastSubscribeAck = Rxn<Map<String, dynamic>>();

  final _locationUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _sosAlertController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _mapFocusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectedController = StreamController<void>.broadcast();

  Stream<Map<String, dynamic>> get locationUpdateStream =>
      _locationUpdateController.stream;
  Stream<Map<String, dynamic>> get sosAlertStream => _sosAlertController.stream;
  Stream<Map<String, dynamic>> get mapFocusStream => _mapFocusController.stream;
  Stream<void> get connectedStream => _connectedController.stream;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    disconnect();

    debugPrint(
      'LocationSocket connecting to ${ApiConstants.socketOrigin}/location',
    );

    _socket = socket_io.io(
      '${ApiConstants.socketOrigin}/location',
      _buildOptions(),
    );

    _socket?.onConnect((_) {
      debugPrint('LocationSocket connected');
      isConnected.value = true;
      _connectedController.add(null);
    });

    _socket?.on('location:update', (data) {
      if (data is Map) {
        _locationUpdateController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('sos:alert', (data) {
      if (data is Map) {
        _sosAlertController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('map:focus', (data) {
      if (data is Map) {
        _mapFocusController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket?.onDisconnect((reason) {
      debugPrint('LocationSocket disconnected: $reason');
      isConnected.value = false;
    });

    _socket?.onConnectError((err) {
      debugPrint('LocationSocket connect error: $err');
      isConnected.value = false;
    });
  }

  Map<String, dynamic> _buildOptions() {
    final token = _cacheService.get<String>(AppConstants.accessToken) ?? '';
    return socket_io.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .enableForceNew()
        .enableReconnection()
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .build();
  }

  /// Reconnect with a fresh access token (required after refresh).
  void reconnectWithFreshToken() {
    disconnect();
    connect();
  }

  Future<Map<String, dynamic>?> subscribeMap() async {
    if (_socket == null || !_socket!.connected) return null;
    debugPrint('LocationSocket emit map:subscribe');
    final completer = Completer<Map<String, dynamic>?>();
    _socket?.emitWithAck(
      'map:subscribe',
      null,
      ack: (ackData) {
        debugPrint('LocationSocket map:subscribe ack: $ackData');
        Map<String, dynamic>? mapped;
        if (ackData is Map) {
          mapped = Map<String, dynamic>.from(ackData);
          lastSubscribeAck.value = mapped;
        }
        if (!completer.isCompleted) completer.complete(mapped);
      },
    );
    try {
      return await completer.future.timeout(const Duration(seconds: 4));
    } on TimeoutException {
      return lastSubscribeAck.value;
    }
  }

  Future<bool> subscribeDashboard(String organizationId) async {
    if (_socket == null || !_socket!.connected) return false;
    final payload = {'organizationId': organizationId};
    debugPrint('LocationSocket emit dashboard:subscribe $organizationId');
    final completer = Completer<bool>();
    _socket?.emitWithAck(
      'dashboard:subscribe',
      payload,
      ack: (ackData) {
        debugPrint('LocationSocket dashboard:subscribe ack: $ackData');
        if (!completer.isCompleted) completer.complete(true);
      },
    );
    try {
      return await completer.future.timeout(const Duration(seconds: 3));
    } on TimeoutException {
      return false;
    }
  }

  Future<bool> subscribeAdminSos() async {
    if (_socket == null || !_socket!.connected) return false;
    debugPrint('LocationSocket emit admin:sos:subscribe');
    final completer = Completer<bool>();
    _socket?.emitWithAck(
      'admin:sos:subscribe',
      null,
      ack: (ackData) {
        debugPrint('LocationSocket admin:sos:subscribe ack: $ackData');
        if (!completer.isCompleted) completer.complete(true);
      },
    );
    try {
      return await completer.future.timeout(const Duration(seconds: 3));
    } on TimeoutException {
      return false;
    }
  }

  /// Role-aware subscribe per backend guide §5.3 / §10.
  Future<Map<String, dynamic>?> subscribeForViewer({
    required bool isAdmin,
    required bool isDriverEmitter,
    required List<String> organizationIds,
  }) async {
    final ack = await subscribeMap();
    if (ack == null) return null;

    if (isAdmin) {
      await subscribeAdminSos();
      return ack;
    }

    // dashboard:subscribe rejects sockets that have driverId attached.
    if (!isDriverEmitter) {
      for (final orgId in organizationIds) {
        await subscribeDashboard(orgId);
      }
    }
    return ack;
  }

  void pingLocation({
    required double lat,
    required double lon,
    double? speed,
    double? heading,
    required DateTime deviceTs,
  }) {
    if (_socket == null || !_socket!.connected) return;
    final payload = {
      'lat': lat,
      'lon': lon,
      'speed': speed,
      'heading': heading,
      'deviceTs': deviceTs.toUtc().toIso8601String(),
    };
    _socket?.emitWithAck('location:ping', payload, ack: (_) {});
  }

  Future<void> triggerSos({double? lat, double? lon, String? message}) async {
    final payload = {
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (message != null) 'message': message,
    };

    if (_socket == null || !_socket!.connected) {
      await _triggerSosRest(payload);
      return;
    }

    final ackCompleter = Completer<void>();
    _socket?.emitWithAck(
      'sos:trigger',
      payload,
      ack: (_) {
        if (!ackCompleter.isCompleted) ackCompleter.complete();
      },
    );

    try {
      await ackCompleter.future.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      await _triggerSosRest(payload);
    }
  }

  Future<void> _triggerSosRest(Map<String, dynamic> payload) async {
    await _apiService.post(ApiConstants.sosTrigger, data: payload);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  void dispose() {
    disconnect();
    _locationUpdateController.close();
    _sosAlertController.close();
    _mapFocusController.close();
    _connectedController.close();
  }
}
