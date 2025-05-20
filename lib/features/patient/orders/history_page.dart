import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: Text("Historique des demandes", style: TextStyle(color: AppColors.surfacecolor),),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
    );
  }
}
