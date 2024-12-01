import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/file_model.dart';

class TorrentManagement {
    final String baseUrl = 'https://mymd.adamdienes.com';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const options = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock);

  Future<bool> sendTorrentRequest(String torrentId) async {
    try {
      final token = await _storage.read(key: 'jwt_token', iOptions: options);

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse("$baseUrl/documents/download"),
        headers: {
          'Content-Type': 'application/json',
          'authorization': token},
        body: json.encode({
          'id': torrentId
        }),
      );
      if(response.statusCode == 200) {
        _storage.write(key: 'credit_amount', value: json.decode(response.body)['credits'].toString(), iOptions: options);
        return true;
      }
      else {
        throw Exception('Error purchasing torrent');
      }
    } catch (error) {
      print('Error getting torrent: $error');
    }

    return false;
  }

  Future<bool> sendTorrentUploadRequest(String name, int size, String category, String magnetURL) async {
    try {
      final token = await _storage.read(key: 'jwt_token', iOptions: options);

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse("$baseUrl/documents/upload"),
        headers: {
          'Content-Type': 'application/json',
          'authorization': token},
        body: json.encode({
          'title': name,
          'size': size,
          'category': category,
          'magnet_link': magnetURL
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      else {
        throw Exception('Error uploading torrent');
      }
    } catch (error) {
      print('Error uploading torrent: $error');
    }
    return false;
  }

    Future<List<FileModel>> getTorrents() async {
      final token = await _storage.read(key: 'jwt_token', iOptions: options);

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/documents'),
        headers: {
          'authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('torrents') && decodedResponse['torrents'] is List) {
          final List<dynamic> torrents = decodedResponse['torrents'];
          return torrents.map((json) => FileModel.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load files. Code: ${response.statusCode}, Msg: ${response.body}. Token: $token');
      }
    }
}


