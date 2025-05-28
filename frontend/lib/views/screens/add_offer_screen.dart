import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/add_offer_provider.dart';

class AddOfferScreen extends StatefulWidget {
  final String storeName;
  const AddOfferScreen({required this.storeName});

  @override
  _AddOfferScreenState createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AddOfferProvider>(context, listen: false);
      provider.setStoreName(widget.storeName);
      String? storeName = provider.storeName;
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titalstoreName = context.watch<AddOfferProvider>().storeName;
    return ChangeNotifierProvider(
      create: (_) => AddOfferProvider(),
      child: Consumer<AddOfferProvider>(
        builder: (context, provider, _) {
          if (provider.merchantId == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(titalstoreName!),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(context, provider, titalstoreName),
                  ),
                ),
                if (provider.error != null)
                  _buildErrorBanner(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AddOfferProvider provider,
    String? storeName,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAnimatedSection(
                    'صور العرض',
                    buildImageSection(context, provider),
                  ),
                  _buildAnimatedSection(
                    'تفاصيل العرض',
                    _buildDescriptionField(provider),
                  ),
                  _buildAnimatedSection(
                    'مدة العرض',
                    _buildDurationDropdown(provider),
                  ),
                ],
              ),
            ),
          ),
          _buildSubmitButton(context, provider, storeName),
        ],
      ),
    );
  }

  Widget buildImageSection(BuildContext context, AddOfferProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildImagePreview(provider),
          Divider(color: Colors.grey[200], height: 1),
          TextButton.icon(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('إضافة صور'),
            onPressed: () => provider.pickImageWITHVIEW(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(AddOfferProvider provider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: provider.images.isEmpty
          ? Container(
              key: const ValueKey('empty'),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined,
                        size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'لا توجد صور مضافة',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              key: ValueKey(provider.images.length),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: provider.images.length,
                itemBuilder: (context, index) => Hero(
                  tag: 'image-$index',
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                          image: DecorationImage(
                            image: MemoryImage(provider.images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => provider.removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDescriptionField(AddOfferProvider provider) {
    return TextFormField(
      controller: provider.descriptionController,
      decoration: InputDecoration(
        hintText: 'اكتب تفاصيل العرض هنا...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 4,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDurationDropdown(AddOfferProvider provider) {
    return DropdownButtonFormField<int>(
      value: provider.selectedDuration,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
      ),
      items: const [
        DropdownMenuItem(value: 7, child: Text('أسبوع واحد')),
        DropdownMenuItem(value: 14, child: Text('أسبوعين')),
        DropdownMenuItem(value: 21, child: Text('3 أسابيع')),
        DropdownMenuItem(value: 28, child: Text('4 أسابيع')),
        DropdownMenuItem(value: 35, child: Text('5 أسابيع')),
        DropdownMenuItem(value: 42, child: Text('6 أسابيع')),
      ],
      onChanged: (value) => provider.setDuration(value),
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
      ),
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
      dropdownColor: Colors.white,
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    AddOfferProvider provider,
    String? storeName,
  ) {
    print(storeName);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () => _handleSubmit(context, provider, storeName),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: provider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'نشر العرض',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, AddOfferProvider provider) {
    if (provider.error == null) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Colors.red[600],
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  // Clear error
                  provider.setError('');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: child,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    AddOfferProvider provider,
    String? storeName,
  ) async {
    // تحقق من أن اسم المتجر موجود قبل المتابعة
    if (storeName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ اسم المتجر غير متوفر!')),
      );
      return; // لا تتابع إذا كان اسم المتجر غير مُعين
    } else {
      final success = await provider.submitOffer(storeName);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نشر العرض بنجاح! 🎉')),
        );
        Navigator.pop(context);
      } else {
        // في حالة فشل نشر العرض، اعرض رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في نشر العرض!')),
        );
      }
    }
  }
}
