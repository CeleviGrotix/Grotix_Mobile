import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';
import '../../../../features/identity/profile/presentation/provider/profile_provider.dart';
import '../../domain/entities/notification.dart';

class NotificationsDrawer extends StatefulWidget {
  const NotificationsDrawer({super.key});

  @override
  State<NotificationsDrawer> createState() => _NotificationsDrawerState();
}

class _NotificationsDrawerState extends State<NotificationsDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ProfileProvider>();

    final rawNotifications = provider.notifications;
    final notifications = rawNotifications
        .map((n) => NotificationModel.fromMap(n))
        .toList();

    final now = DateTime.now();
    final todayNotifs = notifications.where((n) =>
    n.timestamp.year == now.year &&
        n.timestamp.month == now.month &&
        n.timestamp.day == now.day).toList();
    final olderNotifs = notifications
        .where((n) => !todayNotifs.contains(n))
        .toList();

    return Drawer(
      backgroundColor: AppColors.darkNotis,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.notificationsTitle,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      if (notifications.any((n) => !n.isRead))
                        TextButton(
                          onPressed: () => provider.markAllAsRead(),
                          child: Text(
                            l10n.markAllRead,
                            style: const TextStyle(
                              color: AppColors.greenEmerald,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.xmark,
                          color: AppColors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Content ─────────────────────────────────────────
            Expanded(
              child: provider.isLoading && notifications.isEmpty
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.greenEmerald,
                ),
              )
                  : notifications.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 64),
                  child: Text(
                    l10n.noNotifications,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.4),
                      fontSize: 16,
                    ),
                  ),
                ),
              )
                  : RefreshIndicator(
                color: AppColors.greenEmerald,
                onRefresh: () => provider.loadNotifications(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (todayNotifs.isNotEmpty) ...[
                      _SectionHeader(label: l10n.todaySection),
                      const SizedBox(height: 8),
                      ...todayNotifs.map((n) => _NotificationCard(
                        notification: n,
                        onTap: n.isRead
                            ? null
                            : () => provider.markAsRead(n.id),
                      )),
                      const SizedBox(height: 24),
                    ],
                    if (olderNotifs.isNotEmpty) ...[
                      _SectionHeader(label: l10n.olderSection),
                      const SizedBox(height: 8),
                      ...olderNotifs.map((n) => _NotificationCard(
                        notification: n,
                        onTap: n.isRead
                            ? null
                            : () => provider.markAsRead(n.id),
                      )),
                    ],
                  ],
                ),
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
  final VoidCallback? onTap;

  const _NotificationCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = switch (notification.priority) {
      NotificationPriority.critical =>
      (FontAwesomeIcons.triangleExclamation, AppColors.redCoral),
      NotificationPriority.warning =>
      (FontAwesomeIcons.circleExclamation, Colors.orange),
      NotificationPriority.info =>
      (FontAwesomeIcons.circleInfo, AppColors.greenEmerald),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead
              ? null
              : Border.all(color: iconColor.withOpacity(0.3), width: 1),
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
                          notification.title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm').format(notification.timestamp),
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.6),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (!notification.isRead) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Toca para marcar como leído',
                      style: TextStyle(
                        color: iconColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}