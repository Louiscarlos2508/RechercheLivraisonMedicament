import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

String generateShortNumeroCommande() {
  final milliseconds = DateTime.now().millisecondsSinceEpoch;
  return 'CMD${milliseconds.toRadixString(36).toUpperCase()}';
}



Future<String?> submitDemande({
  required List<Map<String, dynamic>> listeDemande,
  required File? ordonnanceImage,
  required bool besoinUrgent,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return "Utilisateur non connecté";

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final phoneNumber = userDoc.data()?['telephone'] ?? '';
  final double prixTotal = 0;

  if (listeDemande.isEmpty && ordonnanceImage == null) {
    return "Veuillez ajouter au moins un médicament ou une ordonnance.";
  }

  String? ordonnanceUrl;
  try {
    if (ordonnanceImage != null) {
      final fileName = "${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child("ordonnances").child(fileName);
      await ref.putFile(ordonnanceImage);
      ordonnanceUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection("demandes").add({
      "userId": user.uid,
      "email": user.email,
      "phoneNumber": phoneNumber,
      'numero_commande': generateShortNumeroCommande(),
      "medicaments": listeDemande,
      "ordonnanceUrl": ordonnanceUrl,
      "urgent": besoinUrgent,
      "timestamp": FieldValue.serverTimestamp(),
      'statut': 'En attente',
      'prixTotal': prixTotal,
    });

    return FirebaseFirestore.instance.collection("demandes").id;
  } catch (e) {
    return "Erreur : ${e.toString()}";
  }
}
