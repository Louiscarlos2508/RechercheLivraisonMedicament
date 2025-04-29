import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/features/auth/register_page.dart';
import 'features/auth/login_page.dart';
import 'features/splash_screen.dart';

class AppRoutes{

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';


  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    login: (context) => LoginPage(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.register);
      },
    ),
    register: (context) => RegisterPage(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.login);
      },
    ),
  };
}