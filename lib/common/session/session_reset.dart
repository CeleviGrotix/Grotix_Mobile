import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../features/identity/profile/presentation/provider/profile_provider.dart';
import '../../features/supervision/presentation/providers/dashboard_provider.dart';
import '../../features/supervision/presentation/providers/irrigation_provider.dart';
import '../../features/supervision/presentation/providers/members_provider.dart';
import '../../features/supervision/presentation/providers/zone_provider.dart';

/// Limpia estado en memoria al cerrar sesión o antes de cargar otra org.
class SessionReset {
  SessionReset._();

  static void clearAll(BuildContext context) {
    context.read<ZoneProvider>().reset();
    context.read<DashboardProvider>().reset();
    context.read<ProfileProvider>().reset();
    context.read<MembersProvider>().reset();
    context.read<IrrigationProvider>().clearIrrigatingState();
  }
}
