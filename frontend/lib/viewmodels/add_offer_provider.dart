import 'package:ain_frontend/utils/pick_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../ServicesAPI/store_SER.dart';
import '../ServicesFireBase/firestore_service.dart';
import '../utils/UploadcareCofig.dart';

import '../utils/SecureStorageHelper.dart';

// Define different state types to isolate updates
enum OfferStateType {
  loading,
  merchantData,
  images,
  duration,
  description,
}

class AddOfferProvider with ChangeNotifier {
  final Logger _logger = Logger();
  final StoreService _storeService = StoreService();
  final TextEditingController descriptionController = TextEditingController();
  String? _sstoreName;

  String? get storeName => _sstoreName;

  // State variables
  bool _isLoading = false;
  String? _merchantId;

  int? _selectedDuration;
  final List<Uint8List> _images = [];
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get merchantId => _merchantId;

  int? get selectedDuration => _selectedDuration;
  List<Uint8List> get images => _images;
  String? get error => _error;
  bool get isFormValid =>
      _merchantId != null &&
      _images.isNotEmpty &&
      descriptionController.text.isNotEmpty &&
      _selectedDuration != null;

  // Constructor
  AddOfferProvider() {
    _initializeData();
  }

  void setStoreName(String name) {
    _sstoreName = name;
    print('تم تعيين اسم المتجر: $_sstoreName');

    notifyListeners();
  }

  // Initialize data
  Future<void> _initializeData() async {
    await Future.wait([
      _loadMerchantId(),
    ]);
  }

  // Load merchant ID
  Future<void> _loadMerchantId() async {
    try {
      _setLoading(true, OfferStateType.merchantData);
      final int? userId = await SecureStorageHelper.getUserId();
      if (userId != null) {
        _merchantId = userId.toString();
        _notifyListeners(OfferStateType.merchantData);
      } else {
        _setError('يجب تسجيل الدخول أولاً');
      }
    } catch (e) {
      _setError('خطأ في تحميل بيانات المستخدم: $e');
    } finally {
      _setLoading(false, OfferStateType.merchantData);
    }
  }

  // Add image
  // Future<void> pickImage(BuildContext context) async {
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
  //       final file = File(path);
  //       final bytes = await file.readAsBytes();
  //       _images.add(bytes);
  //       _notifyListeners(OfferStateType.images);
  //     }
  //   } catch (e) {
  //     _setError('حدث خطأ أثناء اختيار الصورة: $e');
  //   }
  // }

  // Future<void> pickImageWITHVIEW(BuildContext context) async {
  //   try {
  //     final ImagePicker picker = ImagePicker();
  //     // اختيار الصورة من معرض الصور
  //     final XFile? pickedFile =
  //         await picker.pickImage(source: ImageSource.gallery);

  //     if (pickedFile != null) {
  //       final File imageFile = File(pickedFile.path);
  //       final bytes = await imageFile.readAsBytes();
  //       _images.add(bytes);

  //       _notifyListeners(OfferStateType.images);
  //     }
  //   } catch (e) {
  //     print('حدث خطأ أثناء اختيار الصورة: $e');
  //   }
  // }

  Future<void> pickImageWITHVIEW(BuildContext context) async {
    final bytes = await pickImageFromGallery(context);
    if (bytes != null) {
      _images.add(bytes);
      _notifyListeners(OfferStateType.images);
    }
  }

  // Remove image
  void removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      _notifyListeners(OfferStateType.images);
    }
  }

  // Set duration
  void setDuration(int? duration) {
    _selectedDuration = duration;
    _notifyListeners(OfferStateType.duration);
  }

  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners(); // لتحديث الواجهة بعد تعيين الخطأ
  }

  // Submit offer
  Future<bool> submitOffer(String storeName) async {
    _setLoading(true, OfferStateType.loading);
    _logger.i("🚀 بدأ تنفيذ دالة submitOffer");
    _error = null;

    try {
      if (_merchantId == null) throw '❌ يجب تسجيل الدخول أولاً';
      if (_images.isEmpty) throw '❌ يجب إضافة صورة واحدة على الأقل';
      if (descriptionController.text.isEmpty) throw '❌ وصف العرض مطلوب';
      if (_selectedDuration == null) throw '❌ الرجاء اختيار المدة';

      if (storeName.isEmpty) {
        _setError('❌ اسم المتجر غير متوفر');
        return false;
      }
      //ازاله هذا الجزء في بيك امج
      List<String> imageUrls = [];
      for (var image in _images) {
        final imageUrl = await UploadcareCofig().uploadImage(image);
        imageUrls.add(imageUrl);
        _logger.d("✅ تم رفع الصورة بنجاح: $imageUrl");
      }

      if (imageUrls.isEmpty) throw '❌ لم يتم رفع أي صورة.';

      DocumentReference docRef = await FirestoreService().addOffer(
        merchantId: _merchantId!,
        storeName: storeName,
        description: descriptionController.text,
        duration: _selectedDuration!,
        images: imageUrls,
      );

      _logger.i('✅ تم حفظ العرض في Firestore بمعرف: ${docRef.id}');
      return true;
    } catch (e) {
      _setError('❌ خطأ أثناء تنفيذ العملية: $e');
      return false;
    } finally {
      _setLoading(false, OfferStateType.loading);
    }
  }

  // Helper methods for state management
  void _setLoading(bool loading, OfferStateType type) {
    _isLoading = loading;
    _notifyListeners(type);
  }

  void _setError(String errorMsg) {
    _error = errorMsg;
    _logger.e(_error!);
    notifyListeners();
  }

  void _notifyListeners(OfferStateType type) {
    // Only notify for specific state changes to prevent unnecessary rebuilds
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
