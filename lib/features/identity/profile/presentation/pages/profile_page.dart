import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/di/locale_provider.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../provider/profile_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/profile_info_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Carga el perfil real al entrar a la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
      context.read<ProfileProvider>().loadUnreadCount();
    });
  }

  Future<void> _onLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(l10n.logoutConfirmTitle,
            style: const TextStyle(color: AppColors.white)),
        content: Text(l10n.logoutConfirmMessage,
            style: TextStyle(color: AppColors.white.withOpacity(0.7))),
        actions: [
          TextButton(
            // para cerrar SOLO el diálogo
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel,
                style: TextStyle(color: AppColors.white.withOpacity(0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    // Solo si se confirmó de verdad, procedemos al logout
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        // Usamos go para resetear el stack de navegación al login
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileProvider = context.watch<ProfileProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final user = profileProvider.user;

    // Loading inicial
    if (profileProvider.isLoading && user == null) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.greenEmerald),
        ),
      );
    }

    // Error al cargar
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.circleExclamation,
                  size: 40, color: AppColors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(profileProvider.errorMessage ?? 'Could not load profile',
                  style: TextStyle(
                      color: AppColors.white.withOpacity(0.5), fontSize: 15)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: profileProvider.loadProfile,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenEmerald),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final isEditing = profileProvider.isEditing;
    final roleName = user.isAdmin ? 'Administrator' : 'User';
    final associationName = context.watch<ProfileProvider>().associationName;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Saludo
              Text(
                l10n.hello(user.displayName.split(' ').first),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // ── PERSONAL INFO ─────────────────────────────────
              _SectionHeader(label: l10n.personalInfo),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + nombre + rol
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ProfileAvatar(
                          imageUrl: user.profilePicture,
                          isEditing: isEditing,
                          onTap: isEditing
                              ? () => profileProvider
                              .pickAndUploadProfilePicture(context)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                roleName,
                                style: const TextStyle(
                                  color: AppColors.greenEmerald,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campos editables
                    ProfileInfoField(
                      label: l10n.associationName,
                      value: associationName,
                      enabled: false,
                      controller: profileProvider.nameController,
                    ),
                    const SizedBox(height: 12),

                    // Email — nunca editable (es la identidad)
                    ProfileInfoField(
                      label: l10n.email,
                      value: user.email,
                      enabled: false,
                    ),
                    const SizedBox(height: 12),

                    ProfileInfoField(
                      label: l10n.phone,
                      value: user.phone,
                      enabled: isEditing,
                      controller: profileProvider.phoneController,
                    ),
                    const SizedBox(height: 12),

                    ProfileInfoField(
                      label: l10n.taxId,
                      value: user.taxId,
                      enabled: isEditing,
                      controller: profileProvider.taxIdController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Botones EDIT / LOG OUT fuera del card
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: isEditing ? l10n.save : l10n.edit,
                      color: AppColors.greenEmerald,
                      isLoading: profileProvider.isLoading,
                      onTap: isEditing
                          ? () => profileProvider.saveProfileChanges(context)
                          : profileProvider.toggleEditing,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isEditing)
                    Expanded(
                      child: _ActionButton(
                        label: l10n.cancel,
                        color: Colors.white24,
                        onTap: profileProvider.toggleEditing,
                      ),
                    )
                  else
                    Expanded(
                      child: _ActionButton(
                        label: l10n.logout,
                        color: Colors.redAccent,
                        onTap: _onLogout,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 28),

              // ── NOTIFICATIONS ─────────────────────────────────
              _SectionHeader(label: l10n.notifications),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _NotificationToggle(
                      label: l10n.pushNotifications,
                      icon: FontAwesomeIcons.bell,
                      value: user.preferences['push'] == true,
                      onChanged: (val) => profileProvider.updatePreferences({
                        ...user.preferences,
                        'push': val,
                      }),
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _NotificationToggle(
                      label: l10n.emailNotifications,
                      icon: FontAwesomeIcons.envelope,
                      value: user.preferences['email'] == true,
                      onChanged: (val) => profileProvider.updatePreferences({
                        ...user.preferences,
                        'email': val,
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── SETTINGS ─────────────────────────────────────
              _SectionHeader(label: l10n.settings),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.globe,
                            size: 15,
                            color: AppColors.white.withOpacity(0.6)),
                        const SizedBox(width: 8),
                        Text(
                          l10n.language,
                          style: TextStyle(
                              color: AppColors.white.withOpacity(0.6),
                              fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LanguageSelector(
                      isSpanish: localeProvider.isSpanish,
                      onChanged: (toSpanish) => localeProvider.setLocale(
                        Locale(toSpanish ? 'es' : 'en'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets privados ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.redAccent,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isEditing;
  final VoidCallback? onTap;

  const _ProfileAvatar({this.imageUrl, required this.isEditing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white10,
              image: imageUrl != null
                  ? DecorationImage(
                  image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: imageUrl == null
                ? const Icon(Icons.person, color: Colors.white30, size: 40)
                : null,
          ),
          if (isEditing)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.greenEmerald,
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(FontAwesomeIcons.pen,
                    size: 10, color: AppColors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.white),
          ),
        )
            : Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: 15, color: AppColors.white.withOpacity(0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                color: AppColors.white.withOpacity(0.85), fontSize: 15),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.greenEmerald,
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}