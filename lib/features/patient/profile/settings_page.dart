import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> savedLocations = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final doc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
    final data = doc.data();
    if (data != null && data.containsKey("savedLocations")) {
      setState(() {
        savedLocations = List<Map<String, dynamic>>.from(data["savedLocations"]);
      });
    }
  }

  Future<void> _saveAllLocations() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({"savedLocations": savedLocations});
  }

  void _editLocation(int index) {
    final loc = savedLocations[index];
    final nameController = TextEditingController(text: loc["name"]);
    final addressController = TextEditingController(text: loc["address"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier l’adresse"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Adresse"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                savedLocations[index]["name"] = nameController.text;
                savedLocations[index]["address"] = addressController.text;
              });
              await _saveAllLocations();
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          )
        ],
      ),
    );
  }

  void _deleteLocation(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: const Text("Voulez-vous supprimer cette adresse enregistrée ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Non")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Oui")),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        savedLocations.removeAt(index);
      });
      await _saveAllLocations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: Text("Paramètres", style: TextStyle(color: AppColors.surfacecolor),),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
      body: savedLocations.isEmpty
          ? const Center(child: Text("Aucune adresse enregistrée."))
          : ListView.builder(
        itemCount: savedLocations.length,
        itemBuilder: (context, index) {
          final loc = savedLocations[index];
          return ListTile(
            title: Text(loc["name"]),
            subtitle: Text(loc["address"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editLocation(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteLocation(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
