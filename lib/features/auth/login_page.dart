import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/services/components/my_button.dart';
import 'package:recherchelivraisonmedicament/core/services/components/my_textfield.dart';

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
  void login(){}

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
                  Text('Mot de passe oublié?'),
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