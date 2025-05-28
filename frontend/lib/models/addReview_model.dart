class AddReviewModel {
  final int rating;
  final String comment;

  AddReviewModel({
    required this.rating,
    required this.comment,
  });

  // للتحقق من صحة البيانات
  bool isValid() {
    return rating >= 1 && rating <= 5 && comment.isNotEmpty;
  }

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }

  // من JSON إلى كائن Dart
  factory AddReviewModel.fromJson(Map<String, dynamic> json) {
    return AddReviewModel(
      rating: json['rating'],
      comment: json['comment'],
    );
  }

  // للتأكد من التقييم الصالح
  static AddReviewModel? fromInput(int rating, String comment) {
    if (rating >= 1 && rating <= 5 && comment.isNotEmpty) {
      return AddReviewModel(rating: rating, comment: comment);
    }
    return null;
  }
}
