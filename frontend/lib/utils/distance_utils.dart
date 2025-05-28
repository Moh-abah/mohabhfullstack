import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateDistance(LatLng start, LatLng end) {
  const double earthRadius = 6371000; // بالمتر
  final dLat = _degreesToRadians(end.latitude - start.latitude);
  final dLon = _degreesToRadians(end.longitude - start.longitude);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(start.latitude)) *
          cos(_degreesToRadians(end.latitude)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}


/*
خوارزميه Haversine Formula.
تقوم حساب أقصر مسافة (Great‐Circle Distance) بين نقطتين على سطح الأرض مع اعتبار كرويته التقريبية.
نحوّل فرق خطوط العرض والفرق بين خطوط الطول من درجات إلى راديان:

dLat = (lat2 – lat1) × π/180
dLon = (lon2 – lon1) × π/180
وحيث lat1_rad و lat2_rad هي خطوط العرض بعد تحويلها للراديان.
نحسب المتغير c (زاوية المركز):



م خوارزمية Haversine لحساب أقصر مسافة (Great-Circle) بين نقطتين جغرافيتين (خط عرض/خط طول) على سطح الأرض، فتقوم بتحويل الفروق من درجات إلى راديان، ثم تطبق الصيغة الرياضية لإيجاد زاوية المركز c وأخيرًا تضربها في نصف قطر الأرض (≈6 371 000 م) لإرجاع المسافة بالمتر.



 */
