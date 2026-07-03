import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/notification_provider.dart';
import 'package:onecitizen/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: () => provider.loadNotifications(),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? ErrorMessage(message: provider.error!, onRetry: () => provider.loadNotifications())
                : provider.notifications.isEmpty
                    ? const EmptyListMessage(message: 'No notifications yet.', icon: Icons.notifications_none)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.notifications.length,
                        itemBuilder: (context, index) {
                          final n = provider.notifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: n.isRead ? null : AppTheme.primaryGreen.withValues(alpha: 0.05),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (n.isRead ? AppTheme.textSecondary : AppTheme.primaryGreen).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                                  color: n.isRead ? AppTheme.textSecondary : AppTheme.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              title: Text(n.message, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600)),
                              subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(n.createdAt)),
                              onTap: n.isRead ? null : () => provider.markAsRead(n.id),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
