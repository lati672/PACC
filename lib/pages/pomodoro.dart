import 'package:flutter/material.dart';
import '../pages/pomodoro_page.dart';

class Pomodoro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Color(0xFF2A2B4D),
        fontFamily: 'Quicksand-Variable',
      ),
      home: PomodoroPage(),
    );
  }
}
