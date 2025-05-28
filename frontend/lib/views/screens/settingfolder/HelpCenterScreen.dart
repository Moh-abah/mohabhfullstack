import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late TextEditingController _searchController;
  String _searchQuery = '';

  final List<HelpCategory> _categories = [
    HelpCategory(
      title: 'الحساب والتسجيل',
      icon: Icons.person,
      color: Colors.blue,
      questions: [
        HelpQuestion(
          question: 'كيف يمكنني إنشاء حساب جديد؟',
          answer: 'يمكنك إنشاء حساب جديد باتباع الخطوات التالية:\n\n'
              '1. انقر على "تسجيل" في الشاشة الرئيسية\n'
              '2. أدخل اسم المستخدم ورقم هاتفك\n'
              '3. أنشئ كلمة مرور قوية\n'
              '4. أكمل معلومات ملفك الشخصي\n'
              '5. تحقق من صحه رقم الهاتف\n\n'
              'بعد إتمام هذه الخطوات، سيكون حسابك جاهزًا للاستخدام.',
        ),
        HelpQuestion(
          question: 'نسيت كلمة المرور، كيف يمكنني استعادتها؟',
          answer: 'لاستعادة كلمة المرور:\n\n'
              '1. انقر على "نسيت كلمة المرور" في شاشة تسجيل الدخول\n'
              '2. أدخل بريدك الإلكتروني المسجل\n'
              '3. ستتلقى رسالة بريد إلكتروني تحتوي على رابط إعادة تعيين كلمة المرور\n'
              '4. انقر على الرابط وأدخل كلمة مرور جديدة\n\n'
              'إذا لم تتلق البريد الإلكتروني، تحقق من مجلد البريد العشوائي أو اتصل بالدعم الفني.',
        ),
        HelpQuestion(
          question: 'كيف يمكنني تغيير معلومات حسابي؟',
          answer: 'لتغيير معلومات حسابك:\n\n'
              '1. انتقل إلى "الإعدادات" من القائمة الرئيسية\n'
              '2. اختر "الملف الشخصي"\n'
              '3. انقر على "تعديل" بجانب المعلومات التي ترغب في تغييرها\n'
              '4. أدخل المعلومات الجديدة\n'
              '5. انقر على "حفظ" لتأكيد التغييرات\n\n'
              'ملاحظة: بعض المعلومات مثل البريد الإلكتروني قد تتطلب إعادة التحقق.',
        ),
      ],
    ),
    HelpCategory(
      title: 'المتاجر والعروض',
      icon: Icons.store,
      color: Colors.green,
      questions: [
        HelpQuestion(
          question: 'كيف يمكنني البحث عن متاجر قريبة؟',
          answer: 'للبحث عن متاجر قريبة:\n\n'
              '1. انتقل إلى شاشة "المتاجر" من القائمة الرئيسية\n'
              '2. اسمح للتطبيق بالوصول إلى موقعك\n'
              '3. ستظهر المتاجر القريبة منك على الخريطة\n'
              '4. يمكنك استخدام شريط البحث للبحث عن متاجر محددة\n'
              '5. انقر على أيقونة التصفية لتصفية النتائج حسب الفئة أو المسافة\n\n'
              'يمكنك أيضًا النقر على أي متجر لعرض المزيد من التفاصيل والعروض المتاحة.',
        ),
        HelpQuestion(
          question: 'كيف يمكنني الاستفادة من العروض؟',
          answer: 'للاستفادة من العروض:\n\n'
              '1. تصفح العروض المتاحة في الشاشة الرئيسية أو صفحة المتجر\n'
              '2. انقر على العرض الذي يهمك لعرض التفاصيل\n'
              '3. انقر على "الاستفادة من العرض"\n'
              '4. سيتم إنشاء رمز QR أو رمز ترويجي\n'
              '5. قدم هذا الرمز في المتجر عند الشراء\n\n'
              'بعض العروض قد تكون محدودة بفترة زمنية أو كمية معينة، لذا تأكد من الاستفادة منها قبل انتهائها.',
        ),
        HelpQuestion(
          question: 'كيف يمكنني تقييم متجر أو عرض؟',
          answer: 'لتقييم متجر أو عرض:\n\n'
              '1. انتقل إلى صفحة المتجر أو العرض\n'
              '2. انقر على "تقييم" أو أيقونة النجوم\n'
              '3. اختر التقييم المناسب (من 1 إلى 5 نجوم)\n'
              '4. أضف تعليقًا (اختياري)\n'
              '5. انقر على "إرسال"\n\n'
              'تساعد تقييماتك المستخدمين الآخرين في اتخاذ قرارات أفضل وتساعد المتاجر في تحسين خدماتها.',
        ),
      ],
    ),
    HelpCategory(
      title: 'الدفع والمعاملات',
      icon: Icons.payment,
      color: Colors.purple,
      questions: [
        HelpQuestion(
          question: 'ما هي طرق الدفع المتاحة؟',
          answer: 'نوفر عدة طرق للدفع:\n\n'
              '• بطاقات الائتمان والخصم (فيزا، ماستركارد، مدى)\n'
              '• المحافظ الإلكترونية (Apple Pay، Google Pay، STC Pay)\n'
              '• التحويل البنكي\n'
              '• الدفع عند الاستلام (لبعض المتاجر)\n\n'
              'يمكنك إضافة وإدارة طرق الدفع الخاصة بك من خلال قسم "طرق الدفع" في الإعدادات.',
        ),
        HelpQuestion(
          question: 'كيف يمكنني استرداد مبلغ معاملة؟',
          answer: 'لاسترداد مبلغ معاملة:\n\n'
              '1. انتقل إلى "سجل المعاملات" في قائمة الإعدادات\n'
              '2. حدد المعاملة التي ترغب في استردادها\n'
              '3. انقر على "طلب استرداد"\n'
              '4. اختر سبب الاسترداد\n'
              '5. أضف أي تفاصيل إضافية\n'
              '6. انقر على "إرسال الطلب"\n\n'
              'سيتم مراجعة طلبك وإبلاغك بالقرار خلال 3-5 أيام عمل. قد تختلف سياسات الاسترداد حسب المتجر.',
        ),
      ],
    ),
    HelpCategory(
      title: 'المشاكل التقنية',
      icon: Icons.build,
      color: Colors.orange,
      questions: [
        HelpQuestion(
          question: 'التطبيق يتوقف فجأة، ماذا أفعل؟',
          answer: 'إذا كان التطبيق يتوقف فجأة، جرب الخطوات التالية:\n\n'
              '1. أعد تشغيل التطبيق\n'
              '2. تأكد من تحديث التطبيق إلى أحدث إصدار\n'
              '3. أعد تشغيل جهازك\n'
              '4. تحقق من اتصالك بالإنترنت\n'
              '5. امسح ذاكرة التخزين المؤقت للتطبيق\n'
              '6. إذا استمرت المشكلة، حاول إلغاء تثبيت التطبيق وإعادة تثبيته\n\n'
              'إذا لم تحل هذه الخطوات المشكلة، يرجى الاتصال بالدعم الفني مع وصف المشكلة بالتفصيل.',
        ),
        HelpQuestion(
          question: 'لا يمكنني تحميل الصور، ما الحل؟',
          answer: 'إذا كنت تواجه مشكلة في تحميل الصور:\n\n'
              '1. تحقق من اتصالك بالإنترنت\n'
              '2. تأكد من منح التطبيق صلاحية الوصول إلى الصور\n'
              '3. تحقق من مساحة التخزين المتاحة على جهازك\n'
              '4. تأكد من أن حجم الصورة لا يتجاوز 10 ميجابايت\n'
              '5. جرب تحميل الصورة بتنسيق مختلف (JPG أو PNG)\n\n'
              'إذا استمرت المشكلة، يمكنك إرسال تقرير خطأ من خلال قسم "الإبلاغ عن مشكلة" في الإعدادات.',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _searchController = TextEditingController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<HelpCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _categories;
    }

    return _categories
        .map((category) {
          final filteredQuestions = category.questions.where((question) {
            return question.question
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                question.answer
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredQuestions.isEmpty) {
            return null;
          }

          return HelpCategory(
            title: category.title,
            icon: category.icon,
            color: category.color,
            questions: filteredQuestions,
          );
        })
        .where((category) => category != null)
        .cast<HelpCategory>()
        .toList();
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
        title: const Text('مركز المساعدة'),
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
            icon: const Icon(Icons.contact_support),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showContactOptions(context);
            },
            tooltip: 'اتصل بنا',
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
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(context),
              Expanded(
                child: _filteredCategories.isEmpty
                    ? _buildNoResultsFound(context)
                    : _buildCategoriesList(context),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showChatSupportDialog(context);
        },
        icon: const Icon(Icons.chat),
        label: const Text('محادثة مباشرة'),
        tooltip: 'تحدث مع فريق الدعم',
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Hero(
      tag: 'help_icon',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
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
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'كيف يمكننا مساعدتك؟',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ابحث في الأسئلة الشائعة أو تواصل مع فريق الدعم',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث عن سؤال...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                      HapticFeedback.lightImpact();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            // يمكن إضافة إجراء إضافي عند الضغط على زر البحث في لوحة المفاتيح
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 800 + (index * 100)),
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
          child: _buildCategoryCard(context, category),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, HelpCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${category.questions.length} سؤال',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            HapticFeedback.lightImpact();
          }
        },
        children: category.questions.map((question) {
          return _buildQuestionItem(context, question, category.color);
        }).toList(),
      ),
    );
  }

  Widget _buildQuestionItem(
      BuildContext context, HelpQuestion question, Color color) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAnswerDialog(context, question, color);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              Icons.question_answer,
              color: color.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لم يتم العثور على نتائج',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب كلمات بحث مختلفة أو تواصل مع فريق الدعم',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showContactOptions(context);
            },
            icon: const Icon(Icons.contact_support),
            label: const Text('تواصل مع الدعم'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAnswerDialog(
      BuildContext context, HelpQuestion question, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.question_answer,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.answer,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'هل كانت هذه الإجابة مفيدة؟',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('شكراً لتقييمك الإيجابي!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.thumb_up),
                                label: const Text('نعم'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                  _showFeedbackDialog(context, question);
                                },
                                icon: const Icon(Icons.thumb_down),
                                label: const Text('لا'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        _showContactOptions(context);
                      },
                      icon: const Icon(Icons.contact_support),
                      label: const Text('تحتاج مساعدة إضافية؟'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _showFeedbackDialog(BuildContext context, HelpQuestion question) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ما الذي لم يكن مفيداً؟'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: 'أخبرنا كيف يمكننا تحسين هذه الإجابة...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
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
              if (feedbackController.text.isNotEmpty) {
                HapticFeedback.mediumImpact();
                // هنا يمكن إضافة كود لإرسال التعليق إلى الخادم
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('شكراً لملاحظاتك! سنعمل على تحسين المحتوى.'),
                    backgroundColor: Colors.blue,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى كتابة ملاحظاتك قبل الإرسال'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
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
              'تواصل معنا',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildContactOption(
              context,
              icon: Icons.phone,
              title: 'اتصل بنا',
              subtitle: '+966 12 345 6789',
              color: Colors.green,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                // هنا يمكن إضافة كود لفتح تطبيق الهاتف مع الرقم
              },
            ),
            const Divider(height: 32),
            _buildContactOption(
              context,
              icon: Icons.email,
              title: 'راسلنا عبر البريد الإلكتروني',
              subtitle: 'support@example.com',
              color: Colors.blue,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                // هنا يمكن إضافة كود لفتح تطبيق البريد الإلكتروني
              },
            ),
            const Divider(height: 32),
            _buildContactOption(
              context,
              icon: Icons.chat,
              title: 'محادثة مباشرة',
              subtitle: 'متاح على مدار الساعة',
              color: Colors.purple,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                _showChatSupportDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showChatSupportDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final List<ChatMessage> messages = [
            ChatMessage(
              text: 'مرحباً! كيف يمكنني مساعدتك اليوم؟',
              isUser: false,
              time: DateTime.now().subtract(const Duration(minutes: 1)),
            ),
          ];

          void addMessage(String text) {
            if (text.trim().isEmpty) return;

            setState(() {
              messages.add(ChatMessage(
                text: text,
                isUser: true,
                time: DateTime.now(),
              ));
            });

            messageController.clear();

            // تمرير القائمة إلى آخر رسالة
            Future.delayed(const Duration(milliseconds: 100), () {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });

            // محاكاة رد من المساعد بعد ثانية واحدة
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                messages.add(ChatMessage(
                  text:
                      'شكراً لتواصلك معنا. سيقوم أحد ممثلي خدمة العملاء بالرد عليك قريباً.',
                  isUser: false,
                  time: DateTime.now(),
                ));
              });

              // تمرير القائمة إلى آخر رسالة
              Future.delayed(const Duration(milliseconds: 100), () {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });
            });
          }

          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.support_agent,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'محادثة مع فريق الدعم',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildChatMessage(context, message);
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: 'اكتب رسالتك هنا...',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (value) {
                            addMessage(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: () {
                          addMessage(messageController.text);
                        },
                        mini: true,
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatMessage(BuildContext context, ChatMessage message) {
    final timeString =
        '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.blue,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser ? const Radius.circular(0) : null,
                  bottomLeft: !message.isUser ? const Radius.circular(0) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class HelpCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<HelpQuestion> questions;

  const HelpCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

class HelpQuestion {
  final String question;
  final String answer;

  const HelpQuestion({
    required this.question,
    required this.answer,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}
