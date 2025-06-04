import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/command_cards.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
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

  Future<List<Map<String, dynamic>>> _fetchOrdersWithFullnames() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('demandes')
        .orderBy('timestamp', descending: true)
        .get();

    final List<Map<String, dynamic>> orders = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final statut = data['statut'] ?? '';
      if (statut != 'Refusée' &&
          statut != 'Terminée' ) {
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
        'nbrProduit':
        '${data['medicaments'] == null ? 0 : data['medicaments'].length} produit(s)',
        'statutColor': _getStatusTextColor(statut),
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
            return const Center(child: Text("Historique de commande vide."));
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
