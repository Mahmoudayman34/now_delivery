import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
              Text(
                'Privacy Policy',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSection(
                'Information We Collect',
                'We collect information you provide directly to us when you register your business account, manage delivery orders, or contact us for support. This may include:\n\n• Business name and contact information\n• Representative name, email address, and phone number\n• Business delivery addresses and locations\n• Order and delivery tracking information\n• Profile pictures (stored locally on your device)',
              ),
              
              
              _buildSection(
                'Data Security',
                'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
              ),
              
              _buildSection(
                'Location Information',
                'We collect and use location information to:\n\n• Display delivery locations on maps\n• Calculate delivery routes and distances\n• Provide real-time order tracking\n• Validate delivery addresses\n\nLocation services are essential for the core functionality of this logistics platform. You can disable location permissions through your device settings, but this will significantly limit app functionality.\n\nLocation data is transmitted via secure HTTPS connections and is only used for delivery management purposes.',
              ),
              
              _buildSection(
                'Camera and Photo Library Access',
                'The app requests camera and photo library permissions to allow you to:\n\n• Take or upload a profile picture\n• Capture delivery documentation (if applicable)\n\nYou can deny these permissions and still use the app\'s core delivery management features. Profile pictures are stored locally on your device and optionally synced to our servers if you choose to upload them.\n\nWe will always request permission before accessing your camera or photo library, as required by iOS guidelines.',
              ),
              
              _buildSection(
                'Cookies and Tracking',
                'This mobile application uses minimal tracking:\n\n• Session authentication tokens (JWT)\n• User preferences stored locally\n• Anonymous usage analytics (optional)\n\nWe do not use third-party advertising trackers or sell your data to advertisers. Analytics data is used solely to improve our service quality and user experience.',
              ),
              
              _buildSection(
                'Data Retention',
                'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. You can request deletion of your account and data at any time.',
              ),
              
            
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.mediumGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
