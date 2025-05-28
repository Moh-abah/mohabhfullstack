import 'package:ain_frontend/views/screens/Login_screan.dart';
import 'package:flutter/material.dart';

class start3 extends StatelessWidget {
  const start3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // الصورة
            SizedBox(
              height: size.height * 0.3,
              child: Image.asset(
                'assets/images/secure_data_icon.png', // استبدل باسم ملف الصورة الفعلي
                fit: BoxFit.contain,
              ),
            ),

            // النص العلوي
            const SizedBox(height: 24.0),
            const Text(
              'بيانات آمنة ودقيقة',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            // النص الفرعي
            const SizedBox(height: 8.0),
            const Text(
              'محرك بحث سريع يلائم احتياجاتك',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            // المؤشر (Dots)
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(isActive: false),
                const SizedBox(width: 8.0),
                _buildDot(isActive: false),
                const SizedBox(width: 8.0),
                _buildDot(isActive: true),
              ],
            ),

            // زر المتابعة
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // يمكنك استبدال هذه العملية بعملية أخرى
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FinalLoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48.0,
                  vertical: 16.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'متابعة',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget صغير لبناء النقاط (Dots)
  Widget _buildDot({required bool isActive}) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4A90E2) : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
