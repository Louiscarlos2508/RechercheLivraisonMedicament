import 'package:flutter/material.dart';

class HealthAdviceCard extends StatelessWidget {
  final String advice;

  const HealthAdviceCard({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100,
            blurRadius: 6,
            offset: const Offset(2, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.health_and_safety, color: Colors.green, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              advice,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}
