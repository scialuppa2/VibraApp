import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class MessageInput extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final TextEditingController messageController;
  final String? selectedFilePath;
  final Uint8List? selectedFileBytes;
  final void Function() onSelectFile;
  final Future<void> Function(String content, String? fileUrl) onSendMessage;
  final void Function() onRemoveFile;

  const MessageInput({
    Key? key,
    required this.chatId,
    required this.currentUserId,
    required this.messageController,
    required this.selectedFilePath,
    required this.selectedFileBytes,
    required this.onSelectFile,
    required this.onSendMessage,
    required this.onRemoveFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileExtension = selectedFilePath?.split('.').last.toLowerCase();
    final mimeType = fileExtension != null ? lookupMimeType(fileExtension) : null;
    final fileIcon = _getFileIcon(mimeType);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (selectedFilePath != null)
            Row(
              children: [
                if (fileIcon != null) fileIcon,
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Selected file: ${selectedFilePath!.split('/').last}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onRemoveFile,
                ),
              ],
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: onSelectFile,
              ),
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final content = messageController.text;
                  await onSendMessage(content, selectedFilePath);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _getFileIcon(String? mimeType) {
    if (mimeType == null) return null;

    if (mimeType.startsWith('image/')) {
      return const Icon(Icons.image);
    } else if (mimeType.startsWith('text/')) {
      return const Icon(Icons.text_fields);
    } else if (mimeType == 'application/pdf') {
      return const Icon(Icons.picture_as_pdf);
    } else if (mimeType.startsWith('application/')) {
      return const Icon(Icons.attach_file);
    } else {
      return const Icon(Icons.file_copy);
    }
  }
}
