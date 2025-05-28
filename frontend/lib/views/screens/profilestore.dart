import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/Profile_Store_Provider.dart';

import 'add_offer_screen.dart';

class Profilestore extends StatefulWidget {
  final int marchintID;
  final int? storeId; // اختياري

  const Profilestore({super.key, required this.marchintID, this.storeId});

  @override
  _ProfilestoreState createState() => _ProfilestoreState();
}

class _ProfilestoreState extends State<Profilestore>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final provider =
          Provider.of<ProfileStoreProvider>(context, listen: false);
      provider.setCurrentTabIndex(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileStoreProvider(
        merchantId: widget.marchintID,
        dio: Dio(),
        storage: const FlutterSecureStorage(),
      )..initialize(),
      child: Consumer<ProfileStoreProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: provider.backgroundColor,
            appBar: AppBar(
              title: Text(provider.store?.name_store ?? 'ملف المتجر'),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              foregroundColor: provider.textPrimaryColor,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddOfferScreen(
                            storeName: provider.store?.name_store ??
                                'اسم المتجر الافتراضي'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // Menu functionality
                  },
                ),
              ],
            ),
            body: provider.isLoading
                ? _buildLoadingIndicator(provider)
                : _buildStoreContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(ProfileStoreProvider provider) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(provider.primaryColor),
      ),
    );
  }

  Widget _buildStoreContent(ProfileStoreProvider provider) {
    if (provider.store == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_mall_directory_outlined,
                size: 64, color: provider.textSecondaryColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'لا توجد بيانات للمتجر',
              style: TextStyle(
                fontSize: 18,
                color: provider.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final refreshProvider =
                    Provider.of<ProfileStoreProvider>(context, listen: false);
                refreshProvider.initialize();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(provider),
          const SizedBox(height: 16),
          _buildStoreDescription(provider),
          const SizedBox(height: 16),
          _buildTabBar(provider),
          _buildTabContent(provider),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileStoreProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  provider.primaryColor.withOpacity(0.7),
                  provider.accentColor.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: provider.store!.images.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImageWithRetry(
                          'https://ucarecdn.com/${provider.store!.images}/-/preview/'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: provider.store!.images.isEmpty
                ? const Icon(Icons.store, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 20),

          // Stats
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                    provider.activeOffers.toString(), 'ofeer', provider),
                _buildStatColumn(
                    provider.totalLikes.toString(), 'like', provider),
                _buildStatColumn(provider.store!.ratingCount.toString(),
                    'ratingCount', provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
      String count, String label, ProfileStoreProvider provider) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: provider.textPrimaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: provider.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreDescription(ProfileStoreProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.store!.name_store,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: provider.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.store!.description,
            style: TextStyle(
              fontSize: 14,
              color: provider.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ProfileStoreProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: provider.primaryColor,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: provider.textSecondaryColor,
          tabs: const [
            Tab(text: 'offer active'),
            Tab(text: 'reviv'),
            Tab(text: 'ofeerdonotactiv'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ProfileStoreProvider provider) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveOffers(provider),
          _buildReviewsGrid(provider),
          _buildInactiveOffers(provider),
        ],
      ),
    );
  }

  Widget _buildActiveOffers(ProfileStoreProvider provider) {
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getActiveOffers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(provider.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('حدث خطأ: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد عروض نشطة حالياً',
                  style: TextStyle(
                    fontSize: 16,
                    color: provider.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        final offers = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offerData = offers[index].data() as Map<String, dynamic>;
            final offerId = offers[index].id;

            return _buildOfferCard(offerId, offerData, provider);
          },
        );
      },
    );
  }

  Widget _buildInactiveOffers(ProfileStoreProvider provider) {
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getInactiveOffers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(provider.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('حدث خطأ: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد عروض منتهية',
                  style: TextStyle(
                    fontSize: 16,
                    color: provider.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        final offers = snapshot.data!.docs;
        // Filter to only show inactive offers
        final inactiveOffers = offers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isActive'] == false;
        }).toList();

        if (inactiveOffers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد عروض منتهية',
                  style: TextStyle(
                    fontSize: 16,
                    color: provider.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: inactiveOffers.length,
          itemBuilder: (context, index) {
            final offerData =
                inactiveOffers[index].data() as Map<String, dynamic>;
            final offerId = inactiveOffers[index].id;

            return _buildOfferCard(offerId, offerData, provider,
                isActive: false);
          },
        );
      },
    );
  }

  Widget _buildOfferCard(String offerId, Map<String, dynamic> offerData,
      ProfileStoreProvider provider,
      {bool isActive = true}) {
    final List<String> images = List<String>.from(offerData['images'] ?? []);
    final String description = offerData['description'] ?? '';
    final int likes = offerData['likes'] ?? 0;
    final Timestamp? createdAt = offerData['createdAt'] as Timestamp?;
    final Timestamp? expiryDate = offerData['expiryDate'] as Timestamp?;

    String formattedDate = 'غير معروف';
    String expiryDateStr = 'غير معروف';
    final fullImageUrls = images.map((imageId) {
      return 'https://ucarecdn.com/$imageId/-/preview/';
    }).toList();

    if (createdAt != null) {
      formattedDate = DateFormat('yyyy-MM-dd').format(createdAt.toDate());
    }

    if (expiryDate != null) {
      expiryDateStr = DateFormat('yyyy-MM-dd').format(expiryDate.toDate());
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offer images
          if (images.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image(
                      image: NetworkImageWithRetry(fullImageUrls.first),
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                              height: 200,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),

          // Offer details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'نشط' : 'منتهي',
                        style: TextStyle(
                          color: isActive ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Expiry date
                    Text(
                      'ينتهي: $expiryDateStr',
                      style: TextStyle(
                        color: provider.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: provider.textPrimaryColor,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    // Likes count
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red[400], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$likes',
                          style: TextStyle(
                            color: provider.textSecondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Comments count - using StreamBuilder to get real-time count
                    StreamBuilder<QuerySnapshot>(
                      stream: provider.getOfferComments(offerId),
                      builder: (context, snapshot) {
                        int commentCount = 0;
                        if (snapshot.hasData) {
                          commentCount = snapshot.data!.docs.length;
                        }

                        return Row(
                          children: [
                            Icon(Icons.comment,
                                color: Colors.blue[400], size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '$commentCount',
                              style: TextStyle(
                                color: provider.textSecondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(width: 16),

                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.grey[600], size: 18),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: provider.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                if (isActive)
                  Row(
                    children: [
                      // Comment button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showCommentsBottomSheet(
                                context, offerId, provider);
                          },
                          icon: const Icon(Icons.comment_outlined),
                          label: const Text('التعليقات'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: provider.primaryColor,
                            side: BorderSide(color: provider.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
      Map<String, dynamic> commentData, ProfileStoreProvider provider) {
    final String username = commentData['username'] ?? 'مستخدم';
    final String comment = commentData['comment'] ?? '';
    final Timestamp? createdAt = commentData['createdAt'] as Timestamp?;

    String timeAgo = '';
    if (createdAt != null) {
      final now = DateTime.now();
      final difference = now.difference(createdAt.toDate());

      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes} دقيقة';
      } else {
        timeAgo = 'الآن';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: provider.primaryColor.withOpacity(0.1),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: TextStyle(
                color: provider.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: provider.textPrimaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: provider.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: TextStyle(
                    color: provider.textPrimaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsBottomSheet(
      BuildContext context, String offerId, ProfileStoreProvider provider) {
    //final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: provider.backgroundColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: provider.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'التعليقات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: provider.textPrimaryColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Comments list
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: provider.getOfferComments(offerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('حدث خطأ: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.comment_outlined,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد تعليقات حتى الآن',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: provider.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final comments = snapshot.data!.docs;

                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final commentData =
                                comments[index].data() as Map<String, dynamic>;
                            return _buildCommentItem(commentData, provider);
                          },
                        );
                      },
                    ),
                  ),

                  // Comment input
                  if (provider.currentUserId != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: provider.backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsGrid(ProfileStoreProvider provider) {
    if (provider.reviewsState.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(provider.primaryColor),
        ),
      );
    }

    if (provider.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد تقييمات حتى الآن',
              style: TextStyle(
                fontSize: 16,
                color: provider.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.refreshReviews();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث التقييمات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.reviews.length,
      itemBuilder: (context, index) {
        final review = provider.reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: provider.primaryColor.withOpacity(0.1),
                      child: Text(
                        review.customerName.isNotEmpty
                            ? review.customerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: provider.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.customerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: provider.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: index < review.rating
                                    ? Colors.amber
                                    : Colors.grey,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      review.createdAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: provider.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.comment,
                  style: TextStyle(
                    color: provider.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
