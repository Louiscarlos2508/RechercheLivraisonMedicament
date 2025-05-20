import 'package:flutter/material.dart';

class PharmacyCard extends StatelessWidget {
  final String name;

  const PharmacyCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.orange.withValues(alpha: 0.35),
      ),
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
