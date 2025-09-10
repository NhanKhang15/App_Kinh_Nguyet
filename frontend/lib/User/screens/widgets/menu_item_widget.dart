import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  // Hàm static để build danh sách menu item widget
  static List<Widget> buildMenuItems({
    required List<Map<String, dynamic>> menuItems,
    required int selectedIndex,
    required Function(int) onItemTap,
  }) {
    return List.generate(menuItems.length, (index) {
      return MenuItemWidget(
        icon: menuItems[index]['icon'],
        title: menuItems[index]['title'],
        isActive: selectedIndex == index,
        onTap: () {
          onItemTap(index);
        },
      );
    });
  }
  
  final IconData icon;
    final String title;
    final bool isActive;
    final VoidCallback onTap;

    const MenuItemWidget({
      Key? key,
      required this.icon,
      required this.title,
      required this.isActive,
      required this.onTap,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFFFDF0F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.pink : Colors.black54,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.pink : Colors.black87,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
          horizontalTitleGap: 12,
        ),
      );
    }
}
