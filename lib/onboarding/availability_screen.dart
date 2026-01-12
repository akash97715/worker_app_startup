import 'package:flutter/material.dart';
import '../common/app_button.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: Column(
        children: [
          RadioListTile(title: const Text('Full Day'), value: 1, groupValue: 1, onChanged: (_) {}),
          RadioListTile(title: const Text('Morning'), value: 2, groupValue: 1, onChanged: (_) {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              text: 'Next',
              onTap: () => Navigator.pushNamed(context, '/rules'),
            ),
          ),
        ],
      ),
    );
  }
}
