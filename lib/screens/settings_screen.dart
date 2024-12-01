import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:p2p_exam/main.dart';

class SettingsScreen extends StatelessWidget {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final options = const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  const SettingsScreen({super.key});

  void _restartApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MyApp(null)),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            subtitle: const Text('Log out of your account'),
            onTap: () {
              _storage.delete(key: 'jwt_token', iOptions: options);
              _storage.delete(key: 'credit_amount', iOptions: options);
              _restartApp(context);
            },
          )
        ],
      ),
    );
  }
}
