import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: Text("Paramètres", style: TextStyle(color: AppColors.surfacecolor),),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
    );
  }
}
