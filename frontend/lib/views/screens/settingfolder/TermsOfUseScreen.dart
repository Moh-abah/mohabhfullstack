import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showFab = false;
  bool _hasAccepted = false;

  final List<TermsSection> _sections = [
    TermsSection(
      title: 'قبول الشروط',
      icon: Icons.check_circle,
      content:
          'باستخدامك للتطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي من هذه الشروط، يرجى عدم استخدام التطبيق.\n\n'
          'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. ستكون التغييرات سارية فور نشرها على التطبيق. استمرارك في استخدام التطبيق بعد نشر التغييرات يعني موافقتك على الشروط المعدلة.',
      color: Colors.green,
    ),
    TermsSection(
      title: 'حقوق الملكية',
      icon: Icons.copyright,
      content:
          'جميع المحتويات المتاحة على التطبيق، بما في ذلك النصوص والرسومات والشعارات والصور ومقاطع الفيديو والبرامج، هي ملكية حصرية لنا أو لمرخصينا.\n\n'
          'لا يجوز نسخ أو إعادة إنتاج أو توزيع أو نشر أو تعديل أو استخدام أي من هذه المواد دون إذن كتابي مسبق منا.',
      color: Colors.blue,
    ),
    TermsSection(
      title: 'قواعد الاستخدام',
      icon: Icons.rule,
      content: 'عند استخدام التطبيق، أنت توافق على عدم:\n\n'
          '• استخدام التطبيق لأغراض غير قانونية\n'
          '• انتهاك حقوق الآخرين\n'
          '• نشر محتوى مسيء أو ضار\n'
          '• محاولة الوصول غير المصرح به إلى أنظمتنا\n'
          '• مشاركة بيانات حسابك مع الآخرين\n'
          '• استخدام التطبيق بطريقة قد تعطل أو تضر بالخدمة\n\n'
          'نحتفظ بالحق في إنهاء أو تقييد وصولك إلى التطبيق إذا انتهكت أيًا من هذه القواعد.',
      color: Colors.red,
    ),
    TermsSection(
      title: 'المسؤولية والتعويض',
      icon: Icons.gavel,
      content:
          'يتم توفير التطبيق "كما هو" دون أي ضمانات من أي نوع. لن نكون مسؤولين عن أي أضرار مباشرة أو غير مباشرة أو عرضية أو خاصة أو تبعية ناتجة عن استخدامك للتطبيق.\n\n'
          'أنت توافق على تعويضنا وحمايتنا من أي مطالبات أو خسائر أو التزامات، بما في ذلك الرسوم القانونية، الناشئة عن استخدامك للتطبيق أو انتهاكك لهذه الشروط.',
      color: Colors.purple,
    ),
    TermsSection(
      title: 'الروابط الخارجية',
      icon: Icons.link,
      content:
          'قد يحتوي التطبيق على روابط لمواقع ويب خارجية لا نتحكم فيها. لا نتحمل أي مسؤولية عن محتوى أو ممارسات الخصوصية أو سياسات هذه المواقع.\n\n'
          'توفير هذه الروابط لا يعني موافقتنا أو تأييدنا لهذه المواقع أو محتواها.',
      color: Colors.teal,
    ),
    TermsSection(
      title: 'القانون الحاكم',
      icon: Icons.balance,
      content:
          'تخضع هذه الشروط والأحكام وتفسر وفقًا لقوانين المملكة العربية السعودية، دون اعتبار لمبادئ تنازع القوانين.\n\n'
          'أي نزاع ينشأ عن أو يتعلق بهذه الشروط سيخضع للاختصاص القضائي الحصري للمحاكم المختصة في المملكة العربية السعودية.',
      color: Colors.amber,
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
        title: const Text('شروط الاستخدام'),
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
            icon: const Icon(Icons.print),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showPrintOptions(context);
            },
            tooltip: 'طباعة',
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
                : [Colors.red[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
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
                    // إضافة مساحة إضافية في الأسفل للزر الثابت
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              _buildAcceptButton(context),
            ],
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
      tag: 'terms_icon',
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
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rule,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'شروط وأحكام الاستخدام',
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
              'يرجى قراءة شروط وأحكام الاستخدام هذه بعناية قبل استخدام التطبيق. تحدد هذه الشروط القواعد والقيود المتعلقة باستخدام خدماتنا.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'باستخدامك للتطبيق، فإنك تقر بأنك قد قرأت وفهمت ووافقت على الالتزام بهذه الشروط.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
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

  Widget _buildExpandableSection(BuildContext context, TermsSection section) {
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
            'إذا كانت لديك أي أسئلة حول شروط الاستخدام، يرجى التواصل معنا:',
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

  Widget _buildAcceptButton(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _hasAccepted,
                    onChanged: (value) {
                      setState(() {
                        _hasAccepted = value ?? false;
                      });
                      HapticFeedback.lightImpact();
                    },
                    activeColor: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'أقر بأنني قرأت وفهمت وأوافق على شروط الاستخدام',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _hasAccepted
                        ? () {
                            HapticFeedback.mediumImpact();
                            _showAcceptanceConfirmation(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('موافق'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPrintOptions(BuildContext context) {
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
              'طباعة شروط الاستخدام',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.print,
                  color: Colors.blue,
                ),
              ),
              title: const Text('طباعة مباشرة'),
              subtitle: const Text('إرسال إلى طابعة متصلة'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('جاري البحث عن طابعات متاحة...')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.green,
                ),
              ),
              title: const Text('حفظ كملف PDF'),
              subtitle: const Text('تحميل نسخة PDF للطباعة لاحقًا'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جاري تحميل ملف PDF...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحميل شروط الاستخدام'),
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

  void _showAcceptanceConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الموافقة'),
        content: const Text(
          'أنت على وشك الموافقة على شروط وأحكام الاستخدام. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم قبول شروط الاستخدام بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
              // هنا يمكن تنفيذ الإجراء المناسب بعد الموافقة
              // مثل حفظ حالة الموافقة في التخزين المحلي
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

class TermsSection {
  final String title;
  final IconData icon;
  final String content;
  final Color color;

  TermsSection({
    required this.title,
    required this.icon,
    required this.content,
    required this.color,
  });
}
