import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomeContent extends StatelessWidget { // Changer en StatelessWidget
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          "Home",
          style: TextStyle(fontSize: 24, color: AppColors.textPrimarycolor),
        ),
      ),
    );
  }
}
