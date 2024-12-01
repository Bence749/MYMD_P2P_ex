import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class FileService {
  final String baseUrl = 'https://mymd.adamdienes.com';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const options = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock);

  Future<bool> register(BuildContext context, String username, String email,
      String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await _storage.write(key: 'jwt_token', value: data['token'], iOptions: options);
      await _storage.write(key: 'credit_amount', value: data['credits'].toString(), iOptions: options);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registering was successful!')));
      return true;
    }
    return false;
  }

  Future<bool> login(BuildContext context, String username,
      String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'jwt_token', value: data['token'], iOptions: options);
      await _storage.write(key: 'credit_amount', value: data['credits'].toString(), iOptions: options);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login was successful!')));
      return true;
    }
    return false;
  }
}
