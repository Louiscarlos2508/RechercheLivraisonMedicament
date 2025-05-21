import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/pharmacy_card.dart';
import 'data/pharmacies_list.dart';


class AllPharmaciesPage extends StatelessWidget {
  const AllPharmaciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: const Text("Toutes les pharmacies", style: TextStyle(color: AppColors.surfacecolor),),
        backgroundColor: AppColors.primarycolor,
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards par ligne
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.3,
          ),
          itemCount: pharmacies.length,
          itemBuilder: (context, index) {
            final pharmacy = pharmacies[index];
            return PharmacyCard(
              name: pharmacy.name,
              address: pharmacy.address,
              distanceInKm: pharmacy.distanceInKm,
            );
          },

        ),
      ),
    );
  }
}
