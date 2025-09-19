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
              
              _buildSection(
                'Information We Collect',
                'We collect information you provide directly to us, such as when you create an account, place an order, or contact us for support. This may include your name, email address, phone number, delivery address, and payment information.',
              ),
              
              _buildSection(
                'How We Use Your Information',
                'We use the information we collect to:\n\n• Process and fulfill your orders\n• Communicate with you about your orders and account\n• Provide customer support\n• Improve our services\n• Send you promotional communications (with your consent)\n• Comply with legal obligations',
              ),
              
              _buildSection(
                'Information Sharing',
                'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy. We may share your information with:\n\n• Delivery partners to fulfill your orders\n• Payment processors to handle transactions\n• Service providers who assist in our operations\n• Law enforcement when required by law',
              ),
              
              _buildSection(
                'Data Security',
                'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
              ),
              
              _buildSection(
                'Location Information',
                'We collect location information to provide delivery services. You can disable location services through your device settings, but this may affect app functionality.',
              ),
              
              _buildSection(
                'Cookies and Tracking',
                'We use cookies and similar technologies to enhance your experience, analyze usage, and provide personalized content. You can manage cookie preferences in your browser settings.',
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
                'Contact Us',
                'If you have any questions about this privacy policy or our data practices, please contact us at:\n\nEmail: privacy@nowdelivery.com\nPhone: +1 (555) 123-4567\nAddress: 123 Delivery Street, City, State 12345',
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
