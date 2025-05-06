import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/features/admin/admin_home.dart';
import 'package:recherchelivraisonmedicament/features/auth/forgot_password_page.dart';
import 'package:recherchelivraisonmedicament/features/auth/register_page.dart';
import 'package:recherchelivraisonmedicament/features/delivery/livreur_home.dart';
import 'package:recherchelivraisonmedicament/features/patient/orders/new_request_page.dart';
import 'package:recherchelivraisonmedicament/features/patient/patient_home.dart';
import 'package:recherchelivraisonmedicament/features/patient/profile/about_page.dart';
import 'package:recherchelivraisonmedicament/features/patient/profile/help_page.dart';
import 'package:recherchelivraisonmedicament/features/patient/profile/settings_page.dart';
import 'package:recherchelivraisonmedicament/features/patient/profile/update_profile_page.dart';
import '../features/auth/login_page.dart';
import '../features/splash_screen.dart';

class AppRoutes{

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String adminHome = '/adminHome';
  static const String livreurHome = '/livreurHome';
  static const String patientHome = '/patientHome';
  static const String resetPassword = '/resetPassword';
  static const String updateProfilePage = '/updateProfilePage';
  static const String requestHistoryPage = '/requestHistoryPage';
  static const String aboutPage = '/aboutPage';
  static const String helpPage = '/helpPage';
  static const String settingsPage = '/settingsPage';


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
    adminHome: (context) => AdminHome(),
    livreurHome: (context) => LivreurHome(),
    patientHome: (context) => PatientHome(),
    resetPassword: (context) => ForgotPasswordPage(),
    updateProfilePage: (context) => UpdateProfilePage(),
    requestHistoryPage: (context) => NewRequestPage(),
    aboutPage: (context) => AboutPage(),
    helpPage: (context) => HelpPage(),
    settingsPage: (context) => SettingsPage(),
  };
}