import 'package:flutter/material.dart';

class DemandeRecente extends StatelessWidget {
  final List<Map<String, String>> demandes;

  const DemandeRecente({super.key, required this.demandes});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en attente':
        return Colors.orange.shade600;
      case 'validée':
        return Colors.green.shade600;
      case 'refusée':
        return Colors.red.shade600;
      default:
        return Colors.blueGrey.shade600;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en attente':
        return Icons.hourglass_top;
      case 'validée':
        return Icons.check_circle;
      case 'refusée':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: demandes.map((demande) {
        final status = demande['status'] ?? '';
        final statusColor = getStatusColor(status);
        final icon = getStatusIcon(status);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            leading: Container(
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: statusColor, size: 28),
            ),
            title: Text(
              "Commande #${demande['orderNumber']}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            subtitle: Text(
              demande['date'] ?? '',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
