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

  @override
  String get generateReport => 'Generar Reporte';

  @override
  String get irrigation => 'Riego';

  @override
  String get start => 'Inicio';

  @override
  String get finish => 'Fin';

  @override
  String get selectTimeRange => 'Selecciona un rango de tiempo:';

  @override
  String get generate => 'GENERAR';

  @override
  String get week => '1 semana';

  @override
  String get month => '1 mes';

  @override
  String get threeMonths => '3 meses';

  @override
  String get sixMonths => '6 meses';

  @override
  String get year => '1 año';

  @override
  String get mainTab => 'PRINCIPAL';

  @override
  String get settingsTab => 'AJUSTES';

  @override
  String get peopleTab => 'PERSONAL';

  @override
  String germinationStage(Object stage) {
    return 'Etapa de germinación: $stage';
  }

  @override
  String latitude(Object lat) {
    return 'Latitud: $lat';
  }

  @override
  String longitude(Object lng) {
    return 'Longitud: $lng';
  }

  @override
  String get moisture => 'Humedad';

  @override
  String get lightRadiation => 'Luz/Radiación';

  @override
  String get temperature => 'Temperatura';

  @override
  String get optimal => 'Óptimo';

  @override
  String get average => 'Medio';

  @override
  String get allowAutoIrrigation => 'Permitir riego automático';

  @override
  String get startManualIrrigation => 'Iniciar riego manual';

  @override
  String get maxTimeIrrigation => 'Tiempo máx. de riego';

  @override
  String get criticalLevels => 'Niveles Críticos';

  @override
  String get agriculturist => 'Agricultor/a';

  @override
  String get remove => 'ELIMINAR';

  @override
  String get invite => 'INVITAR';

  @override
  String get searchPeople => 'Buscar personal...';

  @override
  String get sensors => 'Sensores';

  @override
  String get addSensor => 'AÑADIR SENSOR';

  @override
  String get sensorId => 'ID del Sensor';

  @override
  String get ssidNetwork => 'Red SSID';

  @override
  String get password => 'Contraseña';

  @override
  String lastMaintenance(Object date) {
    return 'Último mantenimiento: $date';
  }

  @override
  String get microcontroller => 'Microcontrolador';
}
