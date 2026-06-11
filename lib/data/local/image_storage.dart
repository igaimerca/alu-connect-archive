import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorage {
  ImageStorage._();
  static final ImageStorage instance = ImageStorage._();

  final _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<String?> pickAndSaveCover({ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return saveCoverFromPath(picked.path);
  }

  Future<String> saveCoverFromPath(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(dir.path, 'covers'));
    if (!coversDir.existsSync()) {
      coversDir.createSync(recursive: true);
    }

    final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final destPath = p.join(coversDir.path, '${_uuid.v4()}$ext');
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  bool hasLocalImage(String path) {
    return path.isNotEmpty && File(path).existsSync();
  }
}
