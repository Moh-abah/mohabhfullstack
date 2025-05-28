import 'package:ain_frontend/ServicesAPI/user_type_service.dart';
import 'package:ain_frontend/viewmodels/state_bottom.dart';
import 'package:ain_frontend/views/screens/MainScreen.dart';

import 'package:ain_frontend/views/screens/create_store_screen.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../models/user.dart';

import '../../utils/SecureStorageHelper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userType = 'customer';
  bool _isLoading = false;
  late Color _passwordStrengthColor;

  final Dio _dio = Dio();
  final SecureStorageHelper _storage = SecureStorageHelper();
  static const String _baseUrl = 'https://myapptestes.onrender.com';

  // نظام الألوان
  final Color _primaryColor = const Color(0xFF2A5C8D);
  final Color _accentColor = const Color(0xFFFFA726);
  final Color _backgroundColor = const Color(0xFFF8F9FA);

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordStrengthColor = _primaryColor;
    _passwordController.addListener(() {
      setState(() {
        _passwordStrengthColor =
            _calculatePasswordStrength(_passwordController.text);
      });
    });
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        '$_baseUrl/api/users/register/',
        data: {
          'username': _usernameController.text,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
          'user_type': _userType,
        },
      );

      if (response.statusCode == 201) {
        await _handleSuccessfulRegistration(response.data);
        _navigateAfterRegistration();
      } else {
        _showErrorSnackbar('فشل في إنشاء الحساب: ${response.data}');
      }
    } on DioException catch (e) {
      _showErrorSnackbar(e.response?.data['message'] ?? 'حدث خطأ غير متوقع');
    } catch (e) {
      _showErrorSnackbar('حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _calculatePasswordStrength(String password) {
    if (password.isEmpty) return _primaryColor; // الحالة الافتراضية
    if (password.length < 6) {
      return Colors.red; // ضعيفة
    } else if (password.length < 8) {
      return Colors.yellow; // متوسطة
    } else {
      return Colors.green; // قوية
    }
  }

  Future<void> _handleSuccessfulRegistration(Map<String, dynamic> data) async {
    await _storage.write('jwt_token', data['access']);
    await _storage.write('refresh_token', data['refresh']);

    final user = User(
      id: data['id'],
      username: _usernameController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      userType: _userType,
    );

    await SecureStorageHelper.saveUser(user);
    final navManager = BottomNavManager();
    navManager.setUserType(_userType);

    // تحديث نوع المستخدم في الخدمة
    final userTypeService = UserTypeService();
    await userTypeService.updateUserTypeAfterAuth(_userType);

    // إعادة تعيين مؤشر التنقل
    navManager.navigateTo(0);

    await UserTypeService().updateUserTypeAfterAuth(_userType);

    _showSuccessSnackbar('تم إنشاء الحساب بنجاح!');
  }

  void _navigateAfterRegistration() {
    if (_userType == 'merchant') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CreateStoreScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 22,
            )),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundColor, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      _AnimatedAuthIcon(primaryColor: _primaryColor),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'اسم المستخدم',
                        icon: Icons.person_pin_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال اسم المستخدم';
                          }
                          final usernameRegex = RegExp(r'^[A-Za-z]+$');
                          if (!usernameRegex.hasMatch(value.trim())) {
                            return 'يجب ان يكون اسم المستخدم عباره عن userme مثل mohabh';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _nameController,
                        label: 'الاسم الكامل',
                        icon: Icons.badge_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال الاسم الكامل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'رقم الهاتف',
                        icon: Icons.phone_iphone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          // التأكد من أن رقم الهاتف مكون من 9 أرقام ويبدأ بأحد البادئات المحددة
                          final phoneRegex = RegExp(r'^(77|73|71|78)[0-9]{7}$');
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return 'رقم الهاتف غير صحيح ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        icon: Icons.lock_clock_rounded,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          // هنا يمكن إضافة شروط إضافية إذا لزم الأمر
                          return null;
                        },
                        borderColor: _passwordStrengthColor,
                      ),
                      const SizedBox(height: 30),
                      _UserTypeSelector(
                        userType: _userType,
                        primaryColor: _primaryColor,
                        accentColor: _accentColor,
                        onChanged: (value) => setState(() => _userType = value),
                      ),
                      const SizedBox(height: 40),
                      _HolographicButton(
                        text: 'إنشاء حساب',
                        icon: Icons.app_registration_rounded,
                        onPressed: _registerUser,
                        isLoading: _isLoading,
                        primaryColor: _primaryColor,
                        accentColor: _accentColor,
                      ),
                      const SizedBox(height: 25),
                      _buildBottomLinks(),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey[800],
          fontSize: 16,
        ),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.8)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: borderColor ?? _primaryColor,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('لديك حساب بالفعل؟',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey[600],
              fontSize: 15,
            )),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text('سجل الدخول',
                style: TextStyle(
                  color: _accentColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                )),
          ),
        ),
      ],
    );
  }
}

// ========== المكونات المخصصة ==========

class _AnimatedAuthIcon extends StatelessWidget {
  final Color primaryColor;

  const _AnimatedAuthIcon({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      child:
          Icon(Icons.person_add_alt_1_rounded, size: 80, color: primaryColor),
      builder: (_, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _UserTypeSelector extends StatelessWidget {
  final String userType;
  final Color primaryColor;
  final Color accentColor;
  final Function(String) onChanged;

  const _UserTypeSelector({
    required this.userType,
    required this.primaryColor,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('نوع الحساب:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[700],
              )),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _UserTypeCard(
                title: 'عميل',
                isSelected: userType == 'customer',
                color: primaryColor,
                onTap: () => onChanged('customer'),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _UserTypeCard(
                title: 'تاجر',
                isSelected: userType == 'merchant',
                color: accentColor,
                onTap: () => onChanged('merchant'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color color;
  final Function() onTap;

  const _UserTypeCard({
    required this.title,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                title == 'عميل'
                    ? Icons.shopping_cart_rounded
                    : Icons.store_rounded,
                size: 32,
                color: isSelected ? color : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isSelected ? color : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _HolographicButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color primaryColor;
  final Color accentColor;

  const _HolographicButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.isLoading,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3)
                else ...[
                  Icon(icon, size: 24, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(text,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
