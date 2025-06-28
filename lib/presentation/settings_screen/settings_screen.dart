import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_toggle_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock user data
  final Map<String, dynamic> userData = {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "emailVerified": true,
    "subscriptionType": "Premium",
    "profileImage":
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
  };

  // Settings state
  bool biometricEnabled = true;
  bool twoFactorEnabled = false;
  bool transactionAlerts = true;
  bool securityNotifications = true;
  bool weeklyReports = false;
  bool budgetReminders = true;
  bool analyticsEnabled = false;
  String selectedCurrency = "USD";
  String selectedDateFormat = "MM/DD/YYYY";
  String selectedNumberFormat = "1,000.00";
  String selectedTheme = "System";
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildProfileHeader(),
            SizedBox(height: 3.h),
            _buildSecuritySection(),
            SizedBox(height: 2.h),
            _buildPrivacySection(),
            SizedBox(height: 2.h),
            _buildAppPreferencesSection(),
            SizedBox(height: 2.h),
            _buildNotificationSection(),
            SizedBox(height: 2.h),
            _buildAccountSection(),
            SizedBox(height: 2.h),
            _buildDangerZone(),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: userData["profileImage"] as String,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData["name"] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      userData["email"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 2.w),
                    userData["emailVerified"] == true
                        ? CustomIconWidget(
                            iconName: 'verified',
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            size: 16,
                          )
                        : Container(),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    userData["subscriptionType"] as String,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'edit',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return SettingsSectionWidget(
      title: 'Security',
      children: [
        SettingsToggleWidget(
          title: 'Biometric Authentication',
          subtitle: 'Use fingerprint or face ID to unlock',
          value: biometricEnabled,
          onChanged: (value) {
            setState(() {
              biometricEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'fingerprint',
        ),
        SettingsItemWidget(
          title: 'Change Password',
          subtitle: 'Update your account password',
          iconName: 'lock',
          onTap: () => _showChangePasswordDialog(),
        ),
        SettingsToggleWidget(
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security',
          value: twoFactorEnabled,
          onChanged: (value) {
            setState(() {
              twoFactorEnabled = value;
            });
            HapticFeedback.lightImpact();
            if (value) {
              _showTwoFactorSetupDialog();
            }
          },
          iconName: 'security',
        ),
        SettingsItemWidget(
          title: 'Session Management',
          subtitle: 'Manage active sessions',
          iconName: 'devices',
          onTap: () => _showSessionManagementDialog(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return SettingsSectionWidget(
      title: 'Privacy',
      children: [
        SettingsItemWidget(
          title: 'Data Export',
          subtitle: 'Download your data as encrypted file',
          iconName: 'download',
          onTap: () => _exportData(),
        ),
        SettingsToggleWidget(
          title: 'Analytics Preferences',
          subtitle: 'Help improve the app with usage data',
          value: analyticsEnabled,
          onChanged: (value) {
            setState(() {
              analyticsEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'analytics',
        ),
        SettingsItemWidget(
          title: 'Local Storage Management',
          subtitle: 'Manage cached data and storage',
          iconName: 'storage',
          onTap: () => _showStorageManagementDialog(),
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection() {
    return SettingsSectionWidget(
      title: 'App Preferences',
      children: [
        SettingsItemWidget(
          title: 'Currency Selection',
          subtitle: selectedCurrency,
          iconName: 'attach_money',
          onTap: () => _showCurrencySelector(),
        ),
        SettingsItemWidget(
          title: 'Date Format',
          subtitle: selectedDateFormat,
          iconName: 'calendar_today',
          onTap: () => _showDateFormatSelector(),
        ),
        SettingsItemWidget(
          title: 'Number Format',
          subtitle: selectedNumberFormat,
          iconName: 'format_list_numbered',
          onTap: () => _showNumberFormatSelector(),
        ),
        SettingsItemWidget(
          title: 'Theme Selection',
          subtitle: selectedTheme,
          iconName: 'palette',
          onTap: () => _showThemeSelector(),
        ),
        SettingsItemWidget(
          title: 'Language Settings',
          subtitle: selectedLanguage,
          iconName: 'language',
          onTap: () => _showLanguageSelector(),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return SettingsSectionWidget(
      title: 'Notifications',
      children: [
        SettingsToggleWidget(
          title: 'Transaction Alerts',
          subtitle: 'Get notified of new transactions',
          value: transactionAlerts,
          onChanged: (value) {
            setState(() {
              transactionAlerts = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'notifications',
        ),
        SettingsToggleWidget(
          title: 'Security Notifications',
          subtitle: 'Important security updates',
          value: securityNotifications,
          onChanged: (value) {
            setState(() {
              securityNotifications = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'security',
        ),
        SettingsToggleWidget(
          title: 'Weekly Reports',
          subtitle: 'Summary of your financial activity',
          value: weeklyReports,
          onChanged: (value) {
            setState(() {
              weeklyReports = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'assessment',
        ),
        SettingsToggleWidget(
          title: 'Budget Reminders',
          subtitle: 'Alerts when approaching budget limits',
          value: budgetReminders,
          onChanged: (value) {
            setState(() {
              budgetReminders = value;
            });
            HapticFeedback.lightImpact();
          },
          iconName: 'account_balance_wallet',
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return SettingsSectionWidget(
      title: 'Account',
      children: [
        SettingsItemWidget(
          title: 'Profile Information',
          subtitle: 'Update your personal details',
          iconName: 'person',
          onTap: () => Navigator.pushNamed(context, '/profile-screen'),
        ),
        SettingsItemWidget(
          title: 'Email Verification',
          subtitle: userData["emailVerified"] == true
              ? 'Verified'
              : 'Pending verification',
          iconName: 'email',
          onTap: () =>
              Navigator.pushNamed(context, '/email-verification-screen'),
          trailing: userData["emailVerified"] == true
              ? CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 20,
                )
              : CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.warningLight,
                  size: 20,
                ),
        ),
        SettingsItemWidget(
          title: 'Linked Accounts',
          subtitle: 'Manage connected bank accounts',
          iconName: 'account_balance',
          onTap: () => _showLinkedAccountsDialog(),
        ),
        SettingsItemWidget(
          title: 'Subscription Details',
          subtitle: 'Manage your subscription',
          iconName: 'card_membership',
          onTap: () => _showSubscriptionDialog(),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return SettingsSectionWidget(
      title: 'Danger Zone',
      children: [
        SettingsItemWidget(
          title: 'Sign Out',
          subtitle: 'Sign out from this device',
          iconName: 'logout',
          onTap: () => _showSignOutDialog(),
          isDestructive: true,
        ),
        SettingsItemWidget(
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          iconName: 'delete_forever',
          onTap: () => _showDeleteAccountDialog(),
          isDestructive: true,
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Text('This will redirect you to the password change screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/password-reset-screen');
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Two-Factor Authentication'),
        content: Text(
            'Setting up 2FA will require you to use an authenticator app or SMS verification.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                twoFactorEnabled = false;
              });
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Setup'),
          ),
        ],
      ),
    );
  }

  void _showSessionManagementDialog() {
    final List<Map<String, dynamic>> sessions = [
      {
        "device": "iPhone 14 Pro",
        "location": "New York, NY",
        "lastActive": "Active now",
        "current": true,
      },
      {
        "device": "MacBook Pro",
        "location": "New York, NY",
        "lastActive": "2 hours ago",
        "current": false,
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Active Sessions'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (sessions as List).map((session) {
              final sessionMap = session as Map<String, dynamic>;
              return ListTile(
                leading: CustomIconWidget(
                  iconName:
                      sessionMap["current"] == true ? 'smartphone' : 'laptop',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(sessionMap["device"] as String),
                subtitle: Text(
                    '${sessionMap["location"]} • ${sessionMap["lastActive"]}'),
                trailing: sessionMap["current"] == true
                    ? Chip(
                        label: Text('Current'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.tertiaryContainer,
                      )
                    : TextButton(
                        onPressed: () {},
                        child: Text('Revoke'),
                      ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: Text(
            'Your data will be exported as an encrypted file. This may take a few moments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Data export started. You will be notified when ready.'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              );
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showStorageManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Cache Size'),
              subtitle: Text('45.2 MB'),
              trailing: TextButton(
                onPressed: () {},
                child: Text('Clear'),
              ),
            ),
            ListTile(
              title: Text('Offline Data'),
              subtitle: Text('128.5 MB'),
              trailing: TextButton(
                onPressed: () {},
                child: Text('Manage'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCurrencySelector() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Currency'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) {
              return RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showDateFormatSelector() {
    final formats = ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Date Format'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: formats.map((format) {
              return RadioListTile<String>(
                title: Text(format),
                value: format,
                groupValue: selectedDateFormat,
                onChanged: (value) {
                  setState(() {
                    selectedDateFormat = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showNumberFormatSelector() {
    final formats = ['1,000.00', '1.000,00', '1 000.00'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Number Format'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: formats.map((format) {
              return RadioListTile<String>(
                title: Text(format),
                value: format,
                groupValue: selectedNumberFormat,
                onChanged: (value) {
                  setState(() {
                    selectedNumberFormat = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showThemeSelector() {
    final themes = ['Light', 'Dark', 'System'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Theme'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: themes.map((theme) {
              return RadioListTile<String>(
                title: Text(theme),
                value: theme,
                groupValue: selectedTheme,
                onChanged: (value) {
                  setState(() {
                    selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLinkedAccountsDialog() {
    final List<Map<String, dynamic>> accounts = [
      {
        "bankName": "Chase Bank",
        "accountType": "Checking",
        "lastFour": "1234",
        "connected": true,
      },
      {
        "bankName": "Bank of America",
        "accountType": "Savings",
        "lastFour": "5678",
        "connected": false,
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Linked Accounts'),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (accounts as List).map((account) {
              final accountMap = account as Map<String, dynamic>;
              return ListTile(
                leading: CustomIconWidget(
                  iconName: 'account_balance',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(accountMap["bankName"] as String),
                subtitle: Text(
                    '${accountMap["accountType"]} •••• ${accountMap["lastFour"]}'),
                trailing: accountMap["connected"] == true
                    ? CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        size: 20,
                      )
                    : TextButton(
                        onPressed: () {},
                        child: Text('Connect'),
                      ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Add Account'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscription Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Plan: ${userData["subscriptionType"]}'),
            SizedBox(height: 1.h),
            Text('Next Billing: January 15, 2024'),
            SizedBox(height: 1.h),
            Text('Amount: \$9.99/month'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Manage'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text(
            'Are you sure you want to sign out? You will need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Final Confirmation',
          style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Type "DELETE" to confirm account deletion:'),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Account deletion initiated. You will receive a confirmation email.'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}
