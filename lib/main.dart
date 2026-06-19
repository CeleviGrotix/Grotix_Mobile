import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grotix/features/supervision/application/services/zone_service.dart';
import 'package:grotix/features/supervision/presentation/providers/zone_provider.dart';
import 'package:provider/provider.dart';

import 'common/di/locale_provider.dart';
import 'common/routes/app_router.dart';
import 'common/theme/app_theme.dart';
import 'features/identity/auth/auth_injection.dart';
import 'features/identity/auth/presentation/providers/auth_provider.dart';
import 'features/identity/profile/infrastructure/datasource/association_datasource.dart';
import 'features/identity/profile/infrastructure/datasource/profile_remote_datasource.dart';
import 'features/identity/profile/infrastructure/repositories/association_repository_impl.dart';
import 'features/identity/profile/infrastructure/repositories/profile_repository_impl.dart';
import 'features/identity/profile/presentation/provider/profile_provider.dart';
import 'features/supervision/application/services/crop_service.dart';
import 'features/supervision/application/services/farm_service.dart';
import 'features/supervision/infrastructure/datasource/crop_datasource.dart';
import 'features/supervision/infrastructure/datasource/farm_datasource.dart';
import 'features/supervision/infrastructure/datasource/members_datasource.dart';
import 'features/supervision/infrastructure/datasource/zone_datasource.dart';
import 'features/supervision/infrastructure/repositories/crop_repository_impl.dart';
import 'features/supervision/infrastructure/repositories/farm_repository_impl.dart';
import 'features/supervision/infrastructure/repositories/zone_repository_impl.dart';
import 'features/supervision/presentation/providers/dashboard_provider.dart';
import 'features/supervision/presentation/providers/members_provider.dart';
import 'l10n/app_localizations.dart';
import 'features/supervision/application/services/irrigation_service.dart';
import 'features/supervision/infrastructure/datasource/irrigation_datasource.dart';
import 'features/supervision/infrastructure/repositories/irrigation_repository_impl.dart';
import 'features/supervision/presentation/providers/irrigation_provider.dart';

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
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            repository: ProfileRepositoryImpl(ProfileRemoteDatasource()),
            associationRepository: AssociationRepositoryImpl(AssociationRemoteDatasource()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ZoneProvider(
            zoneService: ZoneService(ZoneRepositoryImpl(ZoneRemoteDatasource())),
            farmService: FarmService(FarmRepositoryImpl(FarmRemoteDatasource())),
            cropService: CropService(CropRepositoryImpl(CropRemoteDatasource())),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => IrrigationProvider(
            IrrigationService(
              IrrigationRepositoryImpl(
                IrrigationDatasource(),
              ),
            ),
          ),
        ),
        ChangeNotifierProxyProvider<ZoneProvider, DashboardProvider>(
          create: (context) => DashboardProvider(
            zoneProvider: context.read<ZoneProvider>(),
          ),
          update: (context, zoneProvider, previousDashboard) =>
          previousDashboard ?? DashboardProvider(zoneProvider: zoneProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => MembersProvider(
            datasource: MembersRemoteDatasource(),
          ),
        ),
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