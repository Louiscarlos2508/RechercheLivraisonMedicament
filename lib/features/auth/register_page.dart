import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/services/components/my_button.dart';
import 'package:recherchelivraisonmedicament/core/services/components/my_textfield.dart';

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
  void register(){}

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