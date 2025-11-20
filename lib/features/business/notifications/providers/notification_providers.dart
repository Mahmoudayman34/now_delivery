import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'package:flutter_riverpod/legacy.dart';
/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for fetching notifications
final notificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.getNotifications();
});

/// Provider for unread notification count
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.getUnreadCount();
});

/// StateNotifier for managing notification state
class NotificationStateNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationService _service;

  NotificationStateNotifier(this._service) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  /// Load notifications
  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _service.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final success = await _service.markAsRead(notificationId);
    if (success) {
      await loadNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final success = await _service.markAllAsRead();
    if (success) {
      await loadNotifications();
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final success = await _service.deleteNotification(notificationId);
    if (success) {
      await loadNotifications();
    }
  }
}

/// Provider for NotificationStateNotifier
final notificationStateProvider = StateNotifierProvider<NotificationStateNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationStateNotifier(service);
});

