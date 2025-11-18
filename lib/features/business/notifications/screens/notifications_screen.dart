import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../theme/app_theme.dart';
import '../providers/notification_providers.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen loads
    Future.microtask(() {
      ref.read(notificationStateProvider.notifier).loadNotifications();
    });
  }

  Future<void> _refreshNotifications() async {
    await ref.read(notificationStateProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationStateProvider);
    final spacing = AppTheme.spacing(context);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          // Mark all as read button
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () async {
              await ref.read(notificationStateProvider.notifier).markAllAsRead();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(spacing);
          }
          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            color: AppTheme.primaryOrange,
            child: ListView.builder(
              padding: EdgeInsets.all(spacing.md),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(
                  notification,
                  spacing,
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
        error: (error, stackTrace) => _buildErrorState(error, spacing),
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    ResponsiveSpacing spacing,
  ) {
    return Container(
        margin: EdgeInsets.only(bottom: spacing.md),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? Colors.white 
              : AppTheme.primaryOrange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead 
                ? AppTheme.borderGray 
                : AppTheme.primaryOrange.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: notification.isRead 
                ? null 
                : () async {
                    await ref.read(notificationStateProvider.notifier).markAsRead(notification.id);
                  },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: AppTheme.primaryOrange,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.w600,
                                  color: AppTheme.darkGray,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.only(left: spacing.xs),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          notification.body,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.mediumGray,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: spacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppTheme.mediumGray,
                            ),
                            SizedBox(width: spacing.xs),
                            Text(
                              timeago.format(notification.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                            if (notification.type != null) ...[
                              SizedBox(width: spacing.sm),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: spacing.sm,
                                    vertical: spacing.xs - 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(notification.type!).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    notification.type!.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getTypeColor(notification.type!),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Mark as read button
                  if (!notification.isRead)
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.primaryOrange,
                        size: 20,
                      ),
                      onPressed: () async {
                        await ref.read(notificationStateProvider.notifier).markAsRead(notification.id);
                      },
                      tooltip: 'Mark as read',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildEmptyState(ResponsiveSpacing spacing) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 80,
              color: AppTheme.mediumGray.withOpacity(0.5),
            ),
            SizedBox(height: spacing.lg),
            Text(
              'No notifications yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
            SizedBox(height: spacing.sm),
            Text(
              'You\'ll see updates about your orders\nand deliveries here',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, ResponsiveSpacing spacing) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            SizedBox(height: spacing.lg),
            Text(
              'Failed to load notifications',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
            SizedBox(height: spacing.sm),
            Text(
              error.toString(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing.lg),
            ElevatedButton(
              onPressed: _refreshNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xl,
                  vertical: spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'pickup':
        return Icons.inventory_2_outlined;
      case 'return':
        return Icons.keyboard_return_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'alert':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return AppTheme.primaryOrange;
      case 'delivery':
        return Colors.blue;
      case 'pickup':
        return Colors.purple;
      case 'return':
        return Colors.orange;
      case 'payment':
        return AppTheme.successGreen;
      case 'alert':
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGray;
    }
  }
}

