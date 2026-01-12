import 'package:flutter/material.dart';
import '../core/api_client.dart';
import 'package:dio/dio.dart';

class PartnerOtpScreen extends StatefulWidget {
  const PartnerOtpScreen({super.key});

  @override
  State<PartnerOtpScreen> createState() => _PartnerOtpScreenState();
}

class _PartnerOtpScreenState extends State<PartnerOtpScreen> {
  final otpController = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final mobile = ModalRoute.of(context)!.settings.arguments as String;

    Future<void> verifyOtp() async {
      setState(() {
        loading = true;
        error = null;
      });

      try {
        final response = await ApiClient.dio.post(
          '/auth/login/verify-otp',
          data: {
            "mobile_number": mobile,
            "otp": otpController.text,
          },
        );

        // Store partner info
        final partnerId = response.data['partner_id'];
        final status = response.data['status'];
        final serviceStatus = response.data['service_status'];

        // Navigate to dashboard
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {
            'mobile': mobile,
            'partner_id': partnerId,
            'status': status,
            'service_status': serviceStatus,
          },
        );
      } on DioException catch (e) {
        setState(() {
          error = e.response?.data['detail'] ?? 'Invalid OTP';
        });
      } finally {
        setState(() => loading = false);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'OTP sent to $mobile',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
                hintText: 'Enter 4 digit OTP',
              ),
              maxLength: 4,
            ),
            const SizedBox(height: 8),
            const Text(
              'Master OTP: 5555 (for testing)',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Verify & Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Change Mobile Number'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}
