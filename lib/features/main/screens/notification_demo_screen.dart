import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/custom_notifications.dart';
import '../../../theme/app_theme.dart';

/// Demo screen to showcase all notification types
/// This can be accessed from the profile or settings screen for testing
class NotificationDemoScreen extends StatelessWidget {
  const NotificationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Notification Examples',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkGray),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap any button below to see the notification style',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Success Notifications
            _SectionTitle(title: 'Success Notifications'),
            const SizedBox(height: 12),
            _NotificationButton(
              label: 'Simple Success',
              color: Colors.green,
              onPressed: () {
                CustomNotification.showSuccess(
                  context,
                  message: 'Your message has been sent successfully!',
                );
              },
            ),
            const SizedBox(height: 12),
            _NotificationButton(
              label: 'Success with Custom Title',
              color: Colors.green,
              onPressed: () {
                CustomNotification.showSuccess(
                  context,
                  title: 'Order Delivered',
                  message: 'Package delivered to customer at 10:30 AM',
                  duration: const Duration(seconds: 5),
                );
              },
            ),
            const SizedBox(height: 24),

            // Error Notifications
            _SectionTitle(title: 'Error Notifications'),
            const SizedBox(height: 12),
            _NotificationButton(
              label: 'Simple Error',
              color: Colors.red,
              onPressed: () {
                CustomNotification.showError(
                  context,
                  message: 'Sorry, please try again later.',
                );
              },
            ),
            const SizedBox(height: 12),
            _NotificationButton(
              label: 'Error with Retry Button',
              color: Colors.red,
              onPressed: () {
                CustomNotification.showError(
                  context,
                  title: 'Connection Failed',
                  message: 'Unable to connect to server',
                  onRetry: () {
                    // Show another notification when retry is tapped
                    CustomNotification.showInfo(
                      context,
                      message: 'Retry button was tapped!',
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Info Notifications
            _SectionTitle(title: 'Info Notifications'),
            const SizedBox(height: 12),
            _NotificationButton(
              label: 'Simple Info',
              color: Colors.blue,
              onPressed: () {
                CustomNotification.showInfo(
                  context,
                  message: 'Check your email for confirmation.',
                );
              },
            ),
            const SizedBox(height: 12),
            _NotificationButton(
              label: 'Maintenance Notice',
              color: Colors.blue,
              onPressed: () {
                CustomNotification.showInfo(
                  context,
                  title: 'Scheduled Maintenance',
                  message: 'Our website will be undergoing scheduled maintenance tonight from 10 PM to 2 AM.',
                  duration: const Duration(seconds: 6),
                );
              },
            ),
            const SizedBox(height: 24),

            // Warning Notifications
            _SectionTitle(title: 'Warning Notifications'),
            const SizedBox(height: 12),
            _NotificationButton(
              label: 'Simple Warning',
              color: Colors.orange,
              onPressed: () {
                CustomNotification.showWarning(
                  context,
                  message: 'Please save your changes before leaving.',
                );
              },
            ),
            const SizedBox(height: 12),
            _NotificationButton(
              label: 'Subscription Warning',
              color: Colors.orange,
              onPressed: () {
                CustomNotification.showWarning(
                  context,
                  title: 'Subscription Expiring',
                  message: 'Your subscription is about to expire in 3 days. Renew now to avoid any service interruptions.',
                  duration: const Duration(seconds: 5),
                );
              },
            ),
            const SizedBox(height: 40),

            // Documentation Link
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.code,
                    size: 48,
                    color: AppTheme.primaryOrange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Implementation Guide',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check CUSTOM_NOTIFICATIONS_GUIDE.md in the project root for implementation details and examples.',
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
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.darkGray,
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _NotificationButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
