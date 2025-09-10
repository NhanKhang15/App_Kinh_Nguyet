import 'package:flutter/material.dart';
import 'package:frontend/User/screens/widgets/logout_button.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({
    super.key,
    // required this.userAccount,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // final UserAccount userAccount;
  final int selectedIndex;
  final Function(int) onItemSelected;

  @override
  State<StatefulWidget> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  // late UserAccount _userAccount;
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.home, 'title': 'Quản lý câu hỏi', 'onTap': null},
    {'icon': Icons.calendar_month, 'title': 'Thêm câu hỏi', 'onTap': null},
  ];

  void _handleTap(int index) {
    widget.onItemSelected(index);
    Navigator.maybePop(context); 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = Colors.pink;
    final unselectedColor = Colors.grey;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 30),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 2),
                      Text('Sức khỏe phụ nữ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Menu items
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final item = _menuItems[i];
                  final bool selected = widget.selectedIndex == i;

                  return ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: selected ? selectedColor : unselectedColor,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: selected ? selectedColor : Colors.black,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: selected,
                    selectedTileColor: Colors.pink.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () => _handleTap(i),
                  );
                },
              ),
            ),
            const LogoutButton(),
          ],
        ),
      ),
    );
  }
}