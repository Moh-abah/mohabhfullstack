import 'package:flutter/material.dart';

class AppVersionScreen extends StatelessWidget {
  const AppVersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إصدار التطبيق')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 60, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              'إصدار التطبيق الحالي:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '📱 الإصدار 1.0.0',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
