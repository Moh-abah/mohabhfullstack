class Review {
  final int id;
  final String customerName;
  final int rating;
  final String? comment;
  final String createdAt;
  final int storeId;

  Review({
    required this.id,
    required this.customerName,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.storeId,
  });

  // تحويل البيانات من JSON إلى كائن Review
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      customerName: json['customer_name'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
      storeId: json['store'],
    );
  }

  // تحويل كائن Review إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'store': storeId,
    };
  }
}
