import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_theme.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'About',
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
            // App Info Section
            Container(
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
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Now Delivery',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.5 (Build 6)',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Business-to-Business Logistics Platform',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Now Delivery is a comprehensive shipping and delivery management solution for businesses. Manage orders, track deliveries, schedule pickups, and monitor your logistics operations all in one place.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.mediumGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Business Model Notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withOpacity(0.1),
                    AppTheme.primaryOrange.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business_center,
                        color: AppTheme.primaryOrange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Business Application',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This is a B2B (Business-to-Business) application designed exclusively for business users managing delivery and logistics operations.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.darkGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.web, 'Subscriptions managed at nowshipping.co'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.block, 'No in-app purchases or payments'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.devices, 'Multi-platform enterprise system'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Section
            _InfoSection(
              title: 'Contact Information',
              children: [
                _InfoTile(
                  icon: Icons.language,
                  title: 'Website',
                  subtitle: 'nowshipping.co',
                  onTap: () => _launchURL('https://nowshipping.co'),
                ),
                _InfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'support@nowshipping.co',
                  onTap: () => _launchEmail('support@nowshipping.co'),
                ),
                _InfoTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Customer Support',
                  subtitle: 'Get help with your account',
                  onTap: () => _launchEmail('support@nowshipping.co'),
                ),
              ],
            ),
            const SizedBox(height: 24),


            // Legal Section
            _InfoSection(
              title: 'Legal',
              children: [
                _InfoTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'View our terms and conditions',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                ),
                _InfoTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we protect your data',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                _InfoTile(
                  icon: Icons.gavel_outlined,
                  title: 'Licenses',
                  subtitle: 'Open source licenses',
                  onTap: () => _showLicensesDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Credits Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                children: [
                  Text(
                    'Made with ❤️ by the Now Delivery Team',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 Now Shipping. All rights reserved.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryOrange),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.darkGray,
            ),
          ),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _showLicensesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Open Source Licenses',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGray,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'This app uses the following open source packages:\n\n'
            '• Flutter - Google Inc.\n'
            '• flutter_riverpod - Remi Rousselet\n'
            '• google_fonts - Google Inc.\n'
            '• shared_preferences - Flutter Team\n'
            '• url_launcher - Flutter Team\n'
            '• And many more...\n\n'
            'Full license information can be found in the app settings.',
            style: GoogleFonts.inter(
              color: AppTheme.mediumGray,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.mediumGray,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
