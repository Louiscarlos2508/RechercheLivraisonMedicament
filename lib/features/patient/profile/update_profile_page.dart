import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/utils/helper_funtions.dart';
import 'package:recherchelivraisonmedicament/routes/app_routes.dart';

import '../../../core/widgets/my_elevated_button.dart';


class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();

  String? createdAtText;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snapshot.data();
      if (data != null) {
        await initializeDateFormatting('fr_FR', null);
        final Timestamp? createdAt = data['createdAt'];
        String? createdAtText;
        if (createdAt != null) {
          createdAtText = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(createdAt.toDate());
        }
        setState(() {
          nameController.text = data['nom'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['telephone'] ?? '';
          this.createdAtText = createdAtText;
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Réauthentification si mot de passe actuel fourni
        if (currentPasswordController.text.isNotEmpty) {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: currentPasswordController.text.trim(),
          );
          await user.reauthenticateWithCredential(credential);
        }


        // Mise à jour des données Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'nom': nameController.text.trim(),
          'email': emailController.text.trim(),
          'telephone': phoneController.text.trim(),
        });
        if (!mounted) return;
        displayMessageToUser("Profil mis à jour avec succès", context);
        // Mise à jour du mot de passe
        if (newPasswordController.text.isNotEmpty) {
          await user.updatePassword(newPasswordController.text.trim());
        }

        if (!mounted) return;
        displayMessageToUser("Profil mis à jour avec succès", context);

        Navigator.pop(context, true);
      } on FirebaseAuthException catch (e) {
        String message = 'Erreur inconnue';
        if (e.code == 'wrong-password') {
          message = 'Mot de passe actuel incorrect';
        } else if (e.code == 'requires-recent-login') {
          message = 'Veuillez vous reconnecter pour changer le mot de passe.';
        } else {
          message = e.message ?? message;
        }

        displayMessageToUser(message, context);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    newPasswordController.dispose();
    currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: Text("Modifier le profil", style: TextStyle(color: AppColors.surfacecolor),),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          :SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Icon(Icons.person, size: 120,),
              const SizedBox(height: 25,),
              Form(
                  child: Column(
                    children: [
                      const SizedBox(height: 20,),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                            label: Text("Nom complet", style:
                              TextStyle(
                                color: AppColors.textSecondarycolor
                              ),),
                          prefixIcon: Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                          floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                          )
                            ),
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                            label: Text("E-mail", style:
                            TextStyle(
                                color: AppColors.textSecondarycolor
                            ),),
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                            floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                            )
                        ),
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                            label: Text("Numero de téléphone", style:
                            TextStyle(
                                color: AppColors.textSecondarycolor
                            ),),
                            prefixIcon: Icon(Icons.numbers),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                            floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                            )
                        ),
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        controller: currentPasswordController,
                        decoration: InputDecoration(
                            label: Text("Mot de passe actuel", style:
                            TextStyle(
                                color: AppColors.textSecondarycolor
                            ),),
                            prefixIcon: Icon(Icons.fingerprint),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                            floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                            )
                        ),
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                            label: Text("Nouveau Mot de passe", style:
                            TextStyle(
                                color: AppColors.textSecondarycolor
                            ),),
                            prefixIcon: Icon(Icons.fingerprint),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                            floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                            )
                        ),
                      ),
                      const SizedBox(height: 20,),
                      SizedBox(
                        width: double.infinity,
                        child: MyElevatedButton(
                            text: "Modifier",
                            onPressed: updateProfile
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (createdAtText != null)
                            RichText(
                              text: TextSpan(
                                text: "Créé le ",
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: createdAtText!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ElevatedButton(
                            onPressed: () async {
                              final contextToUse = context; // 👈 Capture du context avant les awaits
                              final user = FirebaseAuth.instance.currentUser;

                              if (user != null) {
                                final confirm = await showDialog<bool>(
                                  context: contextToUse,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Supprimer le compte"),
                                    content: const Text("Voulez-vous vraiment supprimer votre compte ? Cette action est irréversible."),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;

                                try {
                                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                                  await user.delete();

                                  await FirebaseAuth.instance.signOut();

                                  if (!contextToUse.mounted) return;

                                  Navigator.pushReplacementNamed(context, AppRoutes.login);

                                  Navigator.of(contextToUse).pop();
                                  displayMessageToUser("Compte supprimé avec succès.", contextToUse);
                                } on FirebaseAuthException catch (e) {
                                  if (!contextToUse.mounted) return;
                                  if (e.code == 'requires-recent-login') {
                                    displayMessageToUser("Veuillez vous reconnecter pour supprimer votre compte.", contextToUse);
                                  } else {
                                    displayMessageToUser("Erreur : ${e.message}", contextToUse);
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              side: BorderSide.none,
                            ),
                            child: const Text("Supprimer"),
                          )
                        ],
                      )
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
