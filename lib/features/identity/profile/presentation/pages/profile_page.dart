import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/di/locale_provider.dart';
import '../../../../../common/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/language_selector.dart';
import '../widgets/profile_info_field.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  // TODO: reemplazar con provider/repositorio real
  UserProfile _profile = const UserProfile(
    userId: 1,
    name: 'Ana María',
    email: 'anamaria@grotix.com',
    phone: '+51 987 654 321',
    role: 'Farm Manager',
    profilePictureUrl: null,
  );

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profile.name);
    _emailController = TextEditingController(text: _profile.email);
    _phoneController = TextEditingController(text: _profile.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Guardar cambios
      setState(() {
        _profile = _profile.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
        );
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.changesSaved),
          backgroundColor: AppColors.greenEmerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _isEditing = true);
    }
  }

  Future<void> _onLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(l10n.logoutConfirmTitle,
            style: const TextStyle(color: AppColors.white)),
        content: Text(l10n.logoutConfirmMessage,
            style: TextStyle(color: AppColors.white.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel,
                style: TextStyle(color: AppColors.white.withOpacity(0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<AuthProvider>().logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

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
                l10n.hello(_profile.firstName),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // ── PERSONAL INFO ──────────────────────────────────
              _SectionHeader(label: l10n.personalInfo),
              const SizedBox(height: 16),

              // Card con avatar + nombre + campos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila: avatar izquierda + nombre/rol derecha
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ProfileAvatar(
                          imageUrl: _profile.profilePictureUrl,
                          isEditing: _isEditing,
                          onTap: _isEditing ? _onPickImage : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profile.name,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _profile.role,
                                style: TextStyle(
                                  color: AppColors.blueCerulean.withOpacity(0.9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campos
                    ProfileInfoField(
                      label: l10n.fullName,
                      value: _profile.name,
                      enabled: _isEditing,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 12),
                    ProfileInfoField(
                      label: l10n.email,
                      value: _profile.email,
                      enabled: _isEditing,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 12),
                    ProfileInfoField(
                      label: l10n.phone,
                      value: _profile.phone,
                      enabled: _isEditing,
                      controller: _phoneController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Botones FUERA del card, en una row
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: _isEditing ? l10n.changesSaved : l10n.edit,
                      color: AppColors.greenEmerald,
                      onTap: _toggleEdit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: l10n.logout,
                      color: AppColors.redCoral,
                      onTap: _onLogout,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── SETTINGS ──────────────────────────────────────
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
                    // Idioma
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
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LanguageSelector(
                      isSpanish: localeProvider.isSpanish,
                      onChanged: (toSpanish) {
                        localeProvider.setLocale(
                          Locale(toSpanish ? 'es' : 'en'),
                        );
                      },
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

  void _onPickImage() {
    // TODO: usar image_picker para seleccionar foto de perfil
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.redAccent,
        fontSize: 22,
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
              borderRadius: BorderRadius.circular(10),
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
                padding: const EdgeInsets.all(4),
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

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
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