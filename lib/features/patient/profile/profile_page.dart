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

  void logout(BuildContext context) async{
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
        centerTitle: true,
        title: Text("Profil", style: TextStyle(color: AppColors.surfacecolor),),
        automaticallyImplyLeading: true,
      ),
      body:isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Icon(Icons.person, size: 120,),
                const SizedBox(height: 15,),
                Text(userName ?? 'Nom inconnu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                Text(userEmail ?? 'Email inconnu', style: TextStyle(fontSize: 15)),
                Text("Tel: ${userPhone ?? 'Inconnu'}", style: TextStyle(fontSize: 15)),
                const SizedBox(height: 15,),
                SizedBox(
                  width: 200,
                  child: MyElevatedButton(
                      text: "Modifier",
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UpdateProfilePage()),
                        );
                        if (updated == true) {
                          fetchUserData();
                        }
                      }
                  ),
                ),
                const SizedBox(height: 30,),
                const Divider(),
                const SizedBox(height: 10,),

                ProfileMenuWidget(
                  title: "Historique des demandes",
                  icon: Icons.history,
                  onPress: (){
                    Navigator.pushNamed(context, AppRoutes.requestHistoryPage);
                  },
                ),
                ProfileMenuWidget(
                  title: "Paramètres",
                  icon: Icons.settings,
                  onPress: (){
                    Navigator.pushNamed(context, AppRoutes.settingsPage);
                  },
                ),
                ProfileMenuWidget(
                  title: "Soutien/Aide",
                  icon: Icons.help,
                  onPress: (){
                    Navigator.pushNamed(context, AppRoutes.helpPage);
                  },
                ),
                const Divider(),
                const SizedBox(height: 10,),
                ProfileMenuWidget(
                  title: "À propos",
                  icon: Icons.info,
                  onPress: (){
                    Navigator.pushNamed(context, AppRoutes.aboutPage);
                  },
                ),
                ProfileMenuWidget(
                  title: "Se déconnecter",
                  icon: Icons.logout,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: () => logout(context),
                ),

              ],
            ),
          )
      ),
    );
  }
}


