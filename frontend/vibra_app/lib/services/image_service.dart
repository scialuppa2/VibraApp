import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    if (kIsWeb) {
      return imageBytes;
    }

    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      final result = await FlutterImageCompress.compressWithFile(
        targetPath,
        quality: 70,
        minWidth: 500,
        minHeight: 500,
        format: CompressFormat.jpeg,
      );

      return result;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }
}
