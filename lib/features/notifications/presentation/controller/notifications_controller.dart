import 'package:flutter/material.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/features/notifications/data/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final notificationsList = <NotificationModel>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void _syncUnreadCount() {
    unreadCount.value =
        notificationsList.where((notification) => !notification.isRead).length;
  }

  List<dynamic> _extractList(dynamic rawData) {
    if (rawData == null) return const [];
    if (rawData is List) return rawData;

    if (rawData is Map) {
      final data = rawData['data'];
      if (data is List) return data;
      if (data is Map) {
        if (data['data'] is List) return data['data'] as List;
        if (data['items'] is List) return data['items'] as List;
      }
      if (rawData['items'] is List) return rawData['items'] as List;
    }

    return const [];
  }

  Future<void> fetchNotifications({bool isBackground = false}) async {
    try {
      if (!isBackground && notificationsList.isEmpty) {
        isLoading.value = true;
      }
      debugPrint(
        '🔔 Fetching notifications (isBackground: $isBackground)...',
      );

      final response = await _apiService.get('/api/v1/notifications');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = _extractList(response.data);
        final fetchedList = list
            .whereType<Map>()
            .map(
              (item) => NotificationModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        notificationsList.assignAll(fetchedList);
        _syncUnreadCount();
      }
    } catch (e) {
      debugPrint('❌ FAILED TO FETCH NOTIFICATIONS: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    final unreadNotifications =
        notificationsList.where((n) => !n.isRead).toList();
    if (unreadNotifications.isEmpty) {
      _syncUnreadCount();
      return;
    }

    try {
      notificationsList.assignAll(
        notificationsList
            .map(
              (n) => NotificationModel(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                isRead: true,
                createdAt: n.createdAt,
                audience: n.audience,
                userId: n.userId,
                data: n.data,
              ),
            )
            .toList(),
      );
      _syncUnreadCount();

      await Future.wait(
        unreadNotifications.map(
          (n) => _apiService.patch('/api/v1/notifications/${n.id}/read'),
        ),
      );
    } catch (e) {
      debugPrint(' Failed to mark all notifications as read: $e');
      await fetchNotifications(isBackground: true);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final index = notificationsList.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = notificationsList[index];
        if (!n.isRead) {
          notificationsList[index] = NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
            audience: n.audience,
            userId: n.userId,
            data: n.data,
          );
          notificationsList.refresh();
          _syncUnreadCount();
        }
      }
      await _apiService.patch('/api/v1/notifications/$id/read');
    } catch (e) {
      debugPrint('❌ Failed to mark notification as read: $e');
      await fetchNotifications(isBackground: true);
    }
  }

  Future<void> markAsUnread(String id) async {
    try {
      final index = notificationsList.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = notificationsList[index];
        notificationsList[index] = NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: false,
          createdAt: n.createdAt,
          audience: n.audience,
          userId: n.userId,
          data: n.data,
        );
        notificationsList.refresh();
        _syncUnreadCount();
      }
      await _apiService.patch('/api/v1/notifications/$id/unread');
    } catch (e) {
      debugPrint('❌ Failed to mark notification as unread: $e');
      await fetchNotifications(isBackground: true);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      notificationsList.removeWhere((n) => n.id == id);
      _syncUnreadCount();
      await _apiService.delete('/api/v1/notifications/$id');
    } catch (e) {
      debugPrint('❌ Failed to delete notification: $e');
      await fetchNotifications(isBackground: true);
    }
  }
}
