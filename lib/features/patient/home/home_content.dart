import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/demande_box.dart';
import '../../../core/widgets/health_advice_card.dart';
import '../../../core/widgets/pharmacy_card.dart';
import 'notifications_page.dart';
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
  Timer? _scrollTimer;
  Future<List<Pharmacy>>? _pharmaciesFuture;

  static const List<String> healthAdvices = [
    "Buvez 1,5L d'eau par jour",
    "Dormez au moins 8h par nuit",
    "Mangez 5 fruits et légumes",
    "Faites 30 min de sport/jour",
    "Évitez le stress prolongé",
  ];

  bool isLoading = true;

  List<Demande> demandesRecentes = [];


  @override
  void initState() {
    super.initState();
    fetchUserName();
    loadRecentRequests();
    _pharmaciesFuture = PharmacyService.fetchNearbyPharmacies();

    _scrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final currentOffset = _scrollController.offset;
        double nextOffset = currentOffset + 220;

        if (nextOffset >= maxScrollExtent) {
          _scrollController.jumpTo(0); // direct au début pour effet "carousel"
        } else {
          _scrollController.animateTo(
            nextOffset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }

      }
    });
  }

  Future<void> loadRecentRequests() async {
    setState(() => isLoading = true);
    final data = await fetchRecentRequests();
    setState(() {
      demandesRecentes = data;
      isLoading = false;
    });
  }



  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }


  Future<void> fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userName = doc['nom'] ?? 'Utilisateur';
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur récupération nom utilisateur: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primarycolor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bonjour 👋",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Bouton de notification
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
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
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                )
                              ],
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

                  // (Optionnel) Avatar utilisateur
                  /*const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppColors.primarycolor),
                  ),*/

                ],
              ),
            ],
          ),
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 5),
            SizedBox(
              height: 70,
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
            const SizedBox(height: 15),
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
            Padding(
              padding: const EdgeInsets.all(5),
              child: FutureBuilder<List<Pharmacy>>(
                future: _pharmaciesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Erreur : ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Aucune pharmacie trouvée.");
                  }

                  final pharmacies = snapshot.data!;
                  final displayedPharmacies = pharmacies.length > 2
                      ? pharmacies.sublist(0, 2)
                      : pharmacies;

                  return Column(
                    children: displayedPharmacies
                        .map((pharmacy) => PharmacyCard(
                      name: pharmacy.name,
                      address: pharmacy.address,
                      distanceInKm: pharmacy.distanceInKm,
                    ))
                        .toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),
            const Text(
              "Mes dernières demandes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 1),
            isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primarycolor))
                : demandesRecentes.isEmpty
                ? const Text("Aucune demande récente")
                : DemandeRecente(demandes: getRecentDemandesMap(demandesRecentes)),

          ],
        ),
      ),
    );
  }
}


Future<List<Demande>> fetchRecentRequests() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('demandes')
      .where('userId', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true)
      .limit(5)
      .get();

  if (kDebugMode) {
    print(">>> Nombre de documents récupérés : ${snapshot.docs.length}");
  }

  for (var doc in snapshot.docs) {
    if (kDebugMode) {
      print(">>> Document : ${doc.data()}");
    }
  }

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Demande.fromMap(data);
  }).toList();

}
List<Map<String, String>> getRecentDemandesMap(List<Demande> demandes) {
  return demandes.take(2).map((demande) => {
    'orderNumber': demande.numeroCommande,
    'date': demande.timeAgoText,
    'status': demande.status,
  }).toList();
}


String timeAgo(Timestamp timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp.toDate());

  if (diff.inSeconds < 60) return 'il y a quelques secondes';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  return 'il y a ${diff.inDays} j';
}

class Demande {
  final String numeroCommande;
  final Timestamp timestamp;
  final String status;

  Demande({
    required this.numeroCommande,
    required this.timestamp,
    required this.status,
  });

  factory Demande.fromMap(Map<String, dynamic> data) {
    return Demande(
      numeroCommande: data['numero_commande'] ?? 'Inconnu',
      timestamp: data['timestamp'] as Timestamp,
      status: data['statut'] ?? 'en attente', // ou autre valeur par défaut
    );
  }

  String get timeAgoText => timeAgo(timestamp);
}

