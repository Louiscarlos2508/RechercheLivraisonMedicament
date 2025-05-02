import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/widgets/my_button.dart';
import 'package:recherchelivraisonmedicament/core/widgets/my_textfield.dart';
import 'package:recherchelivraisonmedicament/core/utils/helper_funtions.dart';
import 'package:recherchelivraisonmedicament/routes.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});


  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final TextEditingController resetEmailController = TextEditingController();

  void resetPassword() async{
    final email = resetEmailController.text.trim();
    
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator(),
        )
    );

    if(email.isEmpty){
      Navigator.pop(context);
      displayMessageToUser("Veuillez entrer votre email!", context);
      return;
    }


    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      Navigator.pop(context);
      displayMessageToUser("Le lien de réinitialisation a été envoyé à $email", context);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.login);
    }on FirebaseAuthException catch (e){
      Navigator.pop(context);
      displayMessageToUser(e.message ?? "Une erreur s'est produite", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Réinitialisation",
        style: TextStyle(
          color: AppColors.textPrimarycolor
        ),
        ),
        iconTheme: IconThemeData(color: AppColors.primarycolor),
      ),
      backgroundColor: AppColors.backgroundcolor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Entrez votre adresse e-mail et nous vous enverrons un lien de réinitialisation du mot de passe",
              textAlign: TextAlign.center,
              ),
              SizedBox(height: 10,),

              MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: resetEmailController,
              ),

              SizedBox(height: 10,),

              MyButton(
                  text: "Réinitialiser",
                  onTap: resetPassword
              )
            ],
          ),
        ),
      ),
    );
  }
}
