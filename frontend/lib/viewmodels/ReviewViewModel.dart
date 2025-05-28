import 'package:ain_frontend/viewmodels/Profile_Store_Provider.dart';
import 'package:flutter/material.dart';

import '../models/feachReview_model.dart';
import '../ServicesAPI/AddReviewService.dart';

class ReviewViewModel extends ChangeNotifier {
  late FeachReview_models _review;
  bool _isLoading = false;
  String _errorMessage = '';
  final Addreviewservice _reviewService;

  ReviewViewModel({required Addreviewservice reviewService})
      : _reviewService = reviewService;
  FeachReview_models get review => _review;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String? _error;

  String? get error => _error;

  // إضافة التقييم
  Future<void> submitReview(int storeId, int rating, String comment,
      ReviewsState reviewsState) async {
    _isLoading = true;
    notifyListeners();

    print('🔵 [submitReview] - بدأ إرسال التقييم للمتجر ID: $storeId');
    print('⭐ التقييم: $rating');
    print('💬 التعليق: $comment');

    try {
      await _reviewService.submitReview(storeId, rating, comment);

      await reviewsState.fetchStoreReviews(storeId);

      _error = null;
      print('✅ [submitReview] - التقييم تم إرساله بنجاح.');
    } catch (e) {
      _error = 'Error: $e';
      print('❌ [submitReview] - حدث خطأ أثناء إرسال التقييم: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('⚡ [submitReview] - انتهت العملية، تحديث حالة التحميل.');
    }
  }

  // void setReview(FeachReview_models updatedReview) {
  //   _review = updatedReview;
  //   notifyListeners(); // إشعار الـUI بالتغيير
  // }

  // Future<void> updateReview(
  //     int reviewId, String comment, int rating, int storeId) async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     // استدعاء الدالة من ReviewService
  //     await _reviewService.updateReview(reviewId, comment, rating, storeId);
  //     notifyListeners(); // إخطار UI
  //   } catch (e) {
  //     _errorMessage = 'Error: $e';
  //     notifyListeners();
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
