enum NotificationPriority { critical, warning, info }

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    final type = (map['type'] as String? ?? 'info').toLowerCase();
    final priority = switch (type) {
      'alert' => NotificationPriority.critical,
      'warning' => NotificationPriority.warning,
      _ => NotificationPriority.info,
    };

    return NotificationModel(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      priority: priority,
      timestamp: DateTime.parse(map['createdAt'] as String),
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}