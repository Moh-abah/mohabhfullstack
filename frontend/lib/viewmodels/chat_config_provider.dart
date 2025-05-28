// import 'package:flutter/material.dart';

// class ChatConfigProvider with ChangeNotifier {
//   // إعدادات التنسيق
//   Color _sentMessageColor = const Color(0xFFDCF8C6);
//   Color _receivedMessageColor = Colors.white;
//   double _messageFontSize = 16.0;
//   bool _showAvatars = true;
//   bool _showTimestamps = true;
//   bool _animateMessages = true;

//   // Getters
//   Color get sentMessageColor => _sentMessageColor;
//   Color get receivedMessageColor => _receivedMessageColor;
//   double get messageFontSize => _messageFontSize;
//   bool get showAvatars => _showAvatars;
//   bool get showTimestamps => _showTimestamps;
//   bool get animateMessages => _animateMessages;

//   // Setters
//   void updateColors(Color sent, Color received) {
//     _sentMessageColor = sent;
//     _receivedMessageColor = received;
//     notifyListeners();
//   }

//   void updateFontSize(double size) {
//     _messageFontSize = size;
//     notifyListeners();
//   }

//   void toggleAvatars(bool value) {
//     _showAvatars = value;
//     notifyListeners();
//   }

//   void toggleTimestamps(bool value) {
//     _showTimestamps = value;
//     notifyListeners();
//   }

//   void toggleAnimations(bool value) {
//     _animateMessages = value;
//     notifyListeners();
//   }
// }
