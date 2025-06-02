import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/features/admin/Profil/profil_page_admin.dart';
import 'package:recherchelivraisonmedicament/features/admin/delivery/livreur_page_admin.dart';
import 'package:recherchelivraisonmedicament/features/admin/orders/orders_page_admin.dart';


class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex =0;
  final systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.primarycolor,
    statusBarIconBrightness: Brightness.light,
  );

  final List<Map<String, dynamic>> _screens = [
    /*{
      'widget': HomeContentAdmin(),
      'icon': Icons.home,
      'label': 'Accueil',
    },

     */
    {
      'widget': OrdersPageAdmin(),
      'icon': Icons.shopping_bag,
      'label': 'Commandes',
    },
    {
      'widget': LivreurPageAdmin(),
      'icon': Icons.delivery_dining_outlined,
      'label': 'Livreur',
    },
    {
      'widget': ProfilPageAdmin(),
      'icon': Icons.person,
      'label': 'Profil',
    },
  ];
  /*void logout(BuildContext context) async{
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
      );
    }
  }

   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
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
    );
  }
}
