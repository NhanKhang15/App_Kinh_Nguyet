import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/user_account.dart';
import '../../screens/menstrual_cycle_tracking/tracking.dart';

class HomePage extends StatefulWidget {
  final UserAccount? userAccount;
  const HomePage({Key? key, this.userAccount}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index; 
    });
  }


  // Title trên AppBar theo tab
  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0:
        return '🏠 Trang chủ';
      case 1:
        return '📆 Theo dõi vòng kinh';
      case 2:
        return '📚 Tư vấn kiến thức';
      case 3:
        return '🧑‍⚕️ Tư vấn chuyên gia';
      case 4:
        return '⚙️ Quản lý tài khoản';
      default:
        return '🏠 Trang chủ';
    }
  }

  // Nếu cần userAccount mà đang null thì show nhắc đăng nhập
  Widget _requireUserAccount(Widget Function(UserAccount ua) builder) {
    final ua = widget.userAccount;
    if (ua == null) {
      return const Center(
        child: Text('Vui lòng đăng nhập để sử dụng tính năng này.'),
      );
    }
    return builder(ua);
  }

  Widget _getBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text('Home page content here'));
      case 1:
        // An toàn null
        return _requireUserAccount(
          (ua) => Tracking(userAccount: ua),
        );
      case 2:
        return const Center(child: Text('Tư vấn kiến thức content here'));
      case 3:
        return const Center(child: Text('Tư vấn chuyên gia content here'));
      case 4:
        return const Center(child: Text('Quản lý tài khoản content here'));
      default:
        return const Center(child: Text('Home page content here'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.userAccount != null
          ? SidebarMenu(
              userAccount: widget.userAccount!,
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
            )
          : null,
      appBar: AppBar(
        title: Text(_appBarTitle),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: _getBodyContent(),
    );
  }
}
