import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/file_model.dart';
import '../widgets/file_item.dart';
import '../services/torrent_management.dart';

class FileListScreen extends StatefulWidget {
  const FileListScreen({super.key});

  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  final TorrentManagement _torrentManagement = TorrentManagement();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const options = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock
  );

  List<FileModel> _files = [];
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _size = 0;
  String _category = 'Movie';
  String _userCredit = '0';
  late Timer _creditUpdateTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _creditUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _loadUserCredit());
  }

  @override
  void dispose() {
    _creditUpdateTimer.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadFiles();
    await _loadUserCredit();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFiles() async {
    final files = await _torrentManagement.getTorrents();
    setState(() {
      _files = files;
    });
  }

  Future<void> _loadUserCredit() async {
    String? credit = await _storage.read(key: 'credit_amount', iOptions: options);
    setState(() {
      _userCredit = credit ?? '0';
    });
  }

  void _showUploadForm() {
    String _magnetLink = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload New File'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Size (MB)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a size';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _size = int.parse(value!);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: <String>['Movie', 'Music', 'Document', 'Archive', 'Image']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _category = newValue!;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Magnet Link'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a magnet link';
                      }
                      if (!value.startsWith('magnet:')) {
                        return 'Please enter a valid magnet link';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _magnetLink = value!;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Upload'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  bool uploadSuccess = await TorrentManagement().sendTorrentUploadRequest(_name, _size, _category, _magnetLink);
                  if (uploadSuccess) {
                    Navigator.of(context).pop();
                    await _loadInitialData();
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Failed to upload file. Please try again.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreditDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_circle_down_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            _userCredit,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File List'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildCreditDisplay(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadInitialData,
        child: ListView.builder(
          itemCount: _files.length,
          itemBuilder: (context, index) {
            return FileItem(initialFile: _files[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadForm,
        tooltip: 'Upload File',
        child: const Icon(Icons.add),
      ),
    );
  }
}
