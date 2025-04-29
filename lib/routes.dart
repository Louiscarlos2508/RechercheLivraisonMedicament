import 'package:flutter/material.dart';
import 'features/auth/login_page.dart';
import 'features/splash_screen.dart';

class AppRoutes{

  static const String splash = '/';
  static const String login = '/login';


  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    login: (context) => LoginPage(),
  };
}