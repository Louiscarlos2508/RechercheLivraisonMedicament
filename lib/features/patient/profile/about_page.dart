import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: Text("À propos", style: TextStyle(color: AppColors.surfacecolor),),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
    );
  }
}
