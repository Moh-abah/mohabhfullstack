class FeachReview_models {
  final int id;
  final String customerName;
  final int rating;
  final String comment;
  final String createdAt;

  FeachReview_models({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // دالة copyWith المعدلة للسماح بتغيير comment و rating فقط
  FeachReview_models copyWith({
    String? comment,
    int? rating,
  }) {
    return FeachReview_models(
      id: id, // لا يمكن تغييره
      customerName: customerName, // لا يمكن تغييره
      rating: rating ?? this.rating, // يمكن تغييره
      comment: comment ?? this.comment, // يمكن تغييره
      createdAt: createdAt, // لا يمكن تغييره
    );
  }

  factory FeachReview_models.fromJson(Map<String, dynamic> json) {
    return FeachReview_models(
      id: json['id'],
      customerName: json['customer_name'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "rating": rating,
      "comment": comment,
      "created_at": createdAt,
      "customer_name": customerName,
    };
  }
}
