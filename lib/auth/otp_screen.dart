import 'package:flutter/material.dart';
import '../core/api_client.dart';
import 'package:dio/dio.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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
        await ApiClient.dio.post(
          '/auth/verify-otp',
          data: {
            "mobile_number": mobile,
            "otp": otpController.text,
          },
        );

        Navigator.pushReplacementNamed(context, '/profile',
            arguments: mobile);
      } on DioError catch (e) {
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
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : verifyOtp,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
