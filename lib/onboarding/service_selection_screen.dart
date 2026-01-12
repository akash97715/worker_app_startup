import 'package:flutter/material.dart';
import '../common/app_button.dart';

class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Services')),
      body: Column(
        children: [
          CheckboxListTile(title: const Text('Maid'), value: true, onChanged: (_) {}),
          CheckboxListTile(title: const Text('Cook'), value: false, onChanged: (_) {}),
          CheckboxListTile(title: const Text('Driver'), value: false, onChanged: (_) {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              text: 'Next',
              onTap: () => Navigator.pushNamed(context, '/vendor'),
            ),
          ),
        ],
      ),
    );
  }
}
