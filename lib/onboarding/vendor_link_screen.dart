import 'package:flutter/material.dart';
import '../common/app_button.dart';

class VendorLinkScreen extends StatelessWidget {
  const VendorLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Vendor Code')),
            const SizedBox(height: 24),
            AppButton(
              text: 'Skip / Next',
              onTap: () => Navigator.pushNamed(context, '/kyc'),
            ),
          ],
        ),
      ),
    );
  }
}
