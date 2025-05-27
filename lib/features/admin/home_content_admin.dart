import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';


class HomeContentAdmin extends StatefulWidget {
  const HomeContentAdmin({super.key});

  @override
  State<HomeContentAdmin> createState() => _HomeContentAdminState();
}

class _HomeContentAdminState extends State<HomeContentAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
    );
  }
}
