import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CommandCards extends StatelessWidget {
  final String fullname;
  final String cmdDate;
  final String cmdNum;
  final String statut;
  final String nbrProduit;
  final Color statutColor;
  final VoidCallback? onTap;

  const CommandCards({
    super.key,
    required this.fullname,
    required this.cmdDate,
    required this.cmdNum,
    required this.statut,
    required this.nbrProduit,
    required this.statutColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradientStart = AppColors.primarycolor;
    String produitChx = nbrProduit;
    int chxP = int.parse(produitChx);
    final String texteProduit = chxP == 0
        ? 'Une ordonnance'
        : '$nbrProduit produit${nbrProduit != "1" ? "s" : ""}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: gradientStart.withValues(alpha: 0.4),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Première ligne (Nom + Date / Nombre de produits)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullname,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cmdDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarycolor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    texteProduit,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(
              color: Colors.black12,
              height: 20,
              thickness: 1,
            ),

            // Deuxième ligne (Numéro de commande / Statut)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'N° $cmdNum',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statutColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statut,
                    style: TextStyle(
                      color: statutColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}