import 'package:flutter/material.dart';
import 'package:frontend/User/screens/widgets/logout_button.dart';
import 'user_account.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({
    super.key,
    required this.userAccount,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final UserAccount userAccount;
  final int selectedIndex;
  final Function(int) onItemSelected;

  @override
  State<StatefulWidget> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  late final UserAccount _userAccount;

  final List<Map<String, dynamic>> _menuItems = const [
    {'icon': Icons.home,          'title': 'Trang chủ'},
    {'icon': Icons.calendar_month,'title': 'Theo dõi vòng kinh'},
    {'icon': Icons.menu_book,     'title': 'Tư vấn kiến thức'},
    {'icon': Icons.person_search, 'title': 'Tư vấn chuyên gia'},
    {'icon': Icons.settings,      'title': 'Quản lý tài khoản'},
  ];

  void _handleTap(int index) {
    widget.onItemSelected(index);   // báo về HomePage đổi tab
    Navigator.maybePop(context);    // đóng Drawer (trượt vào)
  }

  @override
  void initState() {
    super.initState();
    _userAccount = widget.userAccount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const selectedColor = Colors.pink;
    const unselectedColor = Colors.grey;

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
                      Text('Floria',
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

            // Footer: user info + logout
            const Divider(height: 1),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pinkAccent,
                child: Text(
                  (_userAccount.username.isNotEmpty
                          ? _userAccount.username[0]
                          : 'N')
                      .toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                _userAccount.username.isNotEmpty
                    ? _userAccount.username
                    : 'Người dùng',
              ),
              subtitle: Text(
                _userAccount.email.isNotEmpty
                    ? _userAccount.email
                    : 'Đang tải...',
              ),
            ),
            const LogoutButton(),
          ],
        ),
      ),
    );
  }
}
