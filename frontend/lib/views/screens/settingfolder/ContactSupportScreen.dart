import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  final List<ContactMethod> _contactMethods = [
    ContactMethod(
      icon: Icons.email,
      title: 'البريد الإلكتروني',
      subtitle: 'musst92@gmail.com',
      color: Colors.blue,
      action: ContactAction.copy,
      value: 'musst92@gmail.com',
    ),
    ContactMethod(
      icon: Icons.phone,
      title: 'رقم الهاتف',
      subtitle: '+967 780090882',
      color: Colors.green,
      action: ContactAction.call,
      value: '+967780090882',
    ),
    ContactMethod(
      icon: Icons.phone_android,
      title: 'رقم الهاتف البديل',
      subtitle: '+967 770006606',
      color: Colors.teal,
      action: ContactAction.call,
      value: '+967770006606',
    ),
    ContactMethod(
      icon: Icons.chat,
      title: 'المحادثة المباشرة',
      subtitle: 'متاح على مدار الساعة',
      color: Colors.purple,
      action: ContactAction.chat,
      value: '',
    ),
    ContactMethod(
      icon: Icons.language,
      title: 'الموقع الإلكتروني',
      subtitle: 'www.example.com',
      color: Colors.orange,
      action: ContactAction.website,
      value: 'https://www.example.com',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
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
        title: const Text('التواصل مع الدعم الفني'),
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey[900]!, Colors.black]
                : [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildContactMethods(context),
                const SizedBox(height: 32),
                _buildContactForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Hero(
      tag: 'support_icon',
      child: Container(
        width: double.infinity,
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
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'هل لديك مشكلة؟ تواصل معنا!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'فريق الدعم الفني متاح لمساعدتك على مدار الساعة',
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

  Widget _buildContactMethods(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 16),
          child: Text(
            'طرق التواصل',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...List.generate(_contactMethods.length, (index) {
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
            child: _buildContactMethodCard(context, _contactMethods[index]),
          );
        }),
      ],
    );
  }

  Widget _buildContactMethodCard(BuildContext context, ContactMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleContactMethodTap(method),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: method.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                method.icon,
                color: method.color,
                size: 24,
              ),
            ),
            title: Text(
              method.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              method.subtitle,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            trailing: _buildActionIcon(method),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(ContactMethod method) {
    IconData iconData;
    Color iconColor;

    switch (method.action) {
      case ContactAction.copy:
        iconData = Icons.copy;
        iconColor = Colors.blue;
        break;
      case ContactAction.call:
        iconData = Icons.phone_forwarded;
        iconColor = Colors.green;
        break;
      case ContactAction.chat:
        iconData = Icons.chat;
        iconColor = Colors.purple;
        break;
      case ContactAction.website:
        iconData = Icons.open_in_new;
        iconColor = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  void _handleContactMethodTap(ContactMethod method) {
    HapticFeedback.mediumImpact();

    switch (method.action) {
      case ContactAction.copy:
        Clipboard.setData(ClipboardData(text: method.value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ ${method.title} إلى الحافظة'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case ContactAction.call:
        _launchUrl('tel:${method.value}');
        break;
      case ContactAction.chat:
        _showChatDialog(context);
        break;
      case ContactAction.website:
        _launchUrl(method.value);
        break;
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await url_launcher.launchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الرابط'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.chat, color: Colors.purple),
            SizedBox(width: 8),
            Text('المحادثة المباشرة'),
          ],
        ),
        content: const Text(
          'سيتم توجيهك إلى المحادثة المباشرة مع فريق الدعم الفني. هل تريد المتابعة؟',
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
              // هنا يمكن إضافة كود لفتح نافذة المحادثة المباشرة
              // أو الانتقال إلى شاشة المحادثة
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('بدء المحادثة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.message, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'أرسل لنا رسالة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إرسال استفسارك أو مشكلتك وسنقوم بالرد عليك في أقرب وقت ممكن',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'الرسالة',
                      prefixIcon: Icon(Icons.message),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الرسالة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitForm,
                      icon: _isSubmitting
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                          _isSubmitting ? 'جاري الإرسال...' : 'إرسال الرسالة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      HapticFeedback.mediumImpact();

      // محاكاة إرسال البيانات إلى الخادم
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          // إظهار رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال رسالتك بنجاح! سنتواصل معك قريباً.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );

          // إعادة تعيين النموذج
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
        }
      });
    }
  }
}

enum ContactAction {
  copy,
  call,
  chat,
  website,
}

class ContactMethod {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final ContactAction action;
  final String value;

  const ContactMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.action,
    required this.value,
  });
}
