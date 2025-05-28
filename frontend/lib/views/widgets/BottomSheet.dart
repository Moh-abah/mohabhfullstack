import 'package:ain_frontend/models/store.dart';
import 'package:ain_frontend/utils/distance_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Widget buildSearchResultsSheet({
  required List<Store> stores,
  required LatLng userLocation,
  required void Function(LatLng targetLocation, Store store) onStoreSelected,
  required void Function() onSortByDistance,
  required void Function() onSortByRating,
  required bool sortByDistance,
  required bool sortByRating,
  required BuildContext context,
  DraggableScrollableController? controller,
}) {
  // ترتيب المتاجر حسب المسافة أو التقييم
  final sortedStores = List<Store>.from(stores);
  if (sortByDistance) {
    sortedStores.sort((a, b) {
      final distA = calculateDistance(
        userLocation,
        LatLng(a.latitude, a.longitude),
      );
      final distB = calculateDistance(
        userLocation,
        LatLng(b.latitude, b.longitude),
      );
      return distA.compareTo(distB);
    });
  } else if (sortByRating) {
    sortedStores.sort((a, b) {
      final ratingA = a.ratingAverage ?? 0.0;
      final ratingB = b.ratingAverage ?? 0.0;
      return ratingB.compareTo(ratingA); // ترتيب تنازلي للتقييمات
    });
  }

  return DraggableScrollableSheet(
    initialChildSize: 0.3,
    minChildSize: 0.05, // تقليل الحد الأدنى للسماح بالسحب للأسفل دون إغلاق كامل
    maxChildSize: 0.8,
    snap: true,
    snapSizes: const [0.05, 0.3, 0.5, 0.8],
    controller: controller,
    builder: (context, scrollController) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // مؤشر السحب
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // عنوان القائمة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المتاجر القريبة (${sortedStores.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      // زر الترتيب حسب المسافة
                      _buildSortButton(
                        icon: Icons.near_me,
                        isActive: sortByDistance,
                        onTap: onSortByDistance,
                        tooltip: 'ترتيب حسب المسافة',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      // زر الترتيب حسب التقييم
                      _buildSortButton(
                        icon: Icons.star,
                        isActive: sortByRating,
                        onTap: onSortByRating,
                        tooltip: 'ترتيب حسب التقييم',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // خط فاصل
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

            // قائمة المتاجر
            Expanded(
              child: sortedStores.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: sortedStores.length,
                      itemBuilder: (context, index) {
                        return _buildStoreCard(
                          context: context,
                          store: sortedStores[index],
                          userLocation: userLocation,
                          onTap: () => onStoreSelected(
                            LatLng(sortedStores[index].latitude,
                                sortedStores[index].longitude),
                            sortedStores[index],
                          ),
                          isFirst: index == 0,
                          isLast: index == sortedStores.length - 1,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

// بطاقة المتجر - تحسين الأداء باستخدام const حيثما أمكن
Widget _buildStoreCard({
  required BuildContext context,
  required Store store,
  required LatLng userLocation,
  required VoidCallback onTap,
  bool isFirst = false,
  bool isLast = false,
}) {
  final distance = calculateDistance(
    userLocation,
    LatLng(store.latitude, store.longitude),
  );

  final distanceText = distance >= 1000
      ? '${(distance / 1000).toStringAsFixed(1)} كم'
      : '${distance.toStringAsFixed(0)} م';

  return Padding(
    padding: EdgeInsets.only(
      top: isFirst ? 8 : 4,
      bottom: isLast ? 8 : 4,
      left: 16,
      right: 16,
    ),
    child: Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المتجر - تحسين تحميل الصور
              Hero(
                tag: 'store-image-${store.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    child: store.images.isNotEmpty
                        ? FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder.png',
                            image:
                                'https://ucarecdn.com/${store.images}/-/preview/',
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Icon(
                              Icons.store,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : Icon(
                            Icons.store,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // معلومات المتجر
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المتجر
                    Text(
                      store.name_store,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // اسم المالك
                    Text(
                      store.owner_name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // التقييم والمسافة
                    Row(
                      children: [
                        // التقييم
                        RatingBarIndicator(
                          rating: store.ratingAverage ?? 0,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 16,
                          unratedColor: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${store.ratingCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),

                        // المسافة
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                distanceText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildSortButton({
  required IconData icon,
  required bool isActive,
  required VoidCallback onTap,
  required String tooltip,
  required Color color,
}) {
  return Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Icon(icon,
            size: 18, color: isActive ? color : Colors.grey.shade600),
      ),
    ),
  );
}

// حالة عدم وجود متاجر
Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.store_mall_directory_outlined,
          size: 64,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'لا توجد متاجر قريبة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'حاول توسيع نطاق البحث أو تغيير موقعك',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
