import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/notification.dart';
import 'package:onecitizen/services/citizen_services.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required NotificationService notificationService})
      : _notificationService = notificationService;

  final NotificationService _notificationService;

  List<AppNotification> notifications = [];
  bool isLoading = false;
  String? error;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      notifications = await _notificationService.getNotifications();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      final idx = notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        notifications[idx] = AppNotification(
          id: notifications[idx].id,
          message: notifications[idx].message,
          createdAt: notifications[idx].createdAt,
          isRead: true,
        );
        notifyListeners();
      }
    } catch (_) {
      // best-effort
    }
  }
}
