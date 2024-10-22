import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibra_app/models/message.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String searchQuery;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.searchQuery,
  });

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  Future<void> _downloadFile(String url, BuildContext context) async {
    try {
      Dio dio = Dio();
      String filename = url.split('/').last;
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = '${appDocDir.path}/$filename';

      await dio.download(url, savePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File scaricato in: $savePath')),
      );
    } catch (e) {
      print('Errore nel download: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download fallito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 9.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          constraints: const BoxConstraints(maxWidth: 250.0),
          decoration: BoxDecoration(
            color: isMe ? Colors.lightBlue[100] : Colors.redAccent[100],
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    message.senderUsername,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.grey[850] : Colors.grey[850],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('HH:mm').format(message.createdAt),
                    style: const TextStyle(fontSize: 12.0, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              if (message.content.isNotEmpty) ...[
                _buildHighlightedText(message.content),
                const SizedBox(height: 8.0),
              ],
              if (message.fileUrl != null) ...[
                _buildFilePreview(context),
                const SizedBox(height: 10.0),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontSize: 16.0),
      );
    }

    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(searchQuery, caseSensitive: false);
    final Iterable<Match> matches = regex.allMatches(text);

    int start = 0;

    for (final Match match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: const TextStyle(color: Colors.black),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(color: Colors.blue),
      ));

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    final fileUrl = message.fileUrl!;
    final fullUrl = '$baseUrl$fileUrl';
    final fileExtension = p.extension(fileUrl).toLowerCase();

    if (_isImage(fileExtension)) {
      return GestureDetector(
        onTap: () => _downloadFile(fullUrl, context),
        child: Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image);
          },
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _downloadFile(fullUrl, context),
        child: ListTile(
          leading: _fileIcon(fileExtension),
          title: Text(_fileTitle(fileExtension)),
          subtitle: Text(fileUrl.split('/').last),
        ),
      );
    }
  }

  bool _isImage(String fileExtension) {
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(fileExtension);
  }

  Icon _fileIcon(String fileExtension) {
    switch (fileExtension) {
      case '.pdf':
        return const Icon(Icons.picture_as_pdf);
      case '.txt':
        return const Icon(Icons.text_fields);
      default:
        return const Icon(Icons.attach_file);
    }
  }

  String _fileTitle(String fileExtension) {
    switch (fileExtension) {
      case '.pdf':
        return 'PDF File';
      case '.txt':
        return 'Text File';
      default:
        return 'File';
    }
  }
}
