import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'auth/login_screen.dart';
import 'auth/otp_screen.dart';
import 'auth/partner_login_screen.dart';
import 'auth/partner_otp_screen.dart';
import 'onboarding/profile_screen.dart';
import 'onboarding/address_screen.dart';
import 'kyc/upload_document_screen.dart';
import 'onboarding/pending_verification_screen.dart';
import 'home/status_screen.dart';
import 'partner/dashboard_screen.dart';
import 'partner/completed_services_screen.dart';

class WorkerApp extends StatelessWidget {
  const WorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MetroEasy Partner',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeLandingScreen(),
        '/login': (_) => const LoginScreen(),
        '/otp': (_) => const OtpScreen(),
        '/partner-login': (_) => const PartnerLoginScreen(),
        '/partner-otp': (_) => const PartnerOtpScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/completed-services': (_) => const CompletedServicesScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/address': (_) => const AddressScreen(),
        '/kyc': (_) => const UploadDocumentScreen(),
        '/pending': (_) => const PendingVerificationScreen(),
        '/status': (_) => const StatusScreen(),
      },
    );
  }
}
