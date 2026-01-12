import 'package:flutter/material.dart';
import '../core/api_client.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  String? errorMessage;
  bool loading = false;

  Future<void> checkAndSendOtp() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final checkResp = await ApiClient.dio.post(
        '/auth/check-mobile',
        data: {"mobile_number": phoneController.text},
      );

      if (checkResp.data['exists'] == true) {
        // User already registered, redirect to login
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Already Registered'),
              content: Text(checkResp.data['message'] ?? 'You are already registered. Please login.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacementNamed(context, '/partner-login');
                  },
                  child: const Text('Go to Login'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        }
        setState(() => loading = false);
        return;
      }

      await ApiClient.dio.post(
        '/auth/send-otp',
        data: {"mobile_number": phoneController.text},
      );

      Navigator.pushNamed(
        context,
        '/otp',
        arguments: phoneController.text,
      );
    } on DioError catch (e) {
      setState(() {
        errorMessage =
            e.response?.data['detail'] ?? 'Something went wrong';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Partner')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : checkAndSendOtp,
              child:
                  loading ? const CircularProgressIndicator() : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
