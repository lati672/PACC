/*
Summary of File:
  This file contains codes is the home page.
  Include navigator bar in the bottom.
*/
// Packages

import 'package:PACCPolicyapp/pages/threads/thread.dart';
import 'package:PACCPolicyapp/pages/threads/threads.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Pages
import 'package:PACCPolicyapp/pages/user profile/user_profile_page.dart';
import 'package:PACCPolicyapp/pages/blank/blank_page.dart';
//Provider
import 'package:PACCPolicyapp/providers/authentication_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Page index
  int _currentPage = 0;
  // * Pages to display and navigate
  List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    _pages = [ThreadsPage(), UserProfilePage()];
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        items: const [
          BottomNavigationBarItem(
            label: 'BLANK',
            icon: Icon(
              Icons.chat_bubble_sharp,
            ),
          ),
          BottomNavigationBarItem(
            label: 'USER',
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
