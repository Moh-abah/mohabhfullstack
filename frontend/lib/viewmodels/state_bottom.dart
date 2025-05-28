/// مدير حالة شريط التنقل السفلي
/// يوفر إدارة مركزية لحالة التنقل والإشعارات
class BottomNavManager {
  // نمط Singleton للوصول العالمي
  static final BottomNavManager _instance = BottomNavManager._internal();

  // مصنع للحصول على نفس النسخة في كل مرة
  factory BottomNavManager() => _instance;

  // منشئ خاص للتأكد من إنشاء نسخة واحدة فقط
  BottomNavManager._internal();

  // حالة التنقل الحالية
  int _currentIndex = 0;

  // نوع المستخدم (عميل أو تاجر)
  String _userType = 'customer';

  // الحصول على مؤشر التنقل الحالي
  int get currentIndex => _currentIndex;

  // الحصول على نوع المستخدم
  String get userType => _userType;

  // مستمعي التغييرات
  final List<Function(int)> _listeners = [];

  // مستمعي تغييرات نوع المستخدم
  final List<Function(String)> _userTypeListeners = [];

  final Map<int, int> _badgeCounts = {};

  // الحصول على نسخة غير قابلة للتعديل من عدادات الإشعارات
  Map<int, int> get badgeCounts => Map.unmodifiable(_badgeCounts);

  // تاريخ آخر تحديث (مفيد للتزامن)
  DateTime _lastUpdated = DateTime.now();
  DateTime get lastUpdated => _lastUpdated;

  // حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // تسجيل مستمع للتغييرات
  void addListener(Function(int) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  // إلغاء تسجيل مستمع
  void removeListener(Function(int) listener) {
    _listeners.remove(listener);
  }

  // تسجيل مستمع لتغييرات نوع المستخدم
  void addUserTypeListener(Function(String) listener) {
    if (!_userTypeListeners.contains(listener)) {
      _userTypeListeners.add(listener);
    }
  }

  // إلغاء تسجيل مستمع لتغييرات نوع المستخدم
  void removeUserTypeListener(Function(String) listener) {
    _userTypeListeners.remove(listener);
  }

  // تغيير مؤشر التنقل الحالي
  void navigateTo(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      _updateLastModified();
      _notifyListeners();
    }
  }

  // تعيين نوع المستخدم
  void setUserType(String userType) {
    if (_userType != userType) {
      _userType = userType;
      _updateLastModified();
      _notifyUserTypeListeners();
    }
  }

  // تعيين حالة التحميل
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _notifyListeners();
    }
  }

  // تعيين عدد الإشعارات لعلامة تبويب معينة
  void setBadgeCount(int tabIndex, int count) {
    if (count <= 0) {
      _badgeCounts.remove(tabIndex);
    } else {
      _badgeCounts[tabIndex] = count;
    }
    _updateLastModified();
    _notifyListeners();
  }

  // زيادة عدد الإشعارات لعلامة تبويب معينة
  void incrementBadgeCount(int tabIndex) {
    _badgeCounts[tabIndex] = (_badgeCounts[tabIndex] ?? 0) + 1;
    _updateLastModified();
    _notifyListeners();
  }

  // تقليل عدد الإشعارات لعلامة تبويب معينة
  void decrementBadgeCount(int tabIndex) {
    if (_badgeCounts.containsKey(tabIndex)) {
      int currentCount = _badgeCounts[tabIndex]!;
      if (currentCount <= 1) {
        _badgeCounts.remove(tabIndex);
      } else {
        _badgeCounts[tabIndex] = currentCount - 1;
      }
      _updateLastModified();
      _notifyListeners();
    }
  }

  // الحصول على عدد الإشعارات لعلامة تبويب معينة
  int getBadgeCount(int tabIndex) {
    return _badgeCounts[tabIndex] ?? 0;
  }

  // مسح عدد الإشعارات لعلامة تبويب معينة
  void clearBadgeCount(int tabIndex) {
    if (_badgeCounts.containsKey(tabIndex)) {
      _badgeCounts.remove(tabIndex);
      _updateLastModified();
      _notifyListeners();
    }
  }

  // مسح جميع الإشعارات
  void clearAllBadges() {
    if (_badgeCounts.isNotEmpty) {
      _badgeCounts.clear();
      _updateLastModified();
      _notifyListeners();
    }
  }

  // الحصول على إجمالي عدد الإشعارات
  int get totalBadgeCount {
    return _badgeCounts.values.fold(0, (sum, count) => sum + count);
  }

  // التحقق مما إذا كانت هناك إشعارات لعلامة تبويب معينة
  bool hasBadge(int tabIndex) {
    return _badgeCounts.containsKey(tabIndex) && _badgeCounts[tabIndex]! > 0;
  }

  // التحقق مما إذا كانت هناك أي إشعارات
  bool get hasAnyBadges => _badgeCounts.isNotEmpty;

  // تحديث تاريخ آخر تعديل
  void _updateLastModified() {
    _lastUpdated = DateTime.now();
  }

  // إخطار جميع المستمعين بالتغييرات
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_currentIndex);
    }
  }

  // إخطار جميع المستمعين بتغييرات نوع المستخدم
  void _notifyUserTypeListeners() {
    for (var listener in _userTypeListeners) {
      listener(_userType);
    }
  }

  // حفظ الحالة (يمكن استخدامها مع SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'currentIndex': _currentIndex,
      'userType': _userType,
      'badgeCounts':
          _badgeCounts.map((key, value) => MapEntry(key.toString(), value)),
      'lastUpdated': _lastUpdated.millisecondsSinceEpoch,
    };
  }

  // استعادة الحالة (يمكن استخدامها مع SharedPreferences)
  void fromJson(Map<String, dynamic> json) {
    if (json.containsKey('currentIndex')) {
      _currentIndex = json['currentIndex'];
    }

    if (json.containsKey('userType')) {
      _userType = json['userType'];
    }

    if (json.containsKey('badgeCounts')) {
      final Map<String, dynamic> counts = json['badgeCounts'];
      _badgeCounts.clear();
      counts.forEach((key, value) {
        _badgeCounts[int.parse(key)] = value;
      });
    }

    if (json.containsKey('lastUpdated')) {
      _lastUpdated = DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']);
    }

    _notifyListeners();
    _notifyUserTypeListeners();
  }

  // إعادة تعيين المدير (مفيد للتسجيل/تسجيل الخروج)
  void reset() {
    _currentIndex = 0;
    _badgeCounts.clear();
    _isLoading = false;
    _updateLastModified();
    _notifyListeners();
  }
}
