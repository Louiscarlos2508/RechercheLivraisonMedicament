import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

import 'new_orders_page.dart';
import 'orders_history_page.dart';



class OrdersPageAdmin extends StatefulWidget {
  const OrdersPageAdmin({super.key});

  @override
  State<OrdersPageAdmin> createState() => _OrdersPageAdminState();
}

class _OrdersPageAdminState extends State<OrdersPageAdmin> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        backgroundColor: AppColors.primarycolor,
        centerTitle: true,
        title: Text(
          'Commandes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildToggleButon('En cours', 0),
                _buildToggleButon('Terminées', 1),
              ]
            ),
          ),
          Expanded(
              child: currentIndex == 0
                  ? NewOrdersPage()
                  : OrdersHistoryPage(),
          )
        ]
      ),
    );
  }

  Widget _buildToggleButon(String title, int index){
    bool isActive = currentIndex == index;
    return Expanded(
        child: GestureDetector(
          onTap: (){
            setState(() {
              currentIndex = index;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.backgroundcolor,
                //borderRadius: BorderRadius.circular(12)
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                    title,
                    style: TextStyle(
                      color: isActive ? AppColors.primarycolor : Colors.black,
                      fontWeight: FontWeight.bold,
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: isActive ? AppColors.primarycolor : Colors.white,
                    height: 20,
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}

