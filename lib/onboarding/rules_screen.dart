import 'package:flutter/material.dart';
import '../common/app_button.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Please follow platform rules'),
            const SizedBox(height: 24),
            AppButton(
              text: 'I Agree',
              onTap: () => Navigator.pushNamed(context, '/pending'),
            ),
          ],
        ),
      ),
    );
  }
}
