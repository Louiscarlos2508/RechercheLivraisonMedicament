import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Stream<List<NotificationModel>> getUserNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null || data['notifications'] == null) return [];
      final List notifs = data['notifications'];
      return notifs.map((n) => NotificationModel.fromMap(Map<String, dynamic>.from(n))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.surfacecolor,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primarycolor));
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune notification pour l’instant."));
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                leading: Icon(
                  notif.isRead ? Icons.notifications : Icons.notifications_active,
                  color: notif.isRead ? Colors.grey : AppColors.primarycolor,
                ),
                title: Text(notif.title),
                subtitle: Text(notif.body),
                trailing: Text(
                  "${notif.timestamp.hour.toString().padLeft(2, '0')}:${notif.timestamp.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
