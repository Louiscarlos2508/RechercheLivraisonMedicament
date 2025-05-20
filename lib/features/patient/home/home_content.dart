import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/pharmacy_card.dart';
import 'all_pharmacies_page.dart';
import 'data/pharmacies_list.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    // On limite à 4 pour l'affichage
    final List<String> displayedPharmacies =
    pharmacies.length > 4 ? pharmacies.sublist(0, 4) : pharmacies;

    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        title: Text("Home"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne de titre + bouton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pharmacies de garde proches",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllPharmaciesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Grille scrollable avec 2 lignes max
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (displayedPharmacies.length / 2).ceil(),
                itemBuilder: (context, columnIndex) {
                  final int index1 = columnIndex * 2;
                  final int index2 = index1 + 1;

                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Column(
                      children: [
                        PharmacyCard(name: displayedPharmacies[index1]),
                        const SizedBox(height: 15),
                        if (index2 < displayedPharmacies.length)
                          PharmacyCard(name: displayedPharmacies[index2]),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




