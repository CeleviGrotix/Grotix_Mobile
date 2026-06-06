import 'package:flutter/material.dart';

enum NotificationPriority { critical, warning, info }

class NotificationModel {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final Map<String, String>? descriptionArgs;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    this.descriptionArgs,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
  });
}

// Lista Mock para desarrollo con fechas relativas
List<NotificationModel> getMockNotifications() {
  final now = DateTime.now();
  return [
    NotificationModel(
      id: '1',
      titleKey: 'notifCriticalTitle',
      descriptionKey: 'notifCriticalDesc',
      descriptionArgs: {'zone': 'Zona A'},
      priority: NotificationPriority.critical,
      timestamp: now.subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: '2',
      titleKey: 'notifWarningTitle',
      descriptionKey: 'notifWarningDesc',
      descriptionArgs: {'zone': 'Zona B'},
      priority: NotificationPriority.warning,
      timestamp: now.subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: '3',
      titleKey: 'notifInfoTitle',
      descriptionKey: 'notifInfoDesc',
      descriptionArgs: {'farm': 'Granja Norte'},
      priority: NotificationPriority.info,
      timestamp: now.subtract(const Duration(days: 1, hours: 4)),
      isRead: true,
    ),
  ];
}