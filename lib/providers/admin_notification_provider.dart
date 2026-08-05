import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/notification.dart';
import 'package:onecitizen/services/admin_services.dart';

class AdminNotificationProvider extends ChangeNotifier {
  AdminNotificationProvider({required AdminNotificationService notificationService})
      : _notificationService = notificationService;

  final AdminNotificationService _notificationService;

  List<AppNotification> notifications = [];
  bool isLoading = false;
  String? error;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetched = await _notificationService.getNotifications();
      final locallyReadIds = notifications.where((n) => n.isRead).map((n) => n.id).toSet();
      notifications = [
        for (final n in fetched)
          (!n.isRead && locallyReadIds.contains(n.id))
              ? AppNotification(id: n.id, message: n.message, createdAt: n.createdAt, isRead: true)
              : n,
      ];
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

  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    try {
      await Future.wait(unread.map((n) => _notificationService.markAsRead(n.id)));
      notifications = [
        for (final n in notifications)
          n.isRead
              ? n
              : AppNotification(id: n.id, message: n.message, createdAt: n.createdAt, isRead: true),
      ];
      notifyListeners();
    } catch (_) {
      // best-effort
    }
  }
}
