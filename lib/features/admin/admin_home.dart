import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

import '../../routes.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

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
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
              onPressed: () => logout(context),
              icon: Icon(Icons.logout)
          )
        ],
      ),
    );
  }
}
