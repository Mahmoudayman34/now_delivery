import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
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
            child: _buildProfileCard(context, user, textTheme, spacing),
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
                child: _buildProfileCard(context, user, textTheme, spacing),
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
          SizedBox(height: spacing.md),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.sm,
              ),
            ),
            child: Text(
              'Edit Profile',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
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
        _MenuOption(
          icon: Icons.settings,
          title: 'Settings',
          textTheme: textTheme,
          spacing: spacing,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        _MenuOption(
          icon: Icons.notifications,
          title: 'Notifications',
          textTheme: textTheme,
          spacing: spacing,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        _MenuOption(
          icon: Icons.help,
          title: 'Help & Support',
          textTheme: textTheme,
          spacing: spacing,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
          },
        ),
        _MenuOption(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          textTheme: textTheme,
          spacing: spacing,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            );
          },
        ),
        _MenuOption(
          icon: Icons.info,
          title: 'About',
          textTheme: textTheme,
          spacing: spacing,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutScreen(),
              ),
            );
          },
        ),
        SizedBox(height: spacing.lg),
        _MenuOption(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          textTheme: textTheme,
          spacing: spacing,
          onTap: () => _showDeleteAccountDialog(context, ref),
          isDestructive: true,
        ),
        _MenuOption(
          icon: Icons.logout,
          title: 'Logout',
          textTheme: textTheme,
          spacing: spacing,
          onTap: () => _showLogoutDialog(context, ref),
          isDestructive: true,
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
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
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

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final TextTheme textTheme;
  final ResponsiveSpacing spacing;

  const _MenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.textTheme,
    required this.spacing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing.sm),
      child: Material(
        color: Colors.white,
        borderRadius: Responsive.borderRadius(
          context,
          mobile: 12,
          tablet: 14,
          desktop: 16,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: Responsive.borderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
          child: Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              borderRadius: Responsive.borderRadius(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: context.responsive<double>(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    color: (isDestructive ? Colors.red : AppTheme.primaryOrange).withOpacity(0.1),
                    borderRadius: Responsive.borderRadius(
                      context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : AppTheme.primaryOrange,
                    size: Responsive.iconSize(
                      context,
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : AppTheme.darkGray,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.mediumGray,
                  size: Responsive.iconSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
