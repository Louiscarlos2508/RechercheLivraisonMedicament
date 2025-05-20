import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Commande livrée avec succès !"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Nouvelle pharmacie disponible proche de vous."),
          ),
        ],
      ),
    );
  }
}
