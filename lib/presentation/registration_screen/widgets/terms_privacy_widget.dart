import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TermsPrivacyWidget extends StatelessWidget {
  final bool acceptTerms;
  final ValueChanged<bool?> onTermsChanged;

  const TermsPrivacyWidget({
    super.key,
    required this.acceptTerms,
    required this.onTermsChanged,
  });

  void _showTermsOfService(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(5.w),
        ),
      ),
      builder: (context) =>
          _buildTermsModal(context, 'Terms of Service', _getTermsContent()),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(5.w),
        ),
      ),
      builder: (context) =>
          _buildTermsModal(context, 'Privacy Policy', _getPrivacyContent()),
    );
  }

  Widget _buildTermsModal(BuildContext context, String title, String content) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 12.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                content,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Close button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  String _getTermsContent() {
    return '''
TERMS OF SERVICE

Last updated: ${DateTime.now().year}

1. ACCEPTANCE OF TERMS
By accessing and using Silent Ledger ("the App"), you accept and agree to be bound by the terms and provision of this agreement.

2. DESCRIPTION OF SERVICE
Silent Ledger is a financial management application that provides secure, private financial tracking and ledger management capabilities on mobile devices.

3. USER ACCOUNTS
- You must provide accurate and complete information when creating an account
- You are responsible for maintaining the confidentiality of your account credentials
- You agree to notify us immediately of any unauthorized use of your account

4. PRIVACY AND DATA SECURITY
- We prioritize your data privacy and security
- Your financial data is encrypted and stored securely
- We do not share your personal financial information with third parties without your consent

5. ACCEPTABLE USE
You agree not to:
- Use the App for any illegal or unauthorized purpose
- Attempt to gain unauthorized access to our systems
- Interfere with or disrupt the App's functionality

6. LIMITATION OF LIABILITY
Silent Ledger shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the App.

7. MODIFICATIONS
We reserve the right to modify these terms at any time. Continued use of the App constitutes acceptance of modified terms.

8. TERMINATION
We may terminate or suspend your account at any time for violations of these terms.

9. GOVERNING LAW
These terms shall be governed by and construed in accordance with applicable laws.

10. CONTACT INFORMATION
For questions about these Terms of Service, please contact us through the App's support section.
''';
  }

  String _getPrivacyContent() {
    return '''
PRIVACY POLICY

Last updated: ${DateTime.now().year}

1. INFORMATION WE COLLECT
- Account information (email, encrypted password)
- Financial transaction data you input
- Device information for security purposes
- Usage analytics to improve the App

2. HOW WE USE YOUR INFORMATION
- To provide and maintain the App's functionality
- To secure your account and prevent fraud
- To improve our services and user experience
- To communicate important updates

3. DATA STORAGE AND SECURITY
- All financial data is encrypted using industry-standard encryption
- Data is stored securely on your device and our protected servers
- We implement multiple layers of security to protect your information
- Biometric authentication adds an extra layer of protection

4. DATA SHARING
We do not sell, trade, or share your personal financial information with third parties, except:
- When required by law
- To protect our rights and safety
- With your explicit consent

5. YOUR RIGHTS
You have the right to:
- Access your personal data
- Correct inaccurate information
- Delete your account and associated data
- Export your financial data

6. COOKIES AND TRACKING
- We use minimal tracking for essential App functionality
- No advertising cookies or third-party trackers are used
- You can control cookie preferences in your device settings

7. DATA RETENTION
- We retain your data only as long as necessary to provide services
- You can request data deletion at any time
- Some data may be retained for legal compliance

8. CHILDREN'S PRIVACY
Silent Ledger is not intended for users under 18 years of age. We do not knowingly collect information from children.

9. INTERNATIONAL TRANSFERS
Your data may be transferred to and processed in countries other than your own, with appropriate safeguards in place.

10. CHANGES TO PRIVACY POLICY
We will notify you of any material changes to this Privacy Policy through the App or email.

11. CONTACT US
For privacy-related questions or concerns, please contact us through the App's support section.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 6.w,
          height: 6.w,
          child: Checkbox(
            value: acceptTerms,
            onChanged: onTermsChanged,
            activeColor: AppTheme.lightTheme.primaryColor,
            checkColor: AppTheme.lightTheme.colorScheme.onPrimary,
            side: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => _showTermsOfService(context),
                    child: Text(
                      'Terms of Service',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' and '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => _showPrivacyPolicy(context),
                    child: Text(
                      'Privacy Policy',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const TextSpan(
                    text:
                        '. I understand that my financial data will be encrypted and stored securely.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
