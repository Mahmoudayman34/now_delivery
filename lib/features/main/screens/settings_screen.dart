import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../theme/app_theme.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _locationServices = true;
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _checkLocationPermission();
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('settings_push_notifications') ?? true;
      _emailNotifications = prefs.getBool('settings_email_notifications') ?? false;
      _locationServices = prefs.getBool('settings_location_services') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _checkLocationPermission() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    setState(() {
      _locationServices = serviceEnabled && 
                         (permission == LocationPermission.always || 
                          permission == LocationPermission.whileInUse);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Settings',
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
          children: [
            // Notifications Section
            _SettingsSection(
              title: 'Notifications',
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive order updates and promotions',
                  trailing: Switch(
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                      _savePreference('settings_push_notifications', value);
                    },
                    activeColor: AppTheme.primaryOrange,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Get updates via email',
                  trailing: Switch(
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                      _savePreference('settings_email_notifications', value);
                    },
                    activeColor: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // App Preferences Section
            _SettingsSection(
              title: 'App Preferences',
              children: [
                _SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location Services',
                  subtitle: 'Allow app to access your location',
                  trailing: Switch(
                    value: _locationServices,
                    onChanged: (value) async {
                      if (value) {
                        // User wants to enable location - request permission
                        await _requestLocationPermission();
                      } else {
                        // User wants to disable - show dialog to open settings
                        await _showOpenSettingsDialog();
                      }
                    },
                    activeColor: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account Section
            _SettingsSection(
              title: 'Account',
              children: [
                _SettingsTile(
                  icon: Icons.security_outlined,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.mediumGray,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      final LocationPermission requestResult = await Geolocator.requestPermission();
      
      if (requestResult == LocationPermission.whileInUse || 
          requestResult == LocationPermission.always) {
        setState(() {
          _locationServices = true;
        });
        await _savePreference('settings_location_services', true);
      } else {
        setState(() {
          _locationServices = false;
        });
      }
    } else if (permission == LocationPermission.deniedForever) {
      // Permission denied forever - show dialog to open settings
      await _showOpenSettingsDialog();
    } else {
      // Already has permission
      setState(() {
        _locationServices = true;
      });
      await _savePreference('settings_location_services', true);
    }
  }

  Future<void> _showOpenSettingsDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Location Permission',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGray,
          ),
        ),
        content: Text(
          'To change location permissions, please open the app settings and enable location access.',
          style: GoogleFonts.inter(color: AppTheme.mediumGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Open Settings',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await openAppSettings();
      // Recheck permission after returning from settings
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkLocationPermission();
    }
  }

}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
