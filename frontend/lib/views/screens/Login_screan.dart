import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/Login_VM.dart';
import 'Register_screen.dart';

class FinalLoginScreen extends StatefulWidget {
  const FinalLoginScreen({super.key});

  @override
  _FinalLoginScreenState createState() => _FinalLoginScreenState();
}

class _FinalLoginScreenState extends State<FinalLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameOrPhoneController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // نظام الألوان المطور
  final Color _primaryColor = const Color(0xFF3366CC); // أزرق أكثر حيوية
  final Color _accentColor = const Color(0xFFFF6B6B); // مرجاني أنيق
  final Color _backgroundColor = const Color(0xFFF4F7FC); // خلفية فاتحة

  @override
  void dispose() {
    _usernameOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinalLoginViewModel(),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: Consumer<FinalLoginViewModel>(
          builder: (context, loginViewModel, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  // التحقق التلقائي عند تفاعل المستخدم مع الحقول
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // شعار ديناميكي مع إمكانية التخصيص
                      _AnimatedLogo(primaryColor: _primaryColor),
                      const SizedBox(height: 30),
                      // عنوان بتأثير بارالاكس
                      _ParallaxText(
                        primaryColor: _primaryColor,
                        accentColor: _accentColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'سواء كنت تاجرًا أو عميلًا، أنت في المكان الصحيح',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontFamily: 'Poppins',
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // حقل إدخال "اسم المستخدم أو رقم الهاتف"
                      _GlassmorphicTextField(
                        controller: _usernameOrPhoneController,
                        label: 'اسم المستخدم أو رقم الهاتف',
                        icon: Icons.alternate_email_rounded,
                        primaryColor: _primaryColor,
                        // دالة التحقق من صحة الحقل
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال اسم المستخدم أو رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      // حقل إدخال كلمة المرور
                      _GlassmorphicTextField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        icon: Icons.lock_clock_rounded,
                        isPassword: true,
                        primaryColor: _primaryColor,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // زر الدخول مع تأثير ثلاثي الأبعاد
                      _HolographicButton(
                        isLoading: loginViewModel.isLoading,
                        onPressed: () {
                          // التحقق من صحة الحقول باستخدام Form
                          if (_formKey.currentState!.validate()) {
                            // إذا كانت كل الحقول تعبئت بالشكل الصحيح نقوم بتسجيل الدخول
                            loginViewModel.login(
                              context,
                              _usernameOrPhoneController.text.trim(),
                              _passwordController.text,
                            );
                          }
                        },
                        primaryColor: _primaryColor,
                        accentColor: _accentColor,
                      ),
                      const SizedBox(height: 25),
                      // روابط بتصميم حديث
                      _AnimatedAuthLinks(
                        primaryColor: _primaryColor,
                        onRegister: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --------------------------
// مكونات تصميمية مخصصة
// --------------------------

class _AnimatedLogo extends StatelessWidget {
  final Color primaryColor;

  const _AnimatedLogo({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [primaryColor.withOpacity(0.1), Colors.transparent],
                radius: 0.8,
              ),
            ),
          ),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (_, double value, __) {
              return Transform.scale(
                scale: value,
                child: ClipOval(
                  child: SizedBox(
                    width: 250, // تحديد العرض المطلوب
                    height: 250, // تحديد الطول المطلوب
                    child: Image.asset(
                      "assets/logo.png", // تغيير المسار للصورة الخاصة بك
                      fit: BoxFit.cover, // جعل الصورة تملأ المساحة بشكل مناسب
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GlassmorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final Color primaryColor;
  final String? Function(String?)? validator;

  const _GlassmorphicTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    required this.primaryColor,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey[800],
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.8)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        ),
      ),
    );
  }
}

class _HolographicButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color accentColor;

  const _HolographicButton({
    required this.isLoading,
    required this.onPressed,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [primaryColor, accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onPressed,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint_rounded,
                        size: 24, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'الدخول الآمن',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AnimatedAuthLinks extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onRegister;

  const _AnimatedAuthLinks({
    required this.primaryColor,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildLink('إنشاء حساب', onRegister, primaryColor),
        Text('•', style: TextStyle(color: Colors.grey[500])),
        _buildLink('نسيت كلمة المرور?', () {}, primaryColor),
      ],
    );
  }

  Widget _buildLink(String text, VoidCallback onTap, Color color) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 200),
      builder: (_, double value, __) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  decorationColor: color.withOpacity(0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ParallaxText extends StatelessWidget {
  final Color primaryColor;
  final Color accentColor;

  const _ParallaxText({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [primaryColor, accentColor],
        stops: const [0.3, 0.7],
      ).createShader(bounds),
      child: const Text(
        'مرحبًا في مجتمعك التجاري',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          fontFamily: 'Poppins',
          height: 1.2,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
