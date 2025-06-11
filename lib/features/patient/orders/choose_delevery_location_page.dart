import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

class ChooseDeliveryLocationPage extends StatefulWidget {
  final String demandeId;

  const ChooseDeliveryLocationPage({super.key, required this.demandeId});

  @override
  State<ChooseDeliveryLocationPage> createState() => _ChooseDeliveryLocationPageState();
}

class _ChooseDeliveryLocationPageState extends State<ChooseDeliveryLocationPage> {
  LatLng? selectedPosition;
  LatLng? currentPosition;
  String? address;
  final TextEditingController _nameController = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoadingCurrentLocation = true;

  List<Map<String, dynamic>> savedLocations = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez activer les services de localisation')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Les permissions de localisation sont requises')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        selectedPosition = currentPosition;
        _isLoadingCurrentLocation = false;
      });

      // Récupérer l'adresse de la position actuelle
      _getAddressFromLatLng(currentPosition!);
    } catch (e) {
      if (kDebugMode) {
        print("Erreur de localisation : $e");
      }
      setState(() {
        _isLoadingCurrentLocation = false;
        currentPosition = const LatLng(5.3599517, -4.0082563); // Position par défaut
        selectedPosition = currentPosition;
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

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
    if (selectedPosition == null || _nameController.text.isEmpty || address == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une position valide')),
      );
      return;
    }

    try {
      final locationData = {
        'deliveryPosition': {
          'latitude': selectedPosition!.latitude,
          'longitude': selectedPosition!.longitude,
        },
        'deliveryName': _nameController.text,
        'deliveryAddress': address,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // 1. Check if document exists first
      final docRef = FirebaseFirestore.instance
          .collection('demandes')
          .doc(widget.demandeId);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande introuvable')),
        );
        return;
      }

      // 2. Update or create document
      await docRef.set(locationData, SetOptions(merge: true));

      if (saveToProfile) {
        // Add to user's saved locations
        final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
        await userRef.set({
          "savedLocations": FieldValue.arrayUnion([{
            "name": _nameController.text,
            "latitude": selectedPosition!.latitude,
            "longitude": selectedPosition!.longitude,
            "address": address,
          }])
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      Navigator.pop(context, locationData); // Return location data
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
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
      appBar: AppBar(
          title: const Text("Choisir lieu de livraison", style: TextStyle(
            color: Colors.white
          ),),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
      body: _isLoadingCurrentLocation
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
              initialCameraPosition: CameraPosition(
                target: currentPosition ?? const LatLng(5.3599517, -4.0082563),
                zoom: 14,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
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
                    icon: const Icon(Icons.check, color: AppColors.primarycolor,),
                    label: const Text("Confirmer et enregistrer", style: TextStyle(
                      color: AppColors.primarycolor
                    ),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
