import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const FlutterSecureStorage _storage = FlutterSecureStorage();
  const options = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock);

  final token = await _storage.read(key: 'jwt_token', iOptions: options);

  runApp(MyApp(token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp(this.token, {super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: token == null ? '/auth' : '/home',
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
