import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Terms of Service',
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
                'Terms of Service',
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
                'Acceptance of Terms',
                'By accessing and using Now Delivery ("the Service"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
              ),
              
              _buildSection(
                'Description of Service',
                'Now Delivery is a food and goods delivery platform that connects customers with local restaurants and stores. We facilitate orders and coordinate delivery through our network of delivery partners.',
              ),
              
              _buildSection(
                'User Accounts',
                'To use our Service, you must:\n\n• Be at least 18 years old or have parental consent\n• Provide accurate and complete registration information\n• Maintain the security of your account credentials\n• Accept responsibility for all activities under your account\n• Notify us immediately of any unauthorized use',
              ),
              
              _buildSection(
                'Orders and Payments',
                'When you place an order:\n\n• You are making an offer to purchase items at the listed prices\n• Orders are subject to acceptance by the merchant\n• Prices include applicable taxes and fees\n• Payment is processed when the order is confirmed\n• You are responsible for providing accurate delivery information',
              ),
              
              _buildSection(
                'Delivery Terms',
                'Regarding delivery services:\n\n• Delivery times are estimates and may vary\n• We are not responsible for delays beyond our control\n• You must be available to receive your order\n• Additional fees may apply for failed delivery attempts\n• Special delivery instructions should be provided when ordering',
              ),
              
              _buildSection(
                'Cancellations and Refunds',
                'Order modifications and cancellations:\n\n• Orders may be cancelled within 5 minutes of placement\n• Refunds are processed according to our refund policy\n• We reserve the right to cancel orders in certain circumstances\n• Partial refunds may apply for partially fulfilled orders',
              ),
              
              _buildSection(
                'User Conduct',
                'You agree not to:\n\n• Use the Service for any unlawful purpose\n• Interfere with or disrupt the Service\n• Attempt to gain unauthorized access to our systems\n• Harass or abuse our delivery partners or support staff\n• Provide false or misleading information',
              ),
              
              _buildSection(
                'Intellectual Property',
                'The Service and its content are protected by intellectual property laws. You may not:\n\n• Copy, modify, or distribute our content without permission\n• Use our trademarks or logos without authorization\n• Reverse engineer or attempt to extract source code\n• Create derivative works based on our Service',
              ),
              
              _buildSection(
                'Privacy and Data',
                'Your privacy is important to us:\n\n• We collect and use data as described in our Privacy Policy\n• You consent to data processing for service provision\n• We implement security measures to protect your information\n• You may request access to or deletion of your data',
              ),
              
              _buildSection(
                'Limitation of Liability',
                'To the maximum extent permitted by law:\n\n• We provide the Service "as is" without warranties\n• We are not liable for indirect or consequential damages\n• Our liability is limited to the amount you paid for the Service\n• We are not responsible for third-party merchant actions',
              ),
              
              _buildSection(
                'Termination',
                'Either party may terminate this agreement:\n\n• You may close your account at any time\n• We may suspend or terminate accounts for violations\n• Termination does not affect existing orders or obligations\n• Certain provisions survive termination',
              ),
              
              _buildSection(
                'Changes to Terms',
                'We reserve the right to modify these terms:\n\n• Changes will be posted with an updated date\n• Continued use constitutes acceptance of new terms\n• Material changes may require additional consent\n• You may terminate your account if you disagree with changes',
              ),
              
              _buildSection(
                'Governing Law',
                'These terms are governed by the laws of the jurisdiction where Now Delivery operates. Any disputes will be resolved through binding arbitration or in courts of competent jurisdiction.',
              ),
              
              _buildSection(
                'Contact Information',
                'For questions about these terms, contact us at:\n\nEmail: legal@nowdelivery.com\nPhone: +1 (555) 123-4567\nAddress: 123 Delivery Street, San Francisco, CA 94105',
              ),
              
              const SizedBox(height: 32),
              
              // Acceptance Section
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
                      'Agreement Acknowledgment',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'By using Now Delivery, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
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
