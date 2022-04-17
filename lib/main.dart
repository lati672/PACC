import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Packages
import 'package:provider/provider.dart';

// Services
import './services/navigation_service.dart';

// Providers
import 'package:chatifyapp/providers/authentication_provider.dart';

// pages
import './pages/splash_page.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/home_page.dart';

List<CameraDescription> cameras = [];

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
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
        title: 'Chatify',
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
          '/home': (BuildContext _context) => HomePage(cameras: cameras),
        },
      ),
    );
  }
}
