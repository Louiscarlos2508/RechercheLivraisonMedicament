import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';


class LivreurPageAdmin extends StatefulWidget {
  const LivreurPageAdmin({super.key});

  @override
  State<LivreurPageAdmin> createState() => _LivreurPageAdminState();
}

class _LivreurPageAdminState extends State<LivreurPageAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        centerTitle: true,
        title: Text(
          'Gestion des livreurs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Ajouter un livreur",
              onPressed: (){

              },
              icon: Icon(Icons.person_add_alt_rounded, color: Colors.white,)
          )
        ],
      ),
    );
  }
}
