import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showFab = false;

  final List<PrivacySection> _sections = [
    PrivacySection(
      title: 'جمع البيانات',
      icon: Icons.data_usage,
      content: 'نحن نجمع البيانات التالية:\n'
          '• البريد الإلكتروني\n'
          '• رقم الهاتف\n'
          '• بيانات الاستخدام\n'
          '• الموقع الجغرافي (اختياري)\n'
          '• معلومات الجهاز',
      color: Colors.blue,
    ),
    PrivacySection(
      title: 'استخدام البيانات',
      icon: Icons.security,
      content: 'نستخدم بياناتك للأغراض التالية:\n'
          '• تحسين خدماتنا\n'
          '• تخصيص تجربتك\n'
          '• التواصل معك\n'
          '• تقديم الدعم الفني\n'
          '• تحليل استخدام التطبيق',
      color: Colors.green,
    ),
    PrivacySection(
      title: 'مشاركة البيانات',
      icon: Icons.share,
      content: 'قد نشارك بياناتك مع:\n'
          '• مزودي الخدمة\n'
          '• شركاء الأعمال\n'
          '• الجهات القانونية عند الضرورة\n\n'
          'لن نبيع بياناتك الشخصية لأطراف ثالثة.',
      color: Colors.orange,
    ),
    PrivacySection(
      title: 'أمان البيانات',
      icon: Icons.shield,
      content: 'نتخذ إجراءات أمنية لحماية بياناتك:\n'
          '• التشفير\n'
          '• المصادقة الثنائية\n'
          '• مراقبة الوصول\n'
          '• تحديثات أمنية دورية\n'
          '• نسخ احتياطي آمن',
      color: Colors.purple,
    ),
    PrivacySection(
      title: 'حقوقك',
      icon: Icons.gavel,
      content: 'لديك الحق في:\n'
          '• الوصول إلى بياناتك\n'
          '• تصحيح بياناتك\n'
          '• حذف بياناتك\n'
          '• الاعتراض على معالجة بياناتك\n'
          '• سحب موافقتك في أي وقت',
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _animationController.forward();
  }

  void _scrollListener() {
    if (_scrollController.offset > 100 && !_showFab) {
      setState(() {
        _showFab = true;
      });
    } else if (_scrollController.offset <= 100 && _showFab) {
      setState(() {
        _showFab = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('سياسة الخصوصية'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showShareOptions(context);
            },
            tooltip: 'مشاركة',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey[900]!, Colors.black]
                : [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildIntroduction(context),
                const SizedBox(height: 32),
                ..._buildSections(context),
                const SizedBox(height: 32),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutQuad,
                );
              },
              child: const Icon(Icons.arrow_upward),
              tooltip: 'العودة للأعلى',
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Hero(
      tag: 'privacy_icon',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 54, 203).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 60,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'سياسة الخصوصية الخاصة بنا',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'آخر تحديث: 10 أبريل 2025',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'مقدمة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'نحن نحترم خصوصيتك ونتعهد بحماية بياناتك الشخصية. تصف سياسة الخصوصية هذه كيفية جمع واستخدام ومشاركة بياناتك عند استخدام تطبيقنا.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'بمجرد استخدامك للتطبيق، فإنك توافق على جمع ومعالجة بياناتك وفقًا لهذه السياسة.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context) {
    final List<Widget> sectionWidgets = [];

    for (int i = 0; i < _sections.length; i++) {
      final section = _sections[i];
      //final delay = i * 0.2;

      sectionWidgets.add(
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuad,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: _buildExpandableSection(context, section),
        ),
      );

      sectionWidgets.add(const SizedBox(height: 16));
    }

    return sectionWidgets;
  }

  Widget _buildExpandableSection(BuildContext context, PrivacySection section) {
    return ExpansionTile(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: section.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              section.icon,
              color: section.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      childrenPadding: const EdgeInsets.all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      collapsedBackgroundColor: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).cardColor,
      onExpansionChanged: (expanded) {
        if (expanded) {
          HapticFeedback.lightImpact();
        }
      },
      children: [
        Text(
          section.content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'للتواصل',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'إذا كانت لديك أي أسئلة حول سياسة الخصوصية، يرجى التواصل معنا:',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              // تنفيذ إرسال بريد إلكتروني
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'musst92@gmail.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              // تنفيذ الاتصال
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '+967 780090882',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // تنفيذ تحميل النسخة الكاملة
                _showDownloadOptions(context);
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('تحميل النسخة الكاملة'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'مشاركة سياسة الخصوصية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.copy,
                  label: 'نسخ الرابط',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الرابط')),
                    );
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.email,
                  label: 'البريد',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.message,
                  label: 'رسالة',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.more_horiz,
                  label: 'المزيد',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحميل سياسة الخصوصية'),
        content: const Text(
          'اختر صيغة التحميل المناسبة:',
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري تحميل النسخة PDF')),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري تحميل النسخة النصية')),
              );
            },
            icon: const Icon(Icons.text_snippet),
            label: const Text('نص'),
          ),
        ],
      ),
    );
  }
}

class PrivacySection {
  final String title;
  final IconData icon;
  final String content;
  final Color color;

  PrivacySection({
    required this.title,
    required this.icon,
    required this.content,
    required this.color,
  });
}
