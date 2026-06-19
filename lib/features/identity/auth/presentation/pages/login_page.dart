import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/common/session/session_reset.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../profile/presentation/provider/profile_provider.dart';
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
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    SessionReset.clearAll(context);

    final auth = context.read<AuthProvider>();
    final session = await auth.login(email: email, password: password);

    if (!mounted) return;

    if (session != null) {
      await context.read<ProfileProvider>().loadProfile();
      if (!mounted) return;
      auth.applySession(session);
      context.go('/dashboard');
      return;
    }

    _passwordController.clear();
    _passwordFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Image.asset('assets/images/logo.png', height: 48),
              ),
              const SizedBox(height: 48),
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
              Selector<AuthProvider, String?>(
                selector: (_, auth) => auth.errorMessage,
                builder: (context, errorMessage, _) {
                  if (errorMessage == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ErrorBanner(message: errorMessage),
                  );
                },
              ),
              AuthField(
                label: l10n.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                icon: FontAwesomeIcons.envelope,
                onSubmitted: (_) => _passwordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 16),
              AuthField(
                label: l10n.password,
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                icon: FontAwesomeIcons.lock,
                onSubmitted: (_) => _onLogin(),
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
              Selector<AuthProvider, bool>(
                selector: (_, auth) => auth.isLoading,
                builder: (context, isLoading, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenEmerald,
                        disabledBackgroundColor:
                            AppColors.greenEmerald.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
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
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/register'),
                  child: RichText(
                    text: TextSpan(
                      text: "${l10n.noAccount} ",
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
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
