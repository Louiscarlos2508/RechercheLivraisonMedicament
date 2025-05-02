import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/widgets/my_elevated_button.dart';
import '../../../core/widgets/profil_menu_widget.dart';
import '../../../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

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
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Profil"),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Icon(Icons.person, size: 120,),
                const SizedBox(height: 15,),
                Text("Carlos Simporé", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                Text("test1234@gmail.com", style: TextStyle(fontSize: 15)),
                const SizedBox(height: 15,),
                SizedBox(
                  width: 200,
                  child: MyElevatedButton(
                      text: "Modifier",
                      onTap: (){

                      }
                  ),
                ),
                const SizedBox(height: 30,),
                const Divider(),
                const SizedBox(height: 10,),

                ProfileMenuWidget(
                  title: "Historique des demandes",
                  icon: Icons.history,
                  onPress: (){},
                ),
                ProfileMenuWidget(
                  title: "Paramètres",
                  icon: Icons.settings,
                  onPress: (){},
                ),
                ProfileMenuWidget(
                  title: "Soutien/Aide",
                  icon: Icons.help,
                  onPress: (){},
                ),
                const Divider(),
                const SizedBox(height: 10,),
                ProfileMenuWidget(
                  title: "À propos",
                  icon: Icons.info,
                  onPress: (){},
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


