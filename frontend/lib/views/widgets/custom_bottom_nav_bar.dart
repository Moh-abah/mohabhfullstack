import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ain_frontend/viewmodels/UserTypeViewModel.dart';
import 'package:ain_frontend/viewmodels/state_bottom.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final BottomNavManager _navManager = BottomNavManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام Provider للاستماع لتغييرات نوع المستخدم
    final userType = Provider.of<UserTypeViewModel>(context).userType;

    // استخدام مدير الحالة للحصول على عدادات الإشعارات
    final badgeCounts = _navManager.badgeCounts;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[300],
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
        backgroundColor: const Color.fromARGB(255, 8, 18, 28),
        onTap: (index) {
          _animationController.forward(from: 0);
          widget.onTap(index);
        },
        items: [
          _buildNavItem(
            icon: userType == 'merchant'
                ? Icons.person_outline
                : Icons.home_outlined,
            activeIcon:
                userType == 'merchant' ? Icons.person : Icons.home_filled,
            label: userType == 'merchant' ? 'الملف الشخصي' : 'الرئيسية',
            isSelected: widget.currentIndex == 0,
            badgeCount: badgeCounts[0],
          ),
          _buildNavItem(
            icon: Icons.location_on_outlined,
            activeIcon: Icons.location_on,
            label: 'الموقع',
            isSelected: widget.currentIndex == 1,
            badgeCount: badgeCounts[1],
          ),
          _buildNavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'المحادثات',
            isSelected: widget.currentIndex == 2,
            badgeCount: badgeCounts[2],
          ),
          _buildNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'الإعدادات',
            isSelected: widget.currentIndex == 3,
            badgeCount: badgeCounts[3],
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    int? badgeCount,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? 1.2 : 1.0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 86, 17, 132),
                              Color(0xFF2A5C8D)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 26,
                    color: isSelected ? Colors.white : Colors.grey[300],
                  ),
                ),
              );
            },
          ),
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
