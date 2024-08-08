import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavigationBarWidget({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFF17395E),
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Container(
        height: 45.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.notifications, 'Notifications', 1),
            const SizedBox(width: 30),
            _buildNavItem(Icons.report, 'Report', 2),
            _buildNavItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black,
            size: 24.0,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
