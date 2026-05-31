// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String hello(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get personalInfo => 'INFO PERSONAL';

  @override
  String get settings => 'CONFIGURACIÓN';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get email => 'Correo electrónico';

  @override
  String get phone => 'Teléfono';

  @override
  String get role => 'Rol';

  @override
  String get profilePicture => 'Foto de perfil';

  @override
  String get edit => 'EDITAR';

  @override
  String get logout => 'CERRAR SESIÓN';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get logoutConfirmTitle => 'Cerrar sesión';

  @override
  String get logoutConfirmMessage =>
      '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get changesSaved => 'Cambios guardados';

  @override
  String get allSensorsActive => 'Todos los sensores activos';

  @override
  String get someSensorsFailing => 'Algunos sensores con fallas';

  @override
  String get noActiveSensors => 'Sin sensores activos';

  @override
  String lastUpdate(String time) {
    return 'Última actualización $time';
  }

  @override
  String stage(String stage) {
    return 'Etapa: $stage';
  }

  @override
  String get cultivationAreas => 'Áreas de Cultivo';

  @override
  String get searchZones => 'Buscar zonas...';

  @override
  String get noZonesFound => 'No se encontraron zonas';

  @override
  String get aiImageProcessing => 'Procesamiento IA de Imágenes';

  @override
  String get aiTrustLevel => 'Nivel de Confianza IA';

  @override
  String get zoneStatus => 'ESTADO DE ZONAS';
}
