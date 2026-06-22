import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';

import '../../domain/entities/notification.dart';

class NotificationsDrawer extends StatelessWidget {
  const NotificationsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = getMockNotifications();

    final now = DateTime.now();
    final todayNotifs = notifications.where((n) =>
    n.timestamp.year == now.year &&
        n.timestamp.month == now.month &&
        n.timestamp.day == now.day).toList();

    final olderNotifs = notifications.where((n) => !todayNotifs.contains(n)).toList();

    return Drawer(
      backgroundColor: AppColors.darkNotis,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.notificationsTitle,
                    style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.xmark, color: AppColors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(), // Cierra el Drawer
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (todayNotifs.isNotEmpty) ...[
                    _SectionHeader(label: l10n.todaySection),
                    const SizedBox(height: 8),
                    ...todayNotifs.map((n) => _NotificationCard(notification: n)),
                    const SizedBox(height: 24),
                  ],
                  if (olderNotifs.isNotEmpty) ...[
                    _SectionHeader(label: l10n.olderSection),
                    const SizedBox(height: 8),
                    ...olderNotifs.map((n) => _NotificationCard(notification: n)),
                  ],
                  if (notifications.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        child: Text(
                          l10n.noNotifications,
                          style: TextStyle(color: AppColors.white.withOpacity(0.4), fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.greenEmerald,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (icon, iconColor) = switch (notification.priority) {
      NotificationPriority.critical => (FontAwesomeIcons.triangleExclamation, AppColors.redCoral),
      NotificationPriority.warning => (FontAwesomeIcons.circleExclamation, Colors.orange),
      NotificationPriority.info => (FontAwesomeIcons.circleInfo, AppColors.greenEmerald),
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCardBg,
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead ? null : Border.all(color: iconColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: FaIcon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getLocalizedStr(notification.titleKey, l10n),
                        style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm').format(notification.timestamp),
                      style: TextStyle(color: AppColors.white.withOpacity(0.4), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getLocalizedDesc(notification.descriptionKey, notification.descriptionArgs, l10n),
                  style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helpers de traducción
  String _getLocalizedStr(String key, AppLocalizations l10n) {
    return switch (key) {
      'notifCriticalTitle' => l10n.notifCriticalTitle,
      'notifWarningTitle' => l10n.notifWarningTitle,
      'notifInfoTitle' => l10n.notifInfoTitle,
      _ => key,
    };
  }

  String _getLocalizedDesc(String key, Map<String, String>? args, AppLocalizations l10n) {
    final zone = args?['zone'] ?? '';
    final farm = args?['farm'] ?? '';
    return switch (key) {
      'notifCriticalDesc' => l10n.notifCriticalDesc(zone),
      'notifWarningDesc' => l10n.notifWarningDesc(zone),
      'notifInfoDesc' => l10n.notifInfoDesc(farm),
      _ => key,
    };
  }
}
