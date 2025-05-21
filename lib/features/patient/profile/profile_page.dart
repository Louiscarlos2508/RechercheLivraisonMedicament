import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/widgets/my_elevated_button.dart';
import 'package:recherchelivraisonmedicament/features/patient/profile/update_profile_page.dart';
import '../../../core/widgets/profil_menu_widget.dart';
import '../../../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userEmail;
  String? userPhone;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = userDoc.data();
        if (data != null) {
          setState(() {
            userName = data['nom'];
            userEmail = data['email'];
            userPhone = data['telephone'];
            isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur Firestore: $e');
      debugPrint('🔍 Stack trace: $stackTrace');
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        title: const Text("Mon Profil", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primarycolor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            _buildMenuItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.primarycolor,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              userName ?? 'Nom inconnu',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(userEmail ?? 'Email inconnu', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text("Téléphone : ${userPhone ?? 'Inconnu'}", style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 15),
            SizedBox(
              width: 160,
              child: MyElevatedButton(
                text: "Modifier le profil",
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
                  );
                  if (updated == true) {
                    fetchUserData();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        ProfileMenuWidget(
          title: "Historique des demandes",
          icon: Icons.history,
          onPress: () => Navigator.pushNamed(context, AppRoutes.requestHistoryPage),
        ),
        ProfileMenuWidget(
          title: "Paramètres",
          icon: Icons.settings,
          onPress: () => Navigator.pushNamed(context, AppRoutes.settingsPage),
        ),
        ProfileMenuWidget(
          title: "Soutien / Aide",
          icon: Icons.help_outline,
          onPress: () => Navigator.pushNamed(context, AppRoutes.helpPage),
        ),
        const Divider(),
        ProfileMenuWidget(
          title: "À propos",
          icon: Icons.info_outline,
          onPress: () => Navigator.pushNamed(context, AppRoutes.aboutPage),
        ),
        ProfileMenuWidget(
          title: "Se déconnecter",
          icon: Icons.logout,
          textColor: Colors.red,
          endIcon: false,
          onPress: () => logout(context),
        ),
      ],
    );
  }
}
