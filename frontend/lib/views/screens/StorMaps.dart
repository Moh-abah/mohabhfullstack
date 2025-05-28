import 'package:ain_frontend/viewmodels/Profile_Store_Provider.dart';
import 'package:ain_frontend/views/widgets/BottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/Store_Map_Provider.dart';
import '../widgets/custom_search_bar.dart';
import '../../config/style.dart';

class Stormaps extends StatefulWidget {
  static final GlobalKey<_StormapsState> storeListKey =
      GlobalKey<_StormapsState>();
  final String? merchantId;

  const Stormaps({Key? key, this.merchantId}) : super(key: key);

  @override
  State<Stormaps> createState() => _StormapsState();
}

class _StormapsState extends State<Stormaps>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Logger _logger = Logger();
  final TextEditingController _searchController = TextEditingController();

  // تتبع حالة البحث
  bool _isSearching = false;

  // تحكم في حالة السحب للنتائج
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // استخدام مزود واحد للتطبيق بأكمله
  late StoreListProvider _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<StoreListProvider>(context, listen: false);
      _provider.initializeLocationAndStores();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  // فتح خرائط جوجل للملاحة إلى المتجر المحدد
  Future<void> _openGoogleMapsNavigation(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _logger.e('لا يمكن فتح خرائط جوجل');
    }
  }

  Widget _buildMapView(BuildContext context) {
    return Consumer<StoreListProvider>(
      builder: (context, provider, _) {
        final LatLng initialPosition =
            provider.userLocation ?? provider.defaultLocation;

        return Container(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GoogleMap(
                style: customMapStyle,
                key: const Key('my_google_map'),
                onMapCreated: (controller) {
                  provider.mapController = controller;
                  _logger.i('🗺️ تم إنشاء الخريطة بنجاح');
                },
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 13.0,
                ),
                cameraTargetBounds: CameraTargetBounds(
                  LatLngBounds(
                    southwest: const LatLng(12.0, 42.0),
                    northeast: const LatLng(19.0, 55.0),
                  ),
                ),
                minMaxZoomPreference: const MinMaxZoomPreference(0, 40),
                markers: provider.buildMarkers(provider, context),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onCameraMove: (position) async {
                  provider.mapState.setLastCameraPosition(position);
                },
              ),

              // أزرار التحكم (موقعي وخرائط جوجل)
              Positioned(
                right: 8,
                // رفع الأزرار لتجنب تداخلها مع نتائج البحث
                bottom: _isSearching
                    ? MediaQuery.of(context).size.height * 0.35
                    : MediaQuery.of(context).size.height * 0.12,
                child: Column(
                  children: [
                    // زر الموقع الحالي
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildMapButton(
                        icon: Icons.my_location,
                        onPressed: () => provider.moveToUserLocation(),
                        color: provider.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // زر فتح خرائط جوجل (يظهر فقط عند تحديد متجر)
                    if (provider.getSelectedStoreId != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildMapButton(
                          icon: Icons.directions,
                          onPressed: () {
                            final selectedStore = provider.stores.firstWhere(
                              (store) =>
                                  store.id == provider.getSelectedStoreId,
                              orElse: () => provider.stores.first,
                            );
                            _openGoogleMapsNavigation(
                              double.parse(selectedStore.latitude.toString()),
                              double.parse(selectedStore.longitude.toString()),
                            );
                          },
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 24, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // لازم للـ AutomaticKeepAliveClientMixin

    return ChangeNotifierProvider(
      create: (context) => StoreListProvider(
        reviewsState: Provider.of<ReviewsState>(context, listen: false),
      )..initializeLocationAndStores(),
      child: Scaffold(
        appBar: null,
        body: Consumer<StoreListProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }

            return Stack(
              children: [
                // خريطة جوجل
                Positioned.fill(
                  child: _buildMapView(context),
                ),

                // شريط البحث
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomSearchBar(
                      controller: _searchController,
                      onSearch: (query) {
                        provider.searchStores(query);
                        setState(() {
                          _isSearching = query.isNotEmpty;
                        });
                      },
                      onClear: () {
                        _searchController.clear();
                        provider.clearSearch();
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    ),
                  ),
                ),

                // نتائج البحث - تظهر فقط عند البحث
                if (_isSearching &&
                    provider.filteredStores.isNotEmpty &&
                    provider.mapState.userLocation != null)
                  _buildSearchResultsSheetWrapper(
                    provider: provider,
                    context: context,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // دالة جديدة لتغليف نتائج البحث وإضافة مؤشر سحب دائم
  Widget _buildSearchResultsSheetWrapper({
    required StoreListProvider provider,
    required BuildContext context,
  }) {
    return Stack(
      children: [
        // نتائج البحث
        Positioned.fill(
          child: buildSearchResultsSheet(
            controller: _sheetController,
            stores: provider.filteredStores,
            userLocation: provider.mapState.userLocation!,
            context: context,
            onStoreSelected: (latLng, store) {
              provider.mapState.moveToLocation(latLng, zoom: 16);
              provider.storesState.setSelectedStoreId(store.id);
              setState(() {
                _isSearching = false;
              });
              provider.clearSearch();
            },
            onSortByDistance: provider.setSortByDistance,
            onSortByRating: provider.setSortByRating,
            sortByDistance: provider.sortByDistance,
            sortByRating: provider.sortByRating,
          ),
        ),

        // مؤشر سحب دائم في الأسفل (يظهر عندما يتم سحب النتائج للأسفل)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              // إعادة فتح نتائج البحث عند النقر على المؤشر
              _sheetController.animateTo(
                0.3,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
