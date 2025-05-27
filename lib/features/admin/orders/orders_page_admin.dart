import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';



class OrdersPageAdmin extends StatefulWidget {
  const OrdersPageAdmin({super.key});

  @override
  State<OrdersPageAdmin> createState() => _OrdersPageAdminState();
}

class _OrdersPageAdminState extends State<OrdersPageAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
    );
  }
}
