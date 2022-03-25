// Packages
import 'package:chatifyapp/pages/friends.dart';
import 'package:chatifyapp/pages/settings.dart';
import 'package:chatifyapp/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import '../pages/chats_page.dart';
import 'package:chatifyapp/pages/todolist_page.dart';

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
  final List<Widget> _pages = [
    const ChatsPage(),
    TodoListPage(),
    FriendsPage(),
    UserProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
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
              color: Colors.black,
            ),
          ),
          BottomNavigationBarItem(
            label: '白名单',
            icon: Icon(
              Icons.access_alarm_rounded,
              color: Colors.black,
            ),
          ),
          BottomNavigationBarItem(
            label: '朋友',
            icon: Icon(
              Icons.escalator_warning,
              color: Colors.black,
            ),
          ),
          BottomNavigationBarItem(
            label: '用户',
            icon: Icon(
              Icons.account_circle_rounded,
              color: Colors.black,
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
