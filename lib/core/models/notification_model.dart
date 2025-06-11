import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
