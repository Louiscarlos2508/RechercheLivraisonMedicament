import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/widgets/command_cards.dart';

import '../delivery/attribution_livreur_page.dart';
import 'gestion_commande_page.dart';

class NewOrdersPage extends StatefulWidget {
  const NewOrdersPage({super.key});

  @override
  State<NewOrdersPage> createState() => _NewOrdersPageState();
}

class _NewOrdersPageState extends State<NewOrdersPage> {
  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'En attente':
        return Colors.orange;
      case 'Acceptée':
        return Colors.green;
      case 'Paiement en attente':
        return Colors.blue;
      case 'Livraison en cours':
        return Colors.yellow;
      case 'Refusée':
        return Colors.red;
      case 'Terminée':
        return Colors.greenAccent;
      default:
        return Colors.black;
    }
  }

  void _showOrderDetails(Map<String, dynamic> orderDetails) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfacecolor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // Gère les claviers etc.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    'Commande #${orderDetails['cmdNum']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.primarycolor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info, color: _getStatusTextColor(orderDetails['statut'])),
                      const SizedBox(width: 6),
                      Text(
                        'Statut : ${orderDetails['statut']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _getStatusTextColor(orderDetails['statut']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Médicaments :', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...((orderDetails['medicaments'] as List).map<Widget>((med) {
                    return Text(
                      '• ${med['nom']} ${med['dosage']} ${med['unite']} x${med['quantite']}',
                      style: const TextStyle(fontSize: 14),
                    );
                  })),
                  const SizedBox(height: 10),
                  if (orderDetails['ordonnanceUrl'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ordonnance :', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            orderDetails['ordonnanceUrl'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  if (orderDetails['statut'] != 'En attente')
                    Text(
                      'Prix total : ${orderDetails['prixTotal']} FCFA',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (orderDetails['statut'] == 'Paiement en attente')
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primarycolor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Payer'),
                        ),
                      if (orderDetails['statut'] == 'Livraison en cours')
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primarycolor,
                            side: BorderSide(color: AppColors.primarycolor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Suivre la livraison'),
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersWithFullnames() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('demandes')
        .orderBy('timestamp', descending: true)
        .get();

    final List<Map<String, dynamic>> orders = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final statut = data['statut'] ?? '';
      if (statut != 'En attente' &&
          statut != 'Paiement en attente' &&
          statut != 'Acceptée' &&
          statut != 'Livraison en cours') {
        continue;
      }

      final userId = data['userId'];
      String fullname = 'Client';

      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          fullname = userDoc.data()?['nom'] ?? 'Client';
        }
      }

      final timestamp = data['timestamp'] as Timestamp?;
      final cmdDate = timestamp != null
          ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
          : 'Date inconnue';

      orders.add({
        'fullname': fullname,
        'cmdDate': cmdDate,
        'cmdNum': data['numero_commande'] ?? '',
        'statut': statut,
        'nbrProduit': '${data['medicaments'] == null ? 0 : data['medicaments'].length}',
        'statutColor': _getStatusTextColor(statut),
        'prixTotal': data['prixTotal'],
        'ordonnanceUrl': data['ordonnanceUrl'],
        'medicaments': data['medicaments'],
      });

    }

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrdersWithFullnames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primarycolor,));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune commande trouvée."));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CommandCards(
                  fullname: order['fullname'],
                  cmdDate: order['cmdDate'],
                  cmdNum: order['cmdNum'],
                  statut: order['statut'],
                  nbrProduit: order['nbrProduit'],
                  statutColor: order['statutColor'],
                  onTap: () {
                    final statut = order['statut'];
                    if (statut == 'En attente') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GestionCommandePage(order: order),
                        ),
                      );
                    } else if (statut == 'Paiement en attente' && order['paiementEffectue'] == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttributionLivreurPage(order: order),
                        ),
                      );
                    } else {
                      _showOrderDetails(order);
                    }
                  },

                ),
              );
            },
          );
        },
      ),
    );
  }
}
