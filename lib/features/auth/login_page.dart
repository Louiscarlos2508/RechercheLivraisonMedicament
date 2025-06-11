import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/widgets/my_gesture_detector_button.dart';
import 'package:recherchelivraisonmedicament/core/widgets/my_textfield.dart';
import 'package:recherchelivraisonmedicament/core/utils/helper_funtions.dart';
import 'package:recherchelivraisonmedicament/routes/app_routes.dart';

class LoginPage extends StatefulWidget{

  final VoidCallback? onTap;
  const LoginPage({
    super.key,
    required this.onTap
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //controllers
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  //login methode
  void login() async{
    showDialog(context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primarycolor,),
        )
    );

    if(emailController.text.isEmpty || passwordController.text.isEmpty) {
      Navigator.pop(context);
      displayMessageToUser("Veuillez remplir tous les champ", context);
      return;
    }
    // auth
    try{
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim()
      );

      final uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

      if (!mounted) return;
      if(!userDoc.exists){
        Navigator.pop(context);
        displayMessageToUser("Utilisateur non trouvé", context);
        return;
      }

      final role = userDoc['role'];
      Navigator.pop(context);


      if(role == 'admin'){
        Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
      }else if(role == 'patient'){
        Navigator.pushReplacementNamed(context, AppRoutes.patientHome);
      }else if(role == 'livreur'){
        Navigator.pushReplacementNamed(context, AppRoutes.livreurHome);
      }else{
        Navigator.pop(context);
        displayMessageToUser("Utilisateur non trouvé", context);
      }
    }on FirebaseAuthException catch (e){
      Navigator.pop(context);
      displayMessageToUser(e.message ?? "Une erreur s'est produite", context);
    }
  }

  // In your stateful widgets:
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Image.asset(
                'assets/images/medicine.png',
                width: 100,
                height: 100,
              ),

              const SizedBox(height: 25,),

              //app name
              Text(
                'RechercheLivraisonMedicament',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 50,),

              //email
              MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController
              ),

              const SizedBox(height: 10,),
              //password
              MyTextField(
                  hintText: "Mot de passe",
                  obscureText: true,
                  controller: passwordController
              ),

              const SizedBox(height: 15,),
              //forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.resetPassword);
                    },
                    child: Text('Mot de passe oublié?', style:
                    TextStyle(
                        color: Colors.blueAccent
                    ),),
                  )
                ],
              ),

              const SizedBox(height: 25,),

              //sign in button
              MyButton(
                  text: "Se connecter",
                  onTap: login
              ),

              const SizedBox(height: 25,),

              //don't have an accunt? register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous n'avez pas de compte?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                        " S'inscrire ici",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent
                      ),
                    ),
                  )
                ],
              ),


            ],

          ),
        ),
      ),
    );
  }
}