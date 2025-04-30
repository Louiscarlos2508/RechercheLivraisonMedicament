import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/services/components/my_button.dart';
import 'package:recherchelivraisonmedicament/core/services/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/helper/helper_funtions.dart';

class RegisterPage extends StatefulWidget{

  final VoidCallback? onTap;
  const RegisterPage({
    super.key,
    required this.onTap
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();
  //login methode
  void register () async{

    //show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator(),
        )
    );

    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPwController.text.isEmpty) {
      displayMessageToUser("Veuillez remplir tous les champs", context);
      return;
    }

    //make sure passwords match
    if(passwordController.text != confirmPwController.text){
      //pop loading circular
      Navigator.pop(context);

      //show error message to user
      displayMessageToUser("Les mots de passe ne correspondent pas", context);
      return;
    }else{
      //try creating the user
      try{
        //create the user
        UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'nom': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'telephone': phoneNumberController.text.trim(),
          'role': 'patient',
          'createdAt': Timestamp.now(),
        });
        if (!mounted) return;
        //pop loading circular
        Navigator.pop(context);
        displayMessageToUser("Compte créé avec succès", context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayMessageToUser(e.message ?? "Erreur inconnue", context);
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
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
          
                  //Username
                  MyTextField(
                      hintText: "Nom complet",
                      obscureText: false,
                      controller: usernameController
                  ),
          
                  const SizedBox(height: 10,),
          
                  //email
                  MyTextField(
                      hintText: "Email",
                      obscureText: false,
                      controller: emailController
                  ),
          
                  const SizedBox(height: 10,),
          
                  //Phone number
                  MyTextField(
                      hintText: "Numéro de téléphone",
                      obscureText: false,
                      controller: phoneNumberController
                  ),
          
                  const SizedBox(height: 10,),
          
                  //password
                  MyTextField(
                      hintText: "Mot de passe",
                      obscureText: true,
                      controller: passwordController
                  ),
          
                  const SizedBox(height: 10,),
          
                  //confirm password
                  MyTextField(
                      hintText: "Confirmer le mot de passe",
                      obscureText: true,
                      controller: confirmPwController
                  ),
          
                  const SizedBox(height: 25,),
          
                  //sign in button
                  MyButton(
                      text: "S'inscrire",
                      onTap: register
                  ),
          
                  const SizedBox(height: 25,),
          
                  //don't have an accunt? register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Vous avez déjà un compte?"),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          " Se connecter ici",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
          
          
                ],
          
              ),
            ),
          ),
        ),
      ),
    );
  }
}