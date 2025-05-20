import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/features/patient/profile/profile_page.dart';

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
  final systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.primarycolor,
    statusBarIconBrightness: Brightness.light,
  );

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


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(

        body: _screens[_currentIndex]['widget'],
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
      ),
    );
  }
}
