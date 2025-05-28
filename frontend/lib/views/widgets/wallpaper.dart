import 'dart:io';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BackgroundSelectorWidget extends StatefulWidget {
  final Function(String? imagePath, Color? color) onBackgroundSelected;

  const BackgroundSelectorWidget({
    super.key,
    required this.onBackgroundSelected,
  });

  @override
  _BackgroundSelectorWidgetState createState() =>
      _BackgroundSelectorWidgetState();
}

class _BackgroundSelectorWidgetState extends State<BackgroundSelectorWidget> {
  final List<Color> colors = [
    Colors.white,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.grey.shade300,
  ];

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> _selectColor(Color color) async {
    // حفظ اللون كقيمة نصية (RGB)
    await secureStorage.write(
      key: 'chat_background_color',
      value: '${color.red},${color.green},${color.blue},${color.alpha}',
    );

    // حذف صورة الخلفية إن وجدت
    await secureStorage.delete(key: 'chat_background_image');

    widget.onBackgroundSelected(null, color);
    Navigator.pop(context);
  }

  Future<void> _selectImage(BuildContext context) async {
    try {
      final String? path = await FilesystemPicker.open(
        title: 'اختر صورة',
        context: context, // تمرير context
        rootDirectory: Directory('/storage/emulated/0'), // المسار الأساسي
        fsType: FilesystemType.file, // اختيار الملفات فقط
        allowedExtensions: [
          '.jpg',
          '.jpeg',
          '.png'
        ], // تحديد امتدادات الصور فقط
        pickText: 'اختيار هذه الصورة',
        folderIconColor: Colors.blue,
      );

      if (path != null) {
        // حفظ مسار الصورة
        await secureStorage.write(
          key: 'chat_background_image',
          value: path,
        );

        // حذف لون الخلفية إن وجد
        await secureStorage.delete(key: 'chat_background_color');

        widget.onBackgroundSelected(path, null);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "اختر خلفية المحادثة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () => _selectColor(color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () => _selectImage(context),
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text("اختر صورة من المعرض"),
            ),
          ],
        ),
      ),
    );
  }
}
