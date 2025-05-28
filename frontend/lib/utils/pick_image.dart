import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImageFromGallery(BuildContext context) async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      return bytes;
    }
  } catch (e) {
    print('حدث خطأ أثناء اختيار الصورة: $e');
  }
  return null;
}
