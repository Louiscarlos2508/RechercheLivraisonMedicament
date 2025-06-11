import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

class GestionCommandePage extends StatefulWidget {
  final Map<String, dynamic> order;

  const GestionCommandePage({super.key, required this.order});

  @override
  State<GestionCommandePage> createState() => _GestionCommandePageState();
}

class _GestionCommandePageState extends State<GestionCommandePage> {
  late TextEditingController _prixTotalController;
  List<TextEditingController> _prixParProduitControllers = [];
  Position? _clientPosition;
  List<Map<String, dynamic>> _pharmaciesProches = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _prixTotalController = TextEditingController();
    _initControllers();
    _fetchClientPositionEtPharmacies();
  }

  void _initControllers() {
    final medicaments = widget.order['medicaments'] ?? [];
    _prixParProduitControllers = List.generate(
      medicaments.length,
          (index) => TextEditingController(),
    );
  }

  Future<void> _fetchClientPositionEtPharmacies() async {
    final livraison = widget.order['livraison'];
    if (livraison != null && livraison['lat'] != null && livraison['lng'] != null) {
      final position = Position(
        latitude: livraison['lat'],
        longitude: livraison['lng'],
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
      setState(() => _clientPosition = position);

      final pharmaciesSnapshot = await FirebaseFirestore.instance.collection('pharmacies').get();
      final List<Map<String, dynamic>> proches = [];

      for (var doc in pharmaciesSnapshot.docs) {
        final data = doc.data();
        if (data['lat'] != null && data['lng'] != null) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            data['lat'],
            data['lng'],
          );
          if (distance <= 10000) {
            proches.add({...data, 'distance': distance});
          }
        }
      }

      proches.sort((a, b) => a['distance'].compareTo(b['distance']));
      setState(() => _pharmaciesProches = proches);
    }
  }

  @override
  void dispose() {
    _prixTotalController.dispose();
    for (var controller in _prixParProduitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _refuserCommande() async {
    await FirebaseFirestore.instance
        .collection('demandes')
        .doc(widget.order['id'])
        .update({'statut': 'Refusée'});

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _validerPrix() async {
    if (_formKey.currentState!.validate()) {
      double prixTotal = double.parse(_prixTotalController.text);
      await FirebaseFirestore.instance
          .collection('demandes')
          .doc(widget.order['id'])
          .update({'prixTotal': prixTotal, 'statut': 'Paiement en attente'});

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicaments = widget.order['medicaments'] ?? [];
    final ordonnanceUrl = widget.order['ordonnanceUrl'];

    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: const Text('Gérer la commande', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (medicaments != null) ...[
                const Text('Liste des médicaments :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...List.generate(medicaments.length, (index) {
                  final med = medicaments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${med['nom']} ${med['dosage']} ${med['unite']} x${med['quantite']}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          TextField(
                            controller: _prixParProduitControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Prix (FCFA) - optionnel'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              if (ordonnanceUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ordonnance du client :', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(ordonnanceUrl, height: 200, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _prixTotalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix total (obligatoire)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Le prix total est requis';
                  if (double.tryParse(value) == null) return 'Entrez un nombre valide';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _validerPrix,
                icon: const Icon(Icons.check),
                label: const Text('Valider et demander paiement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarycolor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _refuserCommande,
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text('Refuser la commande', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 20),
              if (_pharmaciesProches.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pharmacies à proximité :', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ..._pharmaciesProches.map((pharma) => Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(pharma['nom'] ?? 'Pharmacie'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pharma['telephone'] != null) Text('📞 ${pharma['telephone']}'),
                            Text('${(pharma['distance'] / 1000).toStringAsFixed(2)} km'),
                          ],
                        ),
                        leading: const Icon(Icons.local_pharmacy, color: Colors.green),
                      ),
                    )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
