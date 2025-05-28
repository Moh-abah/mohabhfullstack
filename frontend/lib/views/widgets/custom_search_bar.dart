import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const CustomSearchBar({
    required this.controller,
    required this.onSearch,
    required this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 64.0, // زيادة الارتفاع من 60 إلى 64
      width: 110,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 214, 210, 210).withOpacity(0.6),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: const Color.fromARGB(255, 36, 0, 95).withOpacity(0.2),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 18.0, right: 15.0), // زيادة البادئة الجانبية
            child: Icon(Icons.search,
                color: const Color.fromARGB(255, 1, 94, 169),
                size: 30), // زيادة حجم الأيقونة من 28 إلى 30
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: TextField(
                controller: controller,
                onChanged: onSearch,
                style: TextStyle(
                  fontSize: 19.0, // زيادة حجم الخط من 18 إلى 19
                  color: Colors.blue[900],
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن متجر...',
                  hintStyle: TextStyle(
                    color:
                        const Color.fromARGB(255, 1, 94, 169).withOpacity(0.7),
                    fontSize: 17.0, // زيادة حجم تلميح النص من 16 إلى 17
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0, // زيادة المساحة العمودية من 18 إلى 20
                    horizontal: 14, // زيادة البادئة الأفقية
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear,
                color: Color.fromARGB(255, 1, 94, 169),
                size: 30), // توحيد حجم الأيقونة مع أيقونة البحث
            onPressed: onClear,
            padding:
                const EdgeInsets.only(right: 0.0), // زيادة البادئة اليمينية
          ),
        ],
      ),
    );
  }
}
