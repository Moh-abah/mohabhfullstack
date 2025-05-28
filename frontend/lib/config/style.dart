const String customMapStyle = '''
[
  {
    "featureType": "poi",        // إخفاء النقاط المهمة (متاجر، مطاعم، الخ)
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "transit",    // إخفاء وسائل النقل (محطات مترو، حافلات)
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "road",       // تحسين مظهر الطرق
    "elementType": "labels.icon",
    "stylers": [{ "visibility": "off" }] // إخفاء أيقونات الطرق
  },
  {
    "featureType": "administrative", // تحسين التقسيمات الإدارية
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#444444" }] // لون نص داكن أنيق
  },
  {
    "featureType": "landscape",  // تحسين المناظر الطبيعية
    "stylers": [
      { "lightness": 45 },       // تدرج ألوان طبيعي
      { "saturation": -5 }       // تقليل التباين قليلاً
    ]
  },
  {
    "featureType": "water",      // تحسين لون المياه
    "stylers": [
      { "color": "#a2daf2" },    // لون مياه فاتح
      { "saturation": 10 }       // زيادة حيوية اللون
    ]
  }
]
''';
