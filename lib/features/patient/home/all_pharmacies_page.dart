import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/pharmacy_card.dart';
import 'data/pharmacies_list.dart';

class AllPharmaciesPage extends StatefulWidget {
  const AllPharmaciesPage({super.key});

  @override
  State<AllPharmaciesPage> createState() => _AllPharmaciesPageState();
}

class _AllPharmaciesPageState extends State<AllPharmaciesPage> {
  List<Pharmacy> pharmacies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPharmacies();
  }

  Future<void> loadPharmacies() async {
    try {
      final result = await PharmacyService.fetchNearbyPharmacies();
      setState(() {
        pharmacies = result;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Erreur : $e");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: const Text("Toutes les pharmacies", style: TextStyle(color: AppColors.surfacecolor)),
        backgroundColor: AppColors.primarycolor,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pharmacies.isEmpty
          ? const Center(child: Text("Aucune pharmacie à moins de 4 km"))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
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
