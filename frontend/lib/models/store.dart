import 'feachReview_model.dart';

class Store {
  final int id;
  final String name_store;
  final String category;
  final String subcategory;
  final String description;
  final double latitude;
  final double longitude;
  final String images;
  final String phone;
  final String owner_name;
  final int ownerId;
  final double ratingAverage;
  final int ratingCount;
  List<FeachReview_models> evaluations;

  Store({
    required this.id,
    required this.name_store,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.phone,
    required this.owner_name,
    required this.ratingAverage,
    required this.ratingCount,
    required this.ownerId,
    required this.evaluations,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    // Handle the images field which can be a List or a String
    String imageStr = '';
    if (json['images'] != null) {
      if (json['images'] is List && json['images'].isNotEmpty) {
        // If it's a list, take the first item
        imageStr = json['images'][0].toString();
      } else if (json['images'] is String) {
        // If it's already a string, use it directly
        imageStr = json['images'];
      }
    }

    return Store(
      id: json['id'],
      name_store: json['name_store'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      description: json['description'] ?? '',
      latitude:
          (json['location'] != null && json['location']['latitude'] != null)
              ? json['location']['latitude'].toDouble()
              : 0.0,
      longitude:
          (json['location'] != null && json['location']['longitude'] != null)
              ? json['location']['longitude'].toDouble()
              : 0.0,
      images: imageStr, // Use the processed image string
      ratingAverage: json['rating_average']?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
      phone: json['phone'] ?? '',
      owner_name: json['owner_name'] ?? '',
      ownerId: int.tryParse(json['owner_id'].toString()) ?? 0,
      evaluations: (json['evaluations'] as List<dynamic>?)
              ?.map((e) => FeachReview_models.fromJson(e))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name_store": name_store,
      "category": category,
      "subcategory": subcategory,
      "description": description,
      "location": {
        "latitude": latitude,
        "longitude": longitude,
      },
      "images": images,
      "rating_average": ratingAverage,
      "rating_count": ratingCount,
      "owner_name": owner_name,
      "phone": phone,
      "owner_id": ownerId,
      "evaluations": evaluations.map((e) => e.toJson()).toList(),
    };
  }
}
