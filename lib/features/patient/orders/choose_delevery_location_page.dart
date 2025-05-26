import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChooseDeliveryLocationPage extends StatefulWidget {
  final String demandeId;

  const ChooseDeliveryLocationPage({super.key, required this.demandeId});

  @override
  State<ChooseDeliveryLocationPage> createState() => _ChooseDeliveryLocationPageState();
}

class _ChooseDeliveryLocationPageState extends State<ChooseDeliveryLocationPage> {
  LatLng? selectedPosition;
  String? address;
  final TextEditingController _nameController = TextEditingController();
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

  Future<void> _onMapTap(LatLng pos) async {
    setState(() {
      selectedPosition = pos;
      address = null;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          address = "${place.street}, ${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur géocodage : $e");
      }
    }
  }

  Future<void> _confirmLocation({bool saveToProfile = true}) async {
    if (selectedPosition == null || _nameController.text.isEmpty || address == null) return;

    final locationData = {
      'deliveryPosition': {
        'latitude': selectedPosition!.latitude,
        'longitude': selectedPosition!.longitude,
      },
      'deliveryName': _nameController.text,
      'deliveryAddress': address,
    };

    // Met à jour la commande
    await FirebaseFirestore.instance
        .collection('demandes')
        .doc(widget.demandeId)
        .update(locationData);

    if (saveToProfile) {
      // Ajoute à la liste des positions de l’utilisateur
      final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
      await userRef.update({
        "savedLocations": FieldValue.arrayUnion([
          {
            "name": _nameController.text,
            "latitude": selectedPosition!.latitude,
            "longitude": selectedPosition!.longitude,
            "address": address,
          }
        ])
      });
    }
    if(!mounted) return;

    Navigator.pop(context);
  }

  void _useSavedLocation(Map<String, dynamic> location) async {
    final locationData = {
      'deliveryPosition': {
        'latitude': location["latitude"],
        'longitude': location["longitude"],
      },
      'deliveryName': location["name"],
      'deliveryAddress': location["address"],
    };

    await FirebaseFirestore.instance
        .collection('demandes')
        .doc(widget.demandeId)
        .update(locationData);

    if(!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choisir lieu de livraison")),
      body: Column(
        children: [
          if (savedLocations.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Mes adresses enregistrées :"),
            ),
            ...savedLocations.map((location) => ListTile(
              title: Text(location["name"]),
              subtitle: Text(location["address"]),
              trailing: const Icon(Icons.location_on),
              onTap: () => _useSavedLocation(location),
            )),
            const Divider(),
          ],
          Expanded(
            child: GoogleMap(
              onTap: _onMapTap,
              initialCameraPosition: const CameraPosition(
                target: LatLng(5.3599517, -4.0082563),
                zoom: 14,
              ),
              markers: selectedPosition != null
                  ? {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: selectedPosition!,
                )
              }
                  : {},
            ),
          ),
          if (selectedPosition != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Nom de cette position"),
                  ),
                  const SizedBox(height: 8),
                  Text("Adresse : ${address ?? "Chargement..."}"),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _confirmLocation,
                    icon: const Icon(Icons.check),
                    label: const Text("Confirmer et enregistrer"),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
