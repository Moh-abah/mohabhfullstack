import 'package:ain_frontend/views/screens/StorMaps.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

import '../../database_helper.dart';
import '../../ServicesFireBase/firestore_service.dart';
import '../../viewmodels/HomeScreenProvider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Logger _logger = Logger();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLiked = false; // حالة الإعجاب
  bool showMessage = false; // حالة عرض الرسالة بجانب الأيقونة
  // Text styles
  late TextStyle _titleStyle;
  late TextStyle _subtitleStyle;
  late TextStyle _bodyStyle;
  late TextStyle _smallStyle;
  late TextStyle _buttonStyle;

  @override
  void initState() {
    super.initState();
    FirestoreService().checkAndDeactivateExpiredOffers();
    _logger.i("Initializing HomeScreen");

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    // Delayed data loading for better effect

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        Provider.of<HomeScreenProvider>(context, listen: false).refreshOffers();
      }
    });

    // Initialize text styles
    _initTextStyles();
  }

  void _initTextStyles() {
    final provider = Provider.of<HomeScreenProvider>(context, listen: false);

    _titleStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: provider.textDarkColor,
      height: 1.2,
    );

    _subtitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: provider.primaryColor,
      height: 1.2,
    );

    _bodyStyle = TextStyle(
      fontSize: 16,
      color: provider.textDarkColor,
      height: 1.5,
    );

    _smallStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
      height: 1.2,
    );

    _buttonStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.i("Building HomeScreen");
    final provider = Provider.of<HomeScreenProvider>(context);

    // Apply luxury theme to the entire screen
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: provider.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: provider.cardColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: provider.primaryColor),
          titleTextStyle: _titleStyle,
        ),
        cardTheme: CardTheme(
          color: provider.cardColor,
          elevation: 4,
          shadowColor: Colors.black26,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      child: provider.isLoading
          ? _buildLoadingScaffold(provider)
          : Scaffold(
              appBar: _buildLuxuryAppBar(provider),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              body: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildBody(provider),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(HomeScreenProvider provider) {
    if (provider.isOnline) {
      // Online mode: use Firestore stream
      return StreamBuilder<QuerySnapshot>(
        stream: provider.getFilteredOffers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _logger.e("Error retrieving data: ${snapshot.error}");
            return _buildErrorWidget(snapshot.error.toString(), provider);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            _logger.i("Waiting for data...");
            return _buildShimmerLoadingList(provider);
          }

          final offers = snapshot.data!.docs;
          _logger.i("Retrieved ${offers.length} offers");

          if (offers.isEmpty) {
            return _buildEmptyOffersWidget(provider.isMerchant, provider);
          }

          return _buildOffersList(offers, provider);
        },
      );
    } else {
      // Offline mode: use cached offers
      return StreamBuilder<List<Offer>>(
        stream: provider.offersStream,
        initialData: provider.cachedOffers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString(), provider);
          }

          if (!snapshot.hasData) {
            return _buildShimmerLoadingList(provider);
          }

          final offers = snapshot.data!;

          if (offers.isEmpty) {
            return _buildEmptyOffersWidget(provider.isMerchant, provider);
          }

          return _buildOfflineOffersList(offers, provider);
        },
      );
    }
  }

  // Build the offline offers list
  Widget _buildOfflineOffersList(
      List<Offer> offers, HomeScreenProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refreshOffers,
      color: provider.accentColor,
      backgroundColor: provider.cardColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: offers.length + 1, // +1 for the load more button
        itemBuilder: (context, index) {
          // Show load more button at the end
          if (index == offers.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: provider.isOnline
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: provider.accentColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => provider.loadMoreOffers(),
                        child: Text('تحميل المزيد', style: _buttonStyle),
                      )
                    : Text(
                        'اتصل بالإنترنت لتحميل المزيد من العروض',
                        style: _smallStyle,
                      ),
              ),
            );
          }

          final offer = offers[index];
          final offerId = offer.id;

          // Parse images from JSON string
          List<String> images = [];
          try {
            images = List<String>.from(jsonDecode(offer.images));
          } catch (e) {
            _logger.e("Error parsing JSON for images: $e");
          }

          // Convert DateTime to Timestamp for compatibility
          Timestamp expiryDate =
              Timestamp.fromDate(offer.expiryDate ?? DateTime.now());

          // Mark offer as viewed when card is displayed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              provider.markOfferAsViewed(offerId);
            }
          });

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.2;
              final startTime = delay;
              final endTime = startTime + 0.8;

              final animationValue = _animationController.value;
              final opacity = animationValue < startTime
                  ? 0.0
                  : animationValue > endTime
                      ? 1.0
                      : (animationValue - startTime) / (endTime - startTime);

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - opacity)),
                  child: child,
                ),
              );
            },
            child: _buildLuxuryOfferCard(
              offerId: offerId,
              storeName: offer.storeName,
              description: offer.description,
              images: images,
              expiryDate: expiryDate,
              isActive: offer.isActive,
              likes: offer.likes,
              provider: provider,
            ),
          );
        },
      ),
    );
  }

  // Build the online offers list
  Widget _buildOffersList(
      List<QueryDocumentSnapshot> offers, HomeScreenProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refreshOffers,
      color: provider.accentColor,
      backgroundColor: provider.cardColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: offers.length + (provider.hasMoreOffers ? 1 : 0),
        itemBuilder: (context, index) {
          // Show "load more" button at the end of the list
          if (index == offers.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: provider.isLoadingMore
                    ? CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(provider.accentColor),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: provider.accentColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => provider.loadMoreOffers(),
                        child: Text('تحميل المزيد', style: _buttonStyle),
                      ),
              ),
            );
          }

          final offer = offers[index].data() as Map<String, dynamic>;
          final images = offer['images'] as List<dynamic>? ?? [];
          final offerId = offer['offerId'] as String;

          // Mark offer as viewed when card is displayed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              provider.markOfferAsViewed(offerId);
            }
          });

          return _buildLuxuryOfferCard(
            offerId: offerId,
            storeName: offer['storeName'] ?? 'بدون اسم',
            description: offer['description'] ?? 'بدون وصف',
            images: images.cast<String>(),
            expiryDate: (offer['expiryDate'] as Timestamp?) ?? Timestamp.now(),
            isActive: offer['isActive'] ?? false,
            likes: int.tryParse(offer['likes'].toString()) ?? 0,
            provider: provider,
          );
        },
      ),
    );
  }

  // Luxury app bar
  PreferredSizeWidget _buildLuxuryAppBar(HomeScreenProvider provider) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer, color: provider.accentColor),
          SizedBox(width: 8),
          Text(
            'العروض المميزة',
            style: _titleStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        // Offline indicator
        if (!provider.isOnline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              backgroundColor: Colors.orange.withOpacity(0.2),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'غير متصل',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        IconButton(
          icon: Icon(Icons.filter_list, color: provider.primaryColor),
          onPressed: () {
            _logger.i("Filter icon pressed");
            _showFilterDialog(provider);
          },
        ),
        /*
        IconButton(
          icon: Icon(Icons.search, color: provider.primaryColor),
          onPressed: () {
            // Add search functionality here
          },
        ),
        */
      ],
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                provider.accentColor.withOpacity(0.3),
                Colors.transparent
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  /*
  Widget _buildLuxuryBottomNavBar(HomeScreenProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: provider.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: CustomBottomNavBar(
        currentIndex: provider.currentIndex,
        onTap: (index) {
          provider.setCurrentIndex(index);
        },
      ),
    );
  }

  */

  // Luxury offer card
  Widget _buildLuxuryOfferCard({
    required String offerId,
    required String storeName,
    required String description,
    required List<String> images,
    required Timestamp expiryDate,
    required bool isActive,
    required int likes,
    required HomeScreenProvider provider,
  }) {
    final daysRemaining = _calculateDaysRemaining(expiryDate);

    // Convert IDs to full URLs
    final fullImageUrls = images.map((imageId) {
      return 'https://ucarecdn.com/$imageId/-/preview/';
    }).toList();

    // Check if the offer is liked by the user
    final isLiked = provider.isOfferLiked(offerId);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _logger.i("Offer card tapped: $storeName");
          _showOfferDetails(offerId, storeName, description, fullImageUrls,
              likes, isLiked, provider);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with enhanced effects
            Stack(
              children: [
                if (fullImageUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image(
                      image: NetworkImageWithRetry(fullImageUrls.first),
                      height: 200,
                      width: double.infinity,
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          height: 200,
                          child: Icon(Icons.error_outline, color: Colors.grey),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey, size: 40),
                  ),

                // Transparent bar at the top with store name
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          storeName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                isActive ? provider.accentColor : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'نشط' : 'منتهي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Remaining time badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: daysRemaining <= 1
                          ? Colors.red
                          : provider.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          daysRemaining > 0
                              ? '$daysRemaining يوم متبق'
                              : 'ينتهي اليوم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Likes badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite,
                          size: 16,
                          color: isLiked ? Colors.red : Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '$likes',
                          style: TextStyle(
                            color: provider.textDarkColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: _bodyStyle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),

                  // Thumbnail images if there are more than one
                  if (fullImageUrls.length > 1)
                    Container(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: fullImageUrls.length - 1,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 60,
                            height: 60,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: provider.accentColor.withOpacity(0.3),
                                  width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image(
                                image: NetworkImageWithRetry(
                                    fullImageUrls[index + 1]),
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 16),

                  // View details button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _showOfferDetails(offerId, storeName, description,
                            fullImageUrls, likes, isLiked, provider);
                      },
                      child: Text(
                        'عرض التفاصيل',
                        style: _buttonStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced loading UI using Shimmer
  Widget _buildShimmerLoadingList(HomeScreenProvider provider) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Enhanced error widget
  Widget _buildErrorWidget(String error, HomeScreenProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            'حدث خطأ أثناء تحميل البيانات',
            style: _subtitleStyle,
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: _smallStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(Icons.refresh),
            label: Text('إعادة المحاولة', style: _buttonStyle),
            onPressed: () {
              provider.refreshOffers();
            },
          ),
        ],
      ),
    );
  }

  // Enhanced empty offers widget
  Widget _buildEmptyOffersWidget(bool isMerchant, HomeScreenProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: provider.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_outlined,
              size: 60,
              color: provider.accentColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'لا توجد عروض متاحة حالياً',
            style: _titleStyle,
          ),
          SizedBox(height: 8),
          Text(
            'ستظهر العروض الجديدة هنا عند إضافتها',
            style: _smallStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          if (isMerchant)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.add),
              label: Text('إضافة أول عرض', style: _buttonStyle),
              onPressed: () {
                _logger.i("Creating first offer");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Stormaps()),
                );
              },
            ),
        ],
      ),
    );
  }

  // Initial loading scaffold
  Widget _buildLoadingScaffold(HomeScreenProvider provider) {
    return Scaffold(
      appBar: AppBar(
        title: Text('العروض الحالية'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(provider.accentColor),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل العروض...',
              style: _bodyStyle,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced offer details modal
  void _showOfferDetails(
      String offerId,
      String storeName,
      String description,
      List<String> images,
      int likes,
      bool isLiked,
      HomeScreenProvider provider) {
    _logger.i("Showing offer details: $storeName");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: provider.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pull handle
            Container(
              width: 40,
              height: 5,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Offer title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: provider.accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.store, color: provider.accentColor),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      storeName,
                      style: _titleStyle,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: provider.primaryColor),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : provider.primaryColor,
                    ),
                    onPressed: () {
                      if (isLiked) {
                        // إذا كان العرض قد تم الإعجاب به مسبقًا
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text(
                                "لقد أعجبت بهذا العرض سابقًا",
                                style: TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // إغلاق مربع الحوار بعد الضغط على الزر
                                  },
                                  child: Text("حسناً"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // إذا لم يكن العرض قد تم الإعجاب به مسبقًا
                        provider.likeOffer(offerId,
                            context); // استدعاء دالة likeOffer لتحديث الحالة
                      }
                    },
                  ),

                  /*
                  IconButton(
                    icon: Icon(Icons.store, color: provider.primaryColor),
                    onPressed: () async {
                      String? merchantId =
                          await provider.getMerchantIdForOffer(offerId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Stormaps(merchantId: merchantId),
                        ),
                      );
                    },
                  ),
                  */
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            // Offer content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image gallery
                    if (images.isNotEmpty)
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image(
                                  image: NetworkImageWithRetry(images[index]),
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  provider.accentColor),
                                        ),
                                      );
                                    }
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    SizedBox(height: 24),

                    // Offer description
                    Text(
                      'تفاصيل العرض',
                      style: _subtitleStyle,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: provider.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        description,
                        style: _bodyStyle,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Likes count
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          '$likes إعجاب',
                          style: _bodyStyle,
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Comments section
                    Text(
                      'إضافة تعليق',
                      style: _subtitleStyle,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: provider.commentController,
                      decoration: InputDecoration(
                        hintText: 'اكتب تعليقك هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: provider.accentColor),
                          onPressed: () {
                            provider.addComment(offerId, context);
                          },
                        ),
                      ),
                      maxLines: 3,
                    ),

                    SizedBox(height: 24),

                    // Display current comments
                    Text(
                      'التعليقات',
                      style: _subtitleStyle,
                    ),
                    SizedBox(height: 8),

                    // Display comments based on connection status
                    provider.canShowOnlineComments(offerId)
                        ? StreamBuilder<QuerySnapshot>(
                            stream: provider.getOfferComments(offerId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('خطأ في تحميل التعليقات');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        provider.accentColor),
                                  ),
                                );
                              }

                              final comments = snapshot.data?.docs ?? [];

                              if (comments.isEmpty) {
                                return Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'لا توجد تعليقات حتى الآن. كن أول من يعلق!',
                                    style: _smallStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index].data()
                                      as Map<String, dynamic>;
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 197, 197, 197),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.person,
                                                size: 16,
                                                color: provider.primaryColor),
                                            SizedBox(width: 4),
                                            Text(
                                              comment['username'] ??
                                                  'مستخدم #${comment['userId']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: provider.primaryColor,
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              _formatTimestamp(
                                                  comment['createdAt']
                                                      as Timestamp),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          comment['comment'] as String,
                                          style: _bodyStyle,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : FutureBuilder<List<OfferComment>>(
                            future: provider.getOfflineComments(offerId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('خطأ في تحميل التعليقات المحلية');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        provider.accentColor),
                                  ),
                                );
                              }

                              final comments = snapshot.data ?? [];

                              if (comments.isEmpty) {
                                return Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'لا توجد تعليقات محلية',
                                        style: _smallStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'أنت في وضع عدم الاتصال. التعليقات عبر الإنترنت غير متاحة.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color.fromARGB(
                                              255, 161, 161, 160),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.person,
                                                size: 16,
                                                color: provider.primaryColor),
                                            SizedBox(width: 4),
                                            Text(
                                              comment.username,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: provider.primaryColor,
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              '(محلي) ${_formatDateTime(comment.createdAt)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          comment.comment,
                                          style: _bodyStyle,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                    SizedBox(height: 24),

                    // Thumbnail gallery
                    if (images.length > 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معرض الصور',
                            style: _subtitleStyle,
                          ),
                          SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  // Show full-size image
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: provider.accentColor
                                            .withOpacity(0.3)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image(
                                      image:
                                          NetworkImageWithRetry(images[index]),
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child:
                                                Container(color: Colors.white),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Action button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: provider.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 61, 146),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Action to use the offer
                  Navigator.pop(context);
                },
                child: Text(
                  'الاستفادة من العرض',
                  style: _buttonStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced filter dialog
  void _showFilterDialog(HomeScreenProvider provider) {
    _logger.i("Showing filter dialog");
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: provider.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'تصفية العروض',
                    style: _titleStyle,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(),

              // Filter options
              Consumer<HomeScreenProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      _buildFilterOption(
                        title: 'العروض النشطة فقط',
                        subtitle: 'عرض العروض المتاحة حالياً فقط',
                        value: provider.activeOnly,
                        onChanged: (v) {
                          _logger.i("Changed active only filter to: $v");
                          provider.updateFilter(activeOnly: v);
                        },
                        provider: provider,
                      ),
                      _buildFilterOption(
                        title: 'الأحدث أولاً',
                        subtitle: 'ترتيب العروض حسب تاريخ الإضافة',
                        value: provider.orderByDate,
                        onChanged: (v) {
                          _logger.i("Changed order by date to: $v");
                          if (v) {
                            provider.updateFilter(
                              orderByDate: true,
                              orderByExpiry: false,
                            );
                          } else {
                            provider.updateFilter(orderByDate: false);
                          }
                        },
                        provider: provider,
                      ),
                      _buildFilterOption(
                        title: 'الأقرب انتهاءً',
                        subtitle: 'ترتيب العروض حسب تاريخ الانتهاء',
                        value: provider.orderByExpiry,
                        onChanged: (v) {
                          _logger.i("Changed order by expiry to: $v");
                          if (v) {
                            provider.updateFilter(
                              orderByExpiry: true,
                              orderByDate: false,
                            );
                          } else {
                            provider.updateFilter(orderByExpiry: false);
                          }
                        },
                        provider: provider,
                      ),
                      _buildFilterOption(
                        title: 'ترتيب تنازلي',
                        subtitle: 'عكس ترتيب العروض',
                        value: provider.descending,
                        onChanged: (v) {
                          _logger.i("Changed descending order to: $v");
                          provider.updateFilter(descending: v);
                        },
                        provider: provider,
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: BorderSide(color: provider.primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: provider.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      _logger.i("Filter canceled");
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.primaryColor,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'تطبيق',
                      style: _buttonStyle,
                    ),
                    onPressed: () {
                      _logger.i("Filter applied");
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Filter option
  Widget _buildFilterOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required HomeScreenProvider provider,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: provider.textDarkColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: _smallStyle,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: provider.accentColor,
          ),
        ],
      ),
    );
  }

  // Helper methods
  int _calculateDaysRemaining(Timestamp expiryDate) {
    final now = DateTime.now();
    final expiry = expiryDate.toDate();
    return expiry.difference(now).inDays;
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }
}
