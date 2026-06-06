import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart'; // Importa i18n
import 'package:provider/provider.dart';

// Importaciones corregidas sin guion bajo
import '../widgets/auth_field.dart';
import '../widgets/error_banner.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: email, password: password);

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!; // Atajo para i18n

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Logo
              Center(
                child: Image.asset('assets/images/logo.png', height: 48),
              ),
              const SizedBox(height: 48),

              // Título con i18n
              Text(
                l10n.welcomeBack,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.signInSubtitle,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Error (Widget ahora público)
              if (auth.errorMessage != null) ...[
                ErrorBanner(message: auth.errorMessage!),
                const SizedBox(height: 16),
              ],

              // Email (Widget ahora público + i18n)
              AuthField(
                label: l10n.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                icon: FontAwesomeIcons.envelope,
              ),
              const SizedBox(height: 16),

              // Password (Widget ahora público + i18n)
              AuthField(
                label: l10n.password,
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
              const SizedBox(height: 32),

              // Botón login con i18n
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _onLogin,
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
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                      : Text(
                    l10n.signIn,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Link a register con i18n
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/register'),
                  child: RichText(
                    text: TextSpan(
                      text: "${l10n.noAccount} ",
                      style: TextStyle(
                          color: AppColors.white.withOpacity(0.5),
                          fontSize: 14),
                      children: [
                        TextSpan(
                          text: l10n.registerLink,
                          style: const TextStyle(
                            color: AppColors.greenEmerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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