import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget{
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary_color,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/medicine.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: 20,),
                Text(
                  'RechercheLivraisonMedicament',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface_color
                  ),
                )
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/pharmacy.png',
                    width: 125,
                    height: 125,
                  ),
                  SizedBox(width: 100,),
                  Image.asset(
                    'assets/images/drugs.png',
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),
            
          ),
        ],
      ),
    );
  }
}