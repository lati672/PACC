import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:provider/provider.dart';

// Services
import './services/navigation_service.dart';

// Providers
import 'package:PACCPolicyapp/providers/authentication_provider.dart';

// pages
import 'package:PACCPolicyapp/pages/splash_page.dart';
import 'package:PACCPolicyapp/pages/login/login_page.dart';
import 'package:PACCPolicyapp/pages/register/register_page.dart';
import 'package:PACCPolicyapp/pages/home/home_page.dart';
import 'dart:io';

void main() {
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () => runApp(
        const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext _context) => AuthenticationProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PACC Policy app',
        theme: ThemeData(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color.fromRGBO(240, 240, 240, 0.8),
              selectedIconTheme: IconThemeData(color: Colors.lightBlue),
              showSelectedLabels: true,
              unselectedLabelStyle: TextStyle(color: Colors.black),
              type: BottomNavigationBarType.fixed),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext _context) => const LoginPage(),
          '/register': (BuildContext _context) => const RegisterPage(),
          '/home': (BuildContext _context) => HomePage(),
        },
      ),
    );
  }
}
