import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadImage(
    XFile image,
  ) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = _storage.ref().child(
          'places/$fileName.jpg',
        );

    Uint8List bytes = await image.readAsBytes();

    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    return await ref.getDownloadURL();
  }
}
