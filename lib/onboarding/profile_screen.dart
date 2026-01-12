import 'package:flutter/material.dart';
import '../core/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final first = TextEditingController();
  final last = TextEditingController();
  final exp = TextEditingController();

  bool driver = false, cook = false, maid = false;

  Future<void> submitProfile(String mobile) async {
    if (first.text.isEmpty || last.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter first name and last name')),
      );
      return;
    }

    final roles = [];
    if (driver) roles.add('driver');
    if (cook) roles.add('cook');
    if (maid) roles.add('maid');

    if (roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one role')),
      );
      return;
    }

    try {
      await ApiClient.dio.post(
        '/partner/profile',
        data: {
          "mobile_number": mobile,
          "first_name": first.text,
          "last_name": last.text,
          "experience": exp.text,
          "roles": roles,
        },
      );

      if (mounted) {
        Navigator.pushNamed(context, '/address', arguments: mobile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: first, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: last, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(
              controller: exp,
              decoration: const InputDecoration(labelText: 'Experience'),
              maxLines: 3,
            ),
            CheckboxListTile(title: const Text('Driver'), value: driver, onChanged: (v) => setState(() => driver = v!)),
            CheckboxListTile(title: const Text('Cook'), value: cook, onChanged: (v) => setState(() => cook = v!)),
            CheckboxListTile(title: const Text('Maid'), value: maid, onChanged: (v) => setState(() => maid = v!)),
            ElevatedButton(onPressed: () => submitProfile(mobile), child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}
