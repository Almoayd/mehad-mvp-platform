import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload bytes to path and return public download URL.
  Future<String?> uploadBytes(String path, Uint8List data, {String? contentType}) async {
    try {
      final ref = _storage.ref().child(path);
      final meta = SettableMetadata(contentType: contentType);
      final task = await ref.putData(data, meta);
      final url = await task.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Storage upload error: $e');
      return null;
    }
  }
}
