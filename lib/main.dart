import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'common/di/locale_provider.dart';
import 'common/routes/app_router.dart';
import 'common/theme/app_theme.dart';
import 'features/identity/auth/auth_injection.dart';
import 'features/identity/auth/presentation/providers/auth_provider.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Creamos el AuthProvider aquí para poder pasarlo al router
  late final AuthProvider _authProvider = buildAuthProvider();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<LocaleProvider, AuthProvider>(
        builder: (context, localeProvider, auth, _) {
          return MaterialApp.router(
            title: 'Grotix',
            theme: getAppTheme(),
            debugShowCheckedModeBanner: false,
            // El router necesita el authProvider para el refreshListenable
            routerConfig: buildAppRouter(_authProvider),
            locale: localeProvider.locale,
            supportedLocales: const [Locale('en'), Locale('es')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}