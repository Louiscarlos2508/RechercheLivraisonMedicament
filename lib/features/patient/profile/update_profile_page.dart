import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helper_funtions.dart';
import '../../../core/widgets/my_elevated_button.dart';
import '../../../routes/app_routes.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final currentPasswordController = TextEditingController();

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
        final createdAt = data['createdAt'] as Timestamp?;
        setState(() {
          nameController.text = data['nom'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['telephone'] ?? '';
          createdAtText = createdAt != null
              ? DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(createdAt.toDate())
              : null;
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (currentPasswordController.text.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPasswordController.text.trim(),
        );
        await user.reauthenticateWithCredential(credential);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'nom': nameController.text.trim(),
        'email': emailController.text.trim(),
        'telephone': phoneController.text.trim(),
      });

      if (newPasswordController.text.isNotEmpty) {
        await user.updatePassword(newPasswordController.text.trim());
      }

      if (!mounted) return;
      displayMessageToUser("Profil mis à jour avec succès", context);
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'wrong-password' => 'Mot de passe actuel incorrect',
        'requires-recent-login' => 'Veuillez vous reconnecter pour changer le mot de passe.',
        _ => e.message ?? 'Erreur inconnue'
      };
      displayMessageToUser(message, context);
    }
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer le compte"),
        content: const Text("Voulez-vous vraiment supprimer votre compte ? Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      displayMessageToUser("Compte supprimé avec succès.", context);
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'requires-recent-login'
          ? "Veuillez vous reconnecter pour supprimer votre compte."
          : "Erreur : ${e.message}";
      if (!mounted) return;
      displayMessageToUser(msg, context);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        label: Text(label, style: TextStyle(color: AppColors.textSecondarycolor)),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
        floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(width: 2, color: AppColors.primarycolor),
        ),
      ),
    );
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
        title: const Text("Modifier le profil", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primarycolor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person, size: 100),
              const SizedBox(height: 20),
              _buildTextField(controller: nameController, label: "Nom complet", icon: Icons.person_outline_rounded),
              const SizedBox(height: 20),
              _buildTextField(controller: emailController, label: "E-mail", icon: Icons.email_outlined),
              const SizedBox(height: 20),
              _buildTextField(controller: phoneController, label: "Numéro de téléphone", icon: Icons.phone),
              const SizedBox(height: 20),
              _buildTextField(controller: currentPasswordController, label: "Mot de passe actuel", icon: Icons.lock_outline, obscure: true),
              const SizedBox(height: 20),
              _buildTextField(controller: newPasswordController, label: "Nouveau mot de passe", icon: Icons.lock_open, obscure: true),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: MyElevatedButton(text: "Modifier", onPressed: updateProfile),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (createdAtText != null)
                    Text("Créé le $createdAtText", style: const TextStyle(fontSize: 12)),
                  ElevatedButton(
                    onPressed: deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text("Supprimer"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
