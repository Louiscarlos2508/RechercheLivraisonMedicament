import 'package:flutter/material.dart';

class AttributionLivreurPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const AttributionLivreurPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attribuer un livreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Commande #${order['cmdNum']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigation vers liste livreurs à implémenter
              },
              child: const Text('Sélectionner un livreur'),
            )
          ],
        ),
      ),
    );
  }
}
