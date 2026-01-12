import 'package:flutter/material.dart';
import '../core/api_client.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  String status = 'approved';

  Future<void> loadStatus(String mobile) async {
    final resp = await ApiClient.dio.get(
      '/partner/status',
      queryParameters: {"mobile_number": mobile},
    );
    setState(() => status = resp.data['status']);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = ModalRoute.of(context)!.settings.arguments as String?;

    if (mobile != null && status == 'loading') {
      loadStatus(mobile);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Application Status')),
      body: Center(
        child: Text(
          status.toUpperCase(),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
