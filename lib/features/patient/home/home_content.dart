import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/health_advice_card.dart';
import '../../../core/widgets/pharmacy_card.dart';
import '../notifications_page.dart';
import 'all_pharmacies_page.dart';
import 'data/pharmacies_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String userName = "";
  int unreadNotifications = 3; // valeur temporaire, remplace ensuite avec Firebase
  final ScrollController _scrollController = ScrollController();
  int _scrollPosition = 0;
  Timer? _scrollTimer;

  static const List<String> healthAdvices = [
    "Buvez 1,5L d'eau par jour",
    "Dormez au moins 8h par nuit",
    "Mangez 5 fruits et légumes",
    "Faites 30 min de sport/jour",
    "Évitez le stress prolongé",
  ];


  @override
  void initState() {
    super.initState();
    fetchUserName();
    _scrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (_scrollController.offset >= maxScroll) {
          _scrollController.jumpTo(0); // recommencer
        } else {
          _scrollPosition += 220; // largeur estimée de la carte + padding
          _scrollController.animateTo(
            _scrollPosition.toDouble(),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }


  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userName = doc['nom'] ?? 'Utilisateur';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // On limite à 4 pour l'affichage
    final List<Pharmacy> displayedPharmacies =
    pharmacies.length > 4 ? pharmacies.sublist(0, 4) : pharmacies;

    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.primarycolor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25,),
                  const Text(
                    "Bonjour 👋",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsPage()),
                      );
                    },
                  ),
                  if (unreadNotifications > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Center(
                          child: Text(
                            '$unreadNotifications',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                "Conseils Santé",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                )
                )
              ]
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: healthAdvices.length,
                separatorBuilder: (_, __) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return HealthAdviceCard(advice: healthAdvices[index]);
                },
              ),
            ),
            const SizedBox(height: 20),

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
                        PharmacyCard(
                          name: displayedPharmacies[index1].name,
                          address: displayedPharmacies[index1].address,
                          distanceInKm: displayedPharmacies[index1].distanceInKm,
                        ),
                        const SizedBox(height: 15),
                        if (index2 < displayedPharmacies.length)
                          PharmacyCard(
                            name: displayedPharmacies[index1].name,
                            address: displayedPharmacies[index1].address,
                            distanceInKm: displayedPharmacies[index1].distanceInKm,
                          ),
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




