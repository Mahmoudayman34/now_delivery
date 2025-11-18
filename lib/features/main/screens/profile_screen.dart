import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';
import '../../main/providers/navigation_provider.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return LoadingOverlay(
      isLoading: authState.isLoading,
      loadingMessage: authState.status.toString().contains('delete') 
          ? 'Deleting account...' 
          : 'Loading...',
      child: Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Responsive.builder(
        context: context,
        mobile: _buildMobileLayout(context, ref, user),
        tablet: context.isLandscape
            ? _buildTabletLandscapeLayout(context, ref, user)
            : _buildMobileLayout(context, ref, user),
        desktop: _buildDesktopLayout(context, ref, user),
      ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, dynamic user) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        children: [
          _buildProfileCard(context, user, textTheme, spacing),
          SizedBox(height: spacing.lg),
          _buildPerformanceStats(context, textTheme, spacing),
          SizedBox(height: spacing.xl),
          _buildMenuOptions(context, ref, textTheme, spacing),
          SizedBox(height: 100), // Extra padding for bottom navigation
        ],
      ),
    );
  }

  Widget _buildTabletLandscapeLayout(BuildContext context, WidgetRef ref, dynamic user) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Profile Card
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              children: [
                _buildProfileCard(context, user, textTheme, spacing),
                SizedBox(height: spacing.lg),
                _buildPerformanceStats(context, textTheme, spacing),
              ],
            ),
          ),
        ),
        
        // Right Panel - Menu Options
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: _buildMenuOptions(context, ref, textTheme, spacing),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, dynamic user) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: context.responsive<double>(
            mobile: double.infinity,
            desktop: 800,
            largeDesktop: 1000,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Profile Card
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(spacing.xl),
                child: Column(
                  children: [
                    _buildProfileCard(context, user, textTheme, spacing),
                    SizedBox(height: spacing.lg),
                    _buildPerformanceStats(context, textTheme, spacing),
                  ],
                ),
              ),
            ),
            
            // Right Panel - Menu Options
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(spacing.xl),
                child: _buildMenuOptions(context, ref, textTheme, spacing),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    dynamic user,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Responsive.borderRadius(
          context,
          mobile: 16,
          tablet: 18,
          desktop: 20,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.responsive<double>(
              mobile: 10,
              tablet: 12,
              desktop: 15,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: context.responsive<double>(
              mobile: 80,
              tablet: 90,
              desktop: 100,
            ),
            height: context.responsive<double>(
              mobile: 80,
              tablet: 90,
              desktop: 100,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppTheme.primaryOrange.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: user?.avatar != null && user!.avatar!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: Image.file(
                      File(user.avatar!),
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryOrange,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryOrange,
                  ),
          ),
          SizedBox(height: spacing.md),
          Text(
            user?.name ?? 'User Name',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            user?.email ?? 'user@example.com',
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats(
    BuildContext context,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF8F0),
            const Color(0xFFFFEFDB),
          ],
        ),
        borderRadius: Responsive.borderRadius(
          context,
          mobile: 16,
          tablet: 18,
          desktop: 20,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Stats',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          SizedBox(height: spacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context: context,
                icon: Icons.local_shipping_outlined,
                value: '245',
                label: 'Deliveries',
                iconColor: AppTheme.primaryOrange,
                textTheme: textTheme,
                spacing: spacing,
              ),
              _buildStatItem(
                context: context,
                icon: Icons.trending_up,
                value: '98%',
                label: 'On Time',
                iconColor: Colors.green,
                textTheme: textTheme,
                spacing: spacing,
              ),
              _buildStatItem(
                context: context,
                icon: Icons.star,
                value: '4.8',
                label: 'Rating',
                iconColor: Colors.amber,
                textTheme: textTheme,
                spacing: spacing,
                showStar: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required TextTheme textTheme,
    required ResponsiveSpacing spacing,
    bool showStar = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          if (showStar)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: context.responsive<double>(
                    mobile: 28,
                    tablet: 32,
                    desktop: 36,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(
    BuildContext context,
    WidgetRef ref,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Column(
      children: [
        // Settings - Simple row
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: AppTheme.darkGray,
                    size: 24,
                  ),
                  SizedBox(width: spacing.md),
                  Text(
                    'Settings',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: spacing.md),
        
        // Help and Support - Simple row
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: AppTheme.darkGray,
                    size: 24,
                  ),
                  SizedBox(width: spacing.md),
                  Text(
                    'Help and Support',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // About - Simple row
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.darkGray,
                    size: 24,
                  ),
                  SizedBox(width: spacing.md),
                  Text(
                    'About',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(height: spacing.md),
        
        // Delete Account - Simple row with red icon
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDeleteAccountDialog(context, ref),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 24,
                  ),
                  SizedBox(width: spacing.md),
                  Text(
                    'Delete Account',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(height: spacing.md),
        
        // Logout - Red outline border
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showLogoutDialog(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.md,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 24,
                    ),
                    SizedBox(width: spacing.md),
                    Text(
                      'Logout',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: spacing.xl),
        
        // Version text
        Text(
          'Version 1.0.0',
          style: textTheme.bodyMedium?.copyWith(
            color: AppTheme.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Account',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. Deleting your account will:',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• Permanently delete all your data\n'
              '• Cancel any active orders\n'
              '• Delete your order history\n'
              '• Deactivate your account immediately',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you absolutely sure you want to delete your account?',
              style: GoogleFonts.inter(
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFinalDeleteConfirmation(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete Account',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final TextEditingController confirmController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Final Confirmation',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To confirm account deletion, please type "DELETE" below:',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: 'Type DELETE to confirm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (confirmController.text.trim() == 'DELETE') {
                Navigator.of(context).pop();
                await ref.read(authProvider.notifier).deleteAccount();
                
                if (context.mounted) {
                  final authState = ref.read(authProvider);
                  if (authState.hasError) {
                    ErrorDialog.show(
                      context,
                      title: 'Delete Failed',
                      message: authState.errorMessage ?? 'Failed to delete account',
                    );
                  } else {
                    SuccessSnackBar.show(
                      context,
                      message: 'Account deleted successfully',
                    );
                  }
                }
              } else {
                ErrorSnackBar.show(
                  context,
                  message: 'Please type "DELETE" to confirm',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirm Delete',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGray,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(
            color: AppTheme.mediumGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.of(context).pop();

              // Trace start of logout flow
              print('🔓 Logout requested from ProfileScreen');

              // Await logout to ensure shared prefs are cleared and AuthNotifier state updates
              await ref.read(authProvider.notifier).logout();

              print('🔁 AuthNotifier.logout() completed');

              // Reset bottom navigation to default (home/dashboard)
              try {
                ref.read(navigationProvider.notifier).setIndex(0);
              } catch (_) {}

              // Inform the user
              if (context.mounted) {
                SuccessSnackBar.show(context, message: 'Logged out successfully');
              }

              // Rely on the global auth state (AuthNotifier) to drive which root
              // screen is shown. `main.dart` listens to `authProvider` and will
              // automatically show `LoginScreen` when the user becomes
              // unauthenticated. Avoid manual navigation here to prevent route
              // conflicts and races.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
