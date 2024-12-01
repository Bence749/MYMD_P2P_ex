import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/file_model.dart';
import '../services/torrent_management.dart';

class FileItem extends StatefulWidget {
  final FileModel initialFile;

  const FileItem({super.key, required this.initialFile});

  @override
  State<FileItem> createState() => _FileItemState();
}

class _FileItemState extends State<FileItem> with SingleTickerProviderStateMixin {
  late FileModel file;
  final TorrentManagement _torrentManagement = TorrentManagement();
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool _isLoading = false;
  bool _showTick = false;

  @override
  void initState() {
    super.initState();
    file = widget.initialFile;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: file.isPurchased ? Colors.greenAccent : Colors.redAccent,
      end: Colors.greenAccent,
    ).animate(_animationController);

    if (file.isPurchased) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendTorrentRequest(String id) async {
    setState(() {
      _isLoading = true;
    });

    bool successfulPurchase = await _torrentManagement.sendTorrentRequest(id);

    if (successfulPurchase) {
      List<FileModel> files = await _torrentManagement.getTorrents();
      setState(() {
        file = files.where((newFile) => newFile.id == file.id).toList().first;
        _isLoading = false;
        _showTick = true;
      });
      await _animationController.forward();
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _showTick = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon() {
    switch (file.category) {
      case 'Document':
        return Icons.description;
      case 'Archive':
        return Icons.archive;
      case 'Music':
        return Icons.music_note;
      case 'Image':
        return Icons.image;
      case 'Movie':
        return Icons.video_library;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _copyToClipboard(BuildContext context, String textToCopy) {
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copied successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildButtonChild() {
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          strokeWidth: 2,
        ),
      );
    } else if (_showTick) {
      return const Icon(Icons.check, color: Colors.green);
    } else {
      return Text(
        file.isPurchased ? 'Download (Click to copy link)' : 'Purchase',
        style: const TextStyle(color: Colors.black),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getCategoryIcon(), size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Size: ${file.size}'),
                  const SizedBox(height: 8),
                  Text('Uploaded: ${DateFormat('yyyy-MM-dd HH:mm').format(file.uploadDate)}'),
                  const SizedBox(height: 8),
                  Text('Category: ${file.category}'),
                  const SizedBox(height: 16,),
                  Text('ID: ${file.id}'),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return ElevatedButton(
                        onPressed: (_isLoading || _showTick) ? null : (file.isPurchased
                            ? () => _copyToClipboard(context, file.magnetLink)
                            : () async {
                          await _sendTorrentRequest(file.id);
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorAnimation.value,
                        ),
                        child: _buildButtonChild(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
