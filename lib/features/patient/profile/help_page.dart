import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';


class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: Text("Soutien/Aide", style: TextStyle(color: AppColors.surfacecolor),),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
    );
  }
}
