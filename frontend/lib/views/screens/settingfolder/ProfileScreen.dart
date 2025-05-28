import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/user.dart';
import '../../../utils/SecureStorageHelper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Dio _dio = Dio();
  static const String _baseUrl = 'https://myapptestes.onrender.com';

  // Colors
  final Color _primaryColor = const Color(0xFF2A5C8D);
  final Color _accentColor = const Color(0xFFFFA726);
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _subtitleColor = const Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Load user data from secure storage
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await SecureStorageHelper.getUser();
      if (user != null) {
        setState(() {
          _user = user;
          _usernameController.text = user.username;
          print(user.username);

          _nameController.text = user.name;
          print(user.name);
          _phoneController.text = user.phone;
          // Don't set password for security reasons
          _passwordController.text = '';
          _confirmPasswordController.text = '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authorization token is missing');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Update user data in API and secure storage
  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog
    final shouldUpdate = await _showConfirmationDialog();
    if (shouldUpdate != true) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Create updated user object
      User updatedUser = User(
        id: _user.id,
        username: _usernameController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : _user.password,
        userType: _user.userType,
      );

      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/api/users/update/${_user.id}/',
        data: updatedUser.toJson(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        await SecureStorageHelper.saveUser(updatedUser);
        _showSuccessSnackBar('Profile updated successfully!');

        // Clear password fields after successful update
        setState(() {
          _passwordController.text = '';
          _confirmPasswordController.text = '';
        });
      } else {
        _showErrorSnackBar('Failed to update profile: ${response.data}');
      }
    } on DioException catch (e) {
      _showErrorSnackBar('Error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('Unexpected error: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Update', style: TextStyle(color: _primaryColor)),
        content: const Text('Are you sure you want to update your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildProfileContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _accentColor),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: _subtitleColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          _buildProfileForm(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: _accentColor.withOpacity(0.2),
            child: Text(
              _nameController.text.isNotEmpty
                  ? _nameController.text[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: _accentColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${_usernameController.text}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 8),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _user.userType.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Personal Information'),
            _buildCard([
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^(77|73|71|78)[0-9]{7}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Security'),
            _buildCard([
              _buildTextField(
                controller: _passwordController,
                label: 'New Password',
                icon: Icons.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: _subtitleColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: _subtitleColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (_passwordController.text.isNotEmpty &&
                      value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Leave password fields empty if you don\'t want to change it',
                style: TextStyle(
                  fontSize: 12,
                  color: _subtitleColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ]),
            const SizedBox(height: 32),
            _buildUpdateButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: _textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _subtitleColor),
        prefixIcon: Icon(icon, color: _primaryColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryColor.withOpacity(0.6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isUpdating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Updating...'),
                ],
              )
            : const Text(
                'Update Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
