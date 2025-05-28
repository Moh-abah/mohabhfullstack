import 'dart:typed_data';
import 'package:ain_frontend/config/Location_Cofig.dart';
import 'package:ain_frontend/utils/UploadcareCofig.dart';
import 'package:ain_frontend/utils/pick_image.dart';
import 'package:ain_frontend/views/screens/MainScreen.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateStoreScreen extends StatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final TextEditingController _nameStoreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _latitude;
  String? _longitude;
  Uint8List? _imageBytes;
  String? _imageUrl;
  bool _isLoading = false;

  // الفئات المنسدلة
  String? selectedMainCategory;
  String? selectedSubcategory;
  final Map<String, List<String>> categories = {
    'الأزياء والملابس والأحذية': [
      'متاجر الأحذية',
      ' الملابس الجاهزة وتصميمها (رجالي ونسائي)',
    ],
    'الإلكترونيات والأجهزة': [
      ' الحواسيب وملحقاتها',
      ' الهواتف الذكية والإكسسوارات',
      ' الأدوات الذكية',
      ' الألعاب الإلكترونية وأجهزة الكونسول',
    ],
    'الأثاث والديكور': [
      ' الأثاث المكتبي',
      ' الديكور',
      ' غرف النوم والمجالس والسجاد',
    ],
    'الأدوات المنزلية والمطبخ': [
      ' المنظفات المنزلية',
      ' الأثاث المطبخي',
      ' أدوات الطهي',
    ],
    'المجوهرات والإكسسوارات': [
      ' المجوهرات الذهبية',
      ' الإكسسوارات العادية',
    ],
    'البناء وموادها': [
      'الأدوات الكهربائية ومواد ومعدات البناء',
      ' الحديد',
      ' الخشب',
      ' الإسمنت',
      ' الكري والنيس',
    ],
    'السيارات وملحقاتها': [
      ' بيع السيارات',
      ' تأجير السيارات',
      ' قطع الغيار الجديدة',
      ' قطع الغيار المستخدم والتشليح',
      ' إكسسوارات السيارات',
      ' الإطارات والزيوت',
    ],
  };

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Location_Coig _locationcoig = Location_Coig();

  // نظام الألوان
  final Color _primaryColor = const Color(0xFF2A5C8D);
  final Color _accentColor = const Color(0xFFFFA726);
  final Color _backgroundColor = const Color(0xFFF8F9FA);

  static const String _baseUrl = 'https://myapptestes.onrender.com';

  Future<void> _createStore() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      _showErrorSnackbar('يجب تسجيل الدخول أولاً');
      return;
    }

    if (_nameStoreController.text.isEmpty ||
        selectedMainCategory == null ||
        selectedSubcategory == null ||
        _latitude == null ||
        _longitude == null ||
        _imageBytes == null) {
      _showErrorSnackbar('الرجاء ملء جميع الحقول المطلوبة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image first using UploadcareService
      final uploadcareService = UploadcareCofig();
      _imageUrl = await uploadcareService.uploadImage(_imageBytes!);

      final response = await _dio.post(
        '$_baseUrl/api/stores/create/',
        data: {
          "name_store": _nameStoreController.text,
          "category": selectedMainCategory,
          "subcategory": selectedSubcategory,
          "description": _descriptionController.text,
          "location": {
            "latitude": double.parse(_latitude!),
            "longitude": double.parse(_longitude!),
          },
          "images": [_imageUrl],
        },
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 201) {
        _showSuccessSnackbar('تم إنشاء المتجر بنجاح!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getLocation() async {
    try {
      var position = await _locationcoig.getCurrentLocation();
      setState(() {
        _latitude = position.latitude.toStringAsFixed(4);
        _longitude = position.longitude.toStringAsFixed(4);
      });
    } catch (e) {
      _showErrorSnackbar('فشل في الحصول على الموقع: $e');
    }
  }

  // Future<void> _pickImageWITHVIEW(BuildContext context) async {
  //   try {
  //     final ImagePicker picker = ImagePicker();
  //     // اختيار الصورة من معرض الصور
  //     final XFile? pickedFile =
  //         await picker.pickImage(source: ImageSource.gallery);

  //     if (pickedFile != null) {
  //       final File imageFile = File(pickedFile.path);
  //       final bytes = await imageFile.readAsBytes();

  //       setState(() {
  //         _imageBytes = bytes;
  //       });
  //     }
  //   } catch (e) {
  //     print('حدث خطأ أثناء اختيار الصورة: $e');
  //   }
  // }

  // Future<void> _pickImage(BuildContext context) async {
  //   try {
  //     final String? path = await FilesystemPicker.open(
  //       title: 'اختر الصورة',
  //       context: context,
  //       rootDirectory: Directory('/storage/emulated/0'),
  //       fsType: FilesystemType.file,
  //       allowedExtensions: ['.jpg', '.jpeg', '.png'],
  //       pickText: 'اختيار هذه الصورة',
  //       folderIconColor: Colors.blue,
  //     );

  //     if (path != null) {
  //       final File imageFile = File(path);
  //       final bytes = await imageFile.readAsBytes();
  //       setState(() {
  //         _imageBytes = bytes;
  //       });
  //     }
  //   } catch (e) {
  //     print('حدث خطأ: $e');
  //   }
  // }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage =
          error.response?.data['message'] ?? 'حدث خطأ في الشبكة';
      _showErrorSnackbar(errorMessage);
    } else {
      _showErrorSnackbar('حدث خطأ غير متوقع: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء متجر جديد',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 22,
            )),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundColor, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _nameStoreController,
                      label: 'اسم المتجر',
                      icon: Icons.store_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryDropdowns(),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _descriptionController,
                      label: 'الوصف',
                      icon: Icons.description_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                    _LocationButton(
                      latitude: _latitude,
                      longitude: _longitude,
                      onPressed: _getLocation,
                      primaryColor: _primaryColor,
                    ),
                    const SizedBox(height: 25),
                    _ImagePickerButton(
                      imagePath: _imageBytes,
                      onPressed: () async {
                        final imageBytes = await pickImageFromGallery(context);
                        if (imageBytes != null) {
                          setState(() {
                            _imageBytes = imageBytes;
                          });
                        }
                      },
                      primaryColor: _primaryColor,
                    ),
                    const SizedBox(height: 40),
                    _HolographicButton(
                      text: 'إنشاء المتجر',
                      icon: Icons.add_business_rounded,
                      onPressed: _createStore,
                      isLoading: _isLoading,
                      primaryColor: _primaryColor,
                      accentColor: _accentColor,
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                Center(child: CircularProgressIndicator(color: _primaryColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey[800],
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontFamily: 'Poppins'),
          prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.8)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdowns() {
    return Column(
      children: [
        _buildDropdown(
          value: selectedMainCategory,
          items: categories.keys.toList(),
          label: 'الفئة الرئيسية',
          hint: 'اختر الفئة الرئيسية',
          onChanged: (value) {
            setState(() {
              selectedMainCategory = value;
              selectedSubcategory = null;
            });
          },
        ),
        const SizedBox(height: 20),
        if (selectedMainCategory != null)
          _buildDropdown(
            value: selectedSubcategory,
            items: categories[selectedMainCategory]!,
            label: 'الفئة الفرعية',
            hint: 'اختر الفئة الفرعية',
            onChanged: (value) => setState(() => selectedSubcategory = value),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        hint: Text(hint, style: const TextStyle(fontFamily: 'Poppins')),
        items: items.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Colors.grey[800],
                )),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }
}

// ========== المكونات المخصصة ==========

class _LocationButton extends StatelessWidget {
  final String? latitude;
  final String? longitude;
  final VoidCallback onPressed;
  final Color primaryColor;

  const _LocationButton({
    required this.latitude,
    required this.longitude,
    required this.onPressed,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_rounded, color: primaryColor, size: 28),
            const SizedBox(width: 12),
            Text(
              latitude == null
                  ? 'الحصول على الموقع'
                  : 'الموقع: $latitude, $longitude',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  final Uint8List? imagePath;
  final VoidCallback onPressed;
  final Color primaryColor;

  const _ImagePickerButton({
    required this.imagePath,
    required this.onPressed,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (imagePath != null)
            Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(
                  imagePath!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_rounded, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  imagePath == null ? 'اختر صورة للمتجر' : 'تغيير الصورة',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HolographicButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color primaryColor;
  final Color accentColor;

  const _HolographicButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.isLoading,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3)
                else ...[
                  Icon(icon, size: 24, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(text,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
