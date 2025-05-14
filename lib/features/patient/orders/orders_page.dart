import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // Variables de filtre
  String _selectedStatus = 'Tous';
  DateTime? _selectedDate;
  final String _orderNumber = '';
  List<QueryDocumentSnapshot> _orders = [];
  bool _isLoading = false;

  // Méthode pour récupérer les commandes avec filtres
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance.collection('demandes');

      // Filtrage par statut
      if (_selectedStatus != 'Tous') {
        query = query.where('statut', isEqualTo: _selectedStatus);
      }

      // Filtrage par date
      if (_selectedDate != null) {
        String dateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        query = query.where('timestamp', isGreaterThanOrEqualTo: DateTime.parse('$dateFormatted 00:00:00'));
        query = query.where('timestamp', isLessThanOrEqualTo: DateTime.parse('$dateFormatted 23:59:59'));
      }

      // Filtrage par numéro de commande
      if (_orderNumber.isNotEmpty) {
        query = query.where('numero_commande', isEqualTo: _orderNumber);
      }

      final snapshot = await query.get();
      setState(() {
        _orders = snapshot.docs;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de récupération des commandes')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Affichage des détails d'une commande dans un modal
  void _showOrderDetails(Map<String, dynamic> orderDetails) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de la commande'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Numéro de commande: ${orderDetails['numero_commande']}'),
                Text('Statut: ${orderDetails['statut']}'),
                Text('Médicaments demandés:'),
                for (var med in orderDetails['medicaments'])
                  Text('  ${med['nom']} - ${med['dosage']} - ${med['unite']} -> Quantité : ${med['quantite']}'),
                if (orderDetails['ordonnanceUrl'] != null)
                  Image.network(orderDetails['ordonnanceUrl'], height: 150, width: 150),
                if (orderDetails['statut'] != 'en attente')
                  Text('Prix total: ${orderDetails['prixTotal']}'),
              ],
            ),
          ),
          actions: [
            if (orderDetails['statut'] == 'paiement en attente')
              TextButton(
                onPressed: () {
                  // Code pour effectuer le paiement
                },
                child: Text('Payer', style: TextStyle(color: AppColors.primarycolor)),
              ),
            if (orderDetails['statut'] == 'accepte')
              TextButton(
                onPressed: () {
                  // Code pour suivre la livraison
                },
                child: Text('Suivre la livraison', style: TextStyle(color: AppColors.primarycolor)),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour obtenir la couleur du texte en fonction du statut
  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'en attente':
        return Colors.orange;
      case 'accepte':
        return Colors.green;
      case 'paiement en attente':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        title: Text('Commandes', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.surfacecolor)),
        centerTitle: true,
        toolbarHeight: 64,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,color: AppColors.surfacecolor,),
            onPressed: _fetchOrders, // Rafraîchir les commandes
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtres de recherche améliorés
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filtre par statut
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items: ['Tous', 'en attente', 'acceptée', 'paiement en attente', 'refusée']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                      _fetchOrders();
                    },
                  ),
                  // Filtre par date
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                        _fetchOrders();
                      }
                    },
                    child: Text(_selectedDate == null ? 'Sélectionner une date' : DateFormat('yyyy-MM-dd').format(_selectedDate!),style: TextStyle(color: AppColors.primarycolor),),
                  ),
                  // Filtre par numéro de commande
                  /*SizedBox(
                    width: 120,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _orderNumber = value;
                        });
                        _fetchOrders();
                      },
                      decoration: InputDecoration(hintText: 'Numéro de commande'),
                    ),
                  ),*/
                ],
              ),
            ),

            SizedBox(height: 16),
            // Affichage de la liste des commandes
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index].data() as Map<String, dynamic>;
                  String status = order['statut'];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Commande #${order['numero_commande']}'),
                      subtitle: Text(
                        'Statut: ${order['statut']}',
                        style: TextStyle(color: _getStatusTextColor(status)),
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () => _showOrderDetails(order),
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
