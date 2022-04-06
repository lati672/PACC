// Packages
import 'package:chatifyapp/pages/friends.dart';
import 'package:chatifyapp/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import '../pages/chats_page.dart';
import 'package:chatifyapp/pages/todolist_page.dart';
import '../pages/parent_todolist.dart';

//Provider
import '../providers/authentication_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Page index
  int _currentPage = 0;
  late AuthenticationProvider _auth;
  // * Pages to display and navigate
  List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    final String role = _auth.user.role;
    _pages = [
      const ChatsPage(),
      _auth.user.role == 'Student' ? TodoListPage() : ParentTodolistPage(),
      // TodoListPage(role: role),
      FriendsPage(role: role),
      UserProfilePage()
    ];
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        items: const [
          BottomNavigationBarItem(
            label: '聊天',
            icon: Icon(
              Icons.chat_bubble_sharp,
            ),
          ),
          BottomNavigationBarItem(
            label: '待办',
            icon: Icon(
              Icons.access_alarm_rounded,
            ),
          ),
          BottomNavigationBarItem(
            label: '朋友',
            icon: Icon(
              Icons.escalator_warning,
            ),
          ),
          BottomNavigationBarItem(
            label: '用户',
            icon: Icon(
              Icons.account_circle_rounded,
            ),
          ),
        ],
        onTap: (_index) {
          setState(
            () {
              _currentPage = _index;
            },
          );
        },
      ),
    );
  }
}
