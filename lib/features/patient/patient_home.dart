import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/features/patient/profile_page.dart';
import 'package:recherchelivraisonmedicament/routes.dart';

import 'home/home_content.dart';
import 'orders/new_request_page.dart';
import 'orders/orders_page.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int _currentIndex =0;

  final List<Map<String, dynamic>> _screens = [
    {
      'widget': HomeContent(),
      'icon': Icons.home,
      'label': 'Accueil',
    },
    {
      'widget': NewRequestPage(),
      'icon': Icons.note_add,
      'label': 'Demande',
    },
    {
      'widget': OrdersPage(),
      'icon': Icons.shopping_bag,
      'label': 'Commandes',
    },
    {
      'widget': ProfilePage(),
      'icon': Icons.person,
      'label': 'Profil',
    },
  ];

  void logout(BuildContext context) async{
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        actions: [
          IconButton(
              onPressed: () => logout(context),
              icon: Icon(Icons.logout)
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _screens[_currentIndex]['widget'],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: AppColors.primarycolor,
          color: AppColors.surfacecolor,
          activeColor: AppColors.surfacecolor,
          style: TabStyle.react,
          curveSize: 70,
          items: _screens
              .map((screen) => TabItem(
            icon: screen['icon'],
            title: screen['label'],
          ))
              .toList(),
        initialActiveIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
