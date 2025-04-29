import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import 'package:recherchelivraisonmedicament/core/services/components/my_textfield.dart';

class LoginPage extends StatefulWidget{


  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //controllers
  final TextEditingController emailControler = TextEditingController();

  final TextEditingController passwordControler = TextEditingController();

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
                  controller: emailControler
              ),

              const SizedBox(height: 10,),
              //password
              MyTextField(
                  hintText: "Mot de passe",
                  obscureText: true,
                  controller: passwordControler
              ),

              const SizedBox(height: 10,),
              //forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Mot de passe oublié?'),
                ],
              )

              //sign in button

              //don't have an accunt? register


            ],

          ),
        ),
      ),
    );
  }
}