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
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.mediumGray,
                ),
              ),
              const SizedBox(height: 24),
              
              // B2B Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business_center, color: AppTheme.primaryOrange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This privacy policy applies to our B2B (Business-to-Business) logistics platform for business users.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSection(
                'Information We Collect',
                'We collect information you provide directly to us when you register your business account, manage delivery orders, or contact us for support. This may include:\n\n• Business name and contact information\n• Representative name, email address, and phone number\n• Business delivery addresses and locations\n• Order and delivery tracking information\n• Profile pictures (stored locally on your device)\n\nNote: All payment and subscription information is collected and processed through our website (nowshipping.co), not through this mobile application.',
              ),
              
              _buildSection(
                'How We Use Your Information',
                'We use the information we collect to:\n\n• Process and manage your delivery orders\n• Communicate with you about your orders and business account\n• Provide customer support and technical assistance\n• Improve our logistics platform and services\n• Send you business updates and service notifications\n• Comply with legal and regulatory obligations\n• Validate your subscription tier and feature access',
              ),
              
              _buildSection(
                'Payment Information',
                'IMPORTANT: This mobile application does NOT process any payments or collect payment information.\n\nAll subscription payments and billing are handled exclusively through our website at nowshipping.co. Your payment details are processed by secure third-party payment processors on our website and are never transmitted through or stored in this mobile application.\n\nThis app only validates your subscription status via secure API calls to determine which features you can access.',
              ),
              
              _buildSection(
                'Information Sharing',
                'We do not sell, trade, or otherwise transfer your business information to third parties without your consent, except as described in this policy. We may share your information with:\n\n• Courier partners to fulfill delivery orders\n• Cloud service providers for data hosting (AWS, Google Cloud)\n• Analytics providers to improve our services\n• Service providers who assist in our operations\n• Law enforcement when required by law\n\nNote: Payment processing is handled by our website payment processors, not through this app.',
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
                'Your Rights',
                'You have the right to:\n\n• Access your personal information\n• Correct inaccurate information\n• Delete your account and data\n• Opt out of promotional communications\n• Request data portability\n• Withdraw consent where applicable',
              ),
              
              _buildSection(
                'Data Retention',
                'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. You can request deletion of your account and data at any time.',
              ),
              
              _buildSection(
                'Children\'s Privacy',
                'Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13. If you become aware that a child has provided us with personal information, please contact us.',
              ),
              
              _buildSection(
                'International Data Transfers',
                'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your information.',
              ),
              
              _buildSection(
                'Changes to This Policy',
                'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.',
              ),
              
              _buildSection(
                'Business User Data',
                'As a B2B application, the data we collect is primarily business-related information for logistics operations. Personal data of individual users (names, emails, phone numbers) is collected only as necessary to identify business representatives and provide account access.\n\nIf you are using this app on behalf of a business, you confirm that you have the authority to provide business information and agree to these terms on behalf of your organization.',
              ),
              
              _buildSection(
                'Contact Us',
                'If you have any questions about this privacy policy or our data practices, please contact us at:\n\nWebsite: https://nowshipping.co\nEmail: support@nowshipping.co\nPrivacy Email: privacy@nowshipping.co\n\nFor subscription or billing questions, please visit our website as all payment matters are handled there.',
              ),
              
              const SizedBox(height: 32),
              
              // Consent Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Processing Consent',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'By using Now Delivery, you consent to the collection and processing of your personal information as described in this privacy policy.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.darkGray,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
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
