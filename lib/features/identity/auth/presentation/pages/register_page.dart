import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';
import '../widgets/error_banner.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteTokenController = TextEditingController();
  bool _obscurePassword = true;
  bool _registeredOk = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _inviteTokenController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final inviteToken = _inviteTokenController.text.trim();

    if (email.isEmpty || password.isEmpty || inviteToken.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: email,
      password: password,
      inviteToken: inviteToken,
    );

    if (success && mounted) {
      setState(() => _registeredOk = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!; // Atajo l10n

    if (_registeredOk) {
      return _SuccessScreen(
        onGoToLogin: () => context.go('/login'),
        l10n: l10n, // Pasamos el l10n a la pantalla de éxito
      );
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: AppColors.white, size: 18),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.createAccount, // i18n
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.inviteTokenSubtitle, // i18n
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.5),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),

              if (auth.errorMessage != null) ...[
                ErrorBanner(message: auth.errorMessage!),
                const SizedBox(height: 16),
              ],

              AuthField(
                label: l10n.email, // i18n
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                icon: FontAwesomeIcons.envelope,
              ),
              const SizedBox(height: 16),

              AuthField(
                label: l10n.password, // i18n
                controller: _passwordController,
                obscureText: _obscurePassword,
                icon: FontAwesomeIcons.lock,
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: FaIcon(
                    _obscurePassword
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    size: 16,
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              AuthField(
                label: l10n.inviteToken, // i18n
                controller: _inviteTokenController,
                icon: FontAwesomeIcons.key,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenEmerald,
                    disabledBackgroundColor:
                    AppColors.greenEmerald.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                      : Text(
                    l10n.register, // i18n
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final VoidCallback onGoToLogin;
  final AppLocalizations l10n; // Recibimos l10n aquí

  const _SuccessScreen({required this.onGoToLogin, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.circleCheck,
                  size: 64, color: AppColors.greenEmerald),
              const SizedBox(height: 24),
              Text(
                l10n.accountCreated, // i18n
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.accountCreatedSubtitle, // i18n
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.white.withOpacity(0.5), fontSize: 15),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onGoToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenEmerald,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.goToSignIn, // i18n
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}