import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatProvider extends ChangeNotifier {
  final int userId;
  final Color primaryColor = const Color(0xFF2A5C8D);
  final Color accentColor = const Color.fromARGB(255, 86, 0, 120);
  static const String baseUrl = 'https://myapptestes.onrender.com';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool isLoading = true;
  bool _hasReceivedInitialData = true;
  List<QueryDocumentSnapshot> allChats = [];
  String selectedFilter = 'الكل';
  int activeChatsCount = 0;

  // تتبع ما إذا كانت البيانات قد تم تحميلها بالفعل
  bool _isInitialized = false;

  // تخزين مؤقت للمستخدمين لتجنب طلبات API المتكررة
  final Map<int, Map<String, dynamic>> _userCache = {};

  ChatProvider({required this.userId}) {
    // تحميل البيانات فقط إذا لم يتم تحميلها من قبل
    if (!_isInitialized) {
      fetchChats();
    }
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  Future<void> fetchChats() async {
    if (!isLoading && _isInitialized) {
      // إذا كانت البيانات قيد التحميل بالفعل أو تم تحميلها، لا تقم بإعادة التحميل
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // إعداد مستمعي Firebase لتحديثات المحادثة في الوقت الفعلي
      _setupChatListeners();

      // تعيين العلم للإشارة إلى أن البيانات قد تم تحميلها
      _isInitialized = true;
    } catch (e) {
      print('Error setting up chat listeners: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  void _finishLoadingIfNeeded() {
    if (!_hasReceivedInitialData) {
      _hasReceivedInitialData = true;
      isLoading = false;
      notifyListeners();
    }
  }

  // إعداد مستمعي Firebase للتحديثات في الوقت الفعلي
  void _setupChatListeners() {
    // مستمع لمحادثات العميل
    FirebaseFirestore.instance
        .collection('chats')
        .where('customerId', isEqualTo: userId)
        .orderBy('lastMessageTime',
            descending: true) // ترتيب المحادثات حسب آخر رسالة
        .snapshots()
        .listen((customerSnapshot) {
      _updateChats(customerSnapshot.docs, []);
      _finishLoadingIfNeeded();
    }, onError: (error) {
      print('Error in customer chats listener: $error');
    });

    // مستمع لمحادثات المالك
    FirebaseFirestore.instance
        .collection('chats')
        .where('ownerId', isEqualTo: userId)
        .orderBy('lastMessageTime',
            descending: true) // ترتيب المحادثات حسب آخر رسالة
        .snapshots()
        .listen((ownerSnapshot) {
      _updateChats([], ownerSnapshot.docs);
      _finishLoadingIfNeeded();
    }, onError: (error) {
      print('Error in owner chats listener: $error');
    });
  }

  // تحديث قائمة المحادثات عند تلقي بيانات جديدة
  void _updateChats(List<QueryDocumentSnapshot> customerChats,
      List<QueryDocumentSnapshot> ownerChats) {
    if (customerChats.isNotEmpty) {
      // تحديث محادثات العميل فقط
      final existingOwnerChats =
          allChats.where((chat) => chat['ownerId'] == userId).toList();
      allChats = [...customerChats, ...existingOwnerChats];
    }

    if (ownerChats.isNotEmpty) {
      // تحديث محادثات المالك فقط
      final existingCustomerChats =
          allChats.where((chat) => chat['customerId'] == userId).toList();
      allChats = [...existingCustomerChats, ...ownerChats];
    }

    // حساب عدد المحادثات النشطة
    activeChatsCount =
        allChats.where((chat) => chat['status'] == 'active').length;

    isLoading = false;
    notifyListeners();
  }

  List<QueryDocumentSnapshot> getFilteredChats() {
    if (selectedFilter == 'الكل') {
      return allChats;
    } else if (selectedFilter == 'متصله') {
      return allChats.where((chat) => chat['status'] == 'active').toList();
    } else if (selectedFilter == 'غير متصله') {
      return allChats.where((chat) => chat['status'] != 'active').toList();
    } else if (selectedFilter == 'المتاجر') {
      return allChats.where((chat) => chat['ownerId'] != userId).toList();
    } else if (selectedFilter == 'العملاء') {
      return allChats.where((chat) => chat['customerId'] != userId).toList();
    }
    return allChats;
  }

  Future<Map<String, dynamic>?> getOtherUser(int otherUserId) async {
    // التحقق من التخزين المؤقت أولاً
    if (_userCache.containsKey(otherUserId)) {
      return _userCache[otherUserId];
    }

    try {
      String? token = await _getToken();

      if (token == null) {
        print('Error: No token found.');
        return null;
      }

      final response = await _dio.get(
        '$baseUrl/api/users/otheruser/$otherUserId/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        // تخزين البيانات في التخزين المؤقت
        _userCache[otherUserId] = response.data;
        return response.data;
      } else {
        print('Error: Request failed with status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<String?> _getToken() async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      return token;
    } catch (e) {
      print('Error fetching token: $e');
      return null;
    }
  }

  // تحديث البيانات يدويًا عند الحاجة
  void refreshChats() {
    // إعادة تعيين علم التحميل
    isLoading = true;
    notifyListeners();

    // لا حاجة لإعادة إعداد المستمعين، فهم يعملون بالفعل
    // فقط إعادة تعيين علم التحميل لإظهار مؤشر التحميل

    // بعد فترة قصيرة، إعادة تعيين علم التحميل
    Future.delayed(const Duration(milliseconds: 500), () {
      isLoading = false;
      notifyListeners();
    });
  }

  // تنظيف الموارد عند التخلص من المزود
  void dispose() {
    // تنظيف أي موارد إذا لزم الأمر
    super.dispose();
  }
}
