// Packages
import 'package:chatifyapp/pages/settings.dart';
import 'package:chatifyapp/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import '../pages/chats_page.dart';
import 'package:chatifyapp/pages/users_page.dart';

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
    UsersPage(),
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
            label: 'ChATS',
            icon: Icon(
              Icons.chat_bubble_sharp,
            ),
          ),
          BottomNavigationBarItem(
            label: 'USERS',
            icon: Icon(
              Icons.supervised_user_circle,
            ),
          ),
          BottomNavigationBarItem(
            label: 'USERPROFILE',
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
