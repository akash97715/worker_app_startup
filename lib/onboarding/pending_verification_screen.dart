import 'package:flutter/material.dart';

class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // disable back
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pushReplacementNamed(context, '/status');
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.sentiment_satisfied_alt,
                      size: 80, color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'Thank you for choosing MetroEasy 🙂',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Aap se jaldi sampark kiya jayega.\nYou will hear back shortly.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap anywhere to continue',
                    style: TextStyle(color: Colors.black45),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
