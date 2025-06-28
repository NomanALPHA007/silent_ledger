import 'package:flutter/material.dart';

import '../presentation/add_transaction_screen/add_transaction_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/user_dashboard_screen/user_dashboard_screen.dart';
import '../presentation/merchant_dashboard_screen/merchant_dashboard_screen.dart';
import '../presentation/admin_dashboard_screen/admin_dashboard_screen.dart';
import '../presentation/loan_eligibility_screen/loan_eligibility_screen.dart';
import '../presentation/email_verification_screen/email_verification_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/monetization_center_screen/monetization_center_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/password_reset_screen/password_reset_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/reports_screen/reports_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/transaction_list_screen/transaction_list_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String passwordResetScreen = '/password-reset-screen';
  static const String emailVerificationScreen = '/email-verification-screen';
  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String dashboardScreen = '/dashboard-screen';
  static const String userDashboardScreen = '/user-dashboard-screen';
  static const String merchantDashboardScreen = '/merchant-dashboard-screen';
  static const String adminDashboardScreen = '/admin-dashboard-screen';
  static const String loanEligibilityScreen = '/loan-eligibility-screen';
  static const String transactionListScreen = '/transaction-list-screen';
  static const String settingsScreen = '/settings-screen';
  static const String addTransactionScreen = '/add-transaction-screen';
  static const String reportsScreen = '/reports-screen';
  static const String monetizationCenterScreen = '/monetization-center-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    passwordResetScreen: (context) => const PasswordResetScreen(),
    emailVerificationScreen: (context) => const EmailVerificationScreen(),
    loginScreen: (context) => const LoginScreen(),
    registrationScreen: (context) => const RegistrationScreen(),
    dashboardScreen: (context) => const DashboardScreen(),
    userDashboardScreen: (context) => const UserDashboardScreen(),
    merchantDashboardScreen: (context) => const MerchantDashboardScreen(),
    adminDashboardScreen: (context) => const AdminDashboardScreen(),
    loanEligibilityScreen: (context) => const LoanEligibilityScreen(),
    transactionListScreen: (context) => const TransactionListScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    addTransactionScreen: (context) => const AddTransactionScreen(),
    reportsScreen: (context) => const ReportsScreen(),
    monetizationCenterScreen: (context) => const MonetizationCenterScreen(),
    // TODO: Add your other routes here
  };
}
