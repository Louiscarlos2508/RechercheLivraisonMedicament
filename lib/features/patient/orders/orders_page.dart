import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedStatus = 'Tous';
  DateTime? _selectedDate;
  List<QueryDocumentSnapshot> _orders = [];
  bool _isLoading = false;

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      Query query = FirebaseFirestore.instance.collection('demandes').where('userId', isEqualTo: user.uid);

      if (_selectedStatus != 'Tous') {
        query = query.where('statut', isEqualTo: _selectedStatus);
      }

      if (_selectedDate != null) {
        String dateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        query = query
            .where('timestamp', isGreaterThanOrEqualTo: DateTime.parse('$dateFormatted 00:00:00'))
            .where('timestamp', isLessThanOrEqualTo: DateTime.parse('$dateFormatted 23:59:59'));
      }

      final snapshot = await query.get();
      setState(() => _orders = snapshot.docs);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de récupération des commandes')),
      );
    } finally {
      setState(() => _isLoading = false);
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
                    'Commande #${orderDetails['numero_commande']}',
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
                      if (orderDetails['statut'] == 'Accepte')
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

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'En attente':
        return Colors.orange;
      case 'Acceptée':
        return Colors.green;
      case 'Paiement en attente':
        return Colors.blue;
      case 'Refusée':
        return Colors.red;
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
        title: const Text('Mes Commandes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        toolbarHeight: 64,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('Tous'),
                  selected: _selectedStatus == 'Tous',
                  onSelected: (value) {
                    setState(() => _selectedStatus = 'Tous');
                    _fetchOrders();
                  },
                ),
                ...['En attente', 'Acceptée', 'Paiement en attente', 'Refusée'].map((status) {
                  return ChoiceChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (value) {
                      setState(() => _selectedStatus = status);
                      _fetchOrders();
                    },
                  );
                }),
                ElevatedButton.icon(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() => _selectedDate = selectedDate);
                      _fetchOrders();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16, color: Colors.white,),
                  label: Text(
                    _selectedDate == null
                        ? 'Date'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarycolor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.backgroundcolor,))
                  : _orders.isEmpty
                  ? const Center(child: Text('Aucune commande trouvée.'))
                  : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index].data() as Map<String, dynamic>;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text('Commande #${order['numero_commande']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Statut: ${order['statut']}',
                        style: TextStyle(color: _getStatusTextColor(order['statut'])),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showOrderDetails(order),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
