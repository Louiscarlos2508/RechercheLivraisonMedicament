import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CommandCards extends StatelessWidget{
  final String fullname;
  final String cmdDate;
  final String cmdNum;
  final String statut;
  final String nbrProduit;
  final Color statutColor;
  
  
  const CommandCards({
    super.key,
    required this.fullname,
    required this.cmdDate,
    required this.cmdNum,
    required this.statut,
    required this.nbrProduit,
    required this.statutColor
  });


  @override
  Widget build(BuildContext context) {
    final gradientStart = AppColors.primarycolor;
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: gradientStart.withValues(alpha: 0.4),
            offset: const Offset(0, 6)
          )
        ]
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    fullname,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18
                    ),
                  ),
                  Text(
                    cmdDate,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12
                    ),
                  )
                ],
              ),
              Text(
                nbrProduit,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18
                ),
              ),
            ],
          ),
          Divider(color: Colors.black,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Num: $cmdNum',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12
                ),
              ),
              Text(
                statut,
                style: TextStyle(
                    color: statutColor,
                    fontSize: 18
                ),
              )
            ],
          ),
        ],
      ),
    );
  }}