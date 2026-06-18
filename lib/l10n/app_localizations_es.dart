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
  String get taxId => 'RUC / NIT';

  @override
  String get save => 'GUARDAR';

  @override
  String get notifications => 'NOTIFICACIONES';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get emailNotifications => 'Notificaciones por email';

  @override
  String get associationName => 'Nombre de asociación';

  @override
  String get retry => 'Reintentar';

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
  String get moistureAir => 'Humedad del aire';

  @override
  String get moistureSoil => 'Humedad de la tierra';

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

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get signInSubtitle => 'Inicia sesión en tu cuenta';

  @override
  String get signIn => 'Entrar';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get registerLink => 'Regístrate';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get inviteTokenSubtitle =>
      'Necesitas un token de invitación para registrarte';

  @override
  String get inviteToken => 'Token de invitación';

  @override
  String get register => 'Registrarse';

  @override
  String get accountCreated => '¡Cuenta creada!';

  @override
  String get accountCreatedSubtitle =>
      'Ahora puedes iniciar sesión con tus credenciales.';

  @override
  String get goToSignIn => 'Ir al inicio de sesión';

  @override
  String get profileUpdatedSuccess => 'Perfil actualizado con éxito';

  @override
  String get errorUpdatingProfile => 'Error al actualizar el perfil';

  @override
  String get profilePictureUpdated => 'Foto de perfil actualizada';

  @override
  String get errorUpdatingPicture => 'No se pudo actualizar la imagen';

  @override
  String get sessionExpired => 'Sesión expirada';

  @override
  String get failedToLoadProfile => 'Error al cargar el perfil';

  @override
  String get filterAndSort => 'Filtrar y Ordenar';

  @override
  String get sortBy => 'ORDENAR POR';

  @override
  String get filterByPhase => 'FILTRAR POR FASE';

  @override
  String get nameAz => 'Nombre (A-Z)';

  @override
  String get nameZa => 'Nombre (Z-A)';

  @override
  String get newestPhase => 'Fase más reciente';

  @override
  String get oldestPhase => 'Fase más antigua';

  @override
  String get phaseSeed => 'Semilla';

  @override
  String get phaseGermination => 'Germinación';

  @override
  String get phaseVegetative => 'Vegetativo';

  @override
  String get phaseFlowering => 'Floración';

  @override
  String get phaseFruiting => 'Fructificación';

  @override
  String get phaseHarvest => 'Cosecha';

  @override
  String get phaseUnknown => 'Desconocido';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get since => 'Desde el';

  @override
  String get days => 'días';

  @override
  String get zoneUpdated => 'Zona actualizada';

  @override
  String get zoneUpdateFailed => 'Error al actualizar zona';

  @override
  String get sectionPhase => 'FASE';

  @override
  String get sectionCrop => 'CULTIVO';

  @override
  String get sectionLocation => 'UBICACIÓN';

  @override
  String get sectionImageUrl => 'URL DE IMAGEN';

  @override
  String get sectionInfo => 'INFORMACIÓN';

  @override
  String get commonName => 'Nombre común';

  @override
  String get scientificName => 'Nombre científico';

  @override
  String get optimalTemp => 'Temperatura óptima';

  @override
  String get optimalHum => 'Humedad óptima';

  @override
  String get optimalLight => 'Luz óptima';

  @override
  String get maxStressTime => 'Tiempo máx. estrés';

  @override
  String get imageUrl => 'URL de Imagen';

  @override
  String get zoneId => 'ID de Zona';

  @override
  String get farmId => 'ID de Granja';

  @override
  String get longitudee => 'Longitud';

  @override
  String get latitudee => 'Latitud';

  @override
  String get selectZone => 'Selecciona zona';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get todaySection => 'Hoy';

  @override
  String get olderSection => 'Anteriores';

  @override
  String get noNotifications => 'No hay notificaciones disponibles';

  @override
  String get notifCriticalTitle => 'Caída Crítica de Humedad';

  @override
  String notifCriticalDesc(String zone) {
    return 'Los niveles de humedad en la $zone han caído drásticamente por debajo del umbral seguro.';
  }

  @override
  String get notifWarningTitle => 'Advertencia de Estrés Alto';

  @override
  String notifWarningDesc(String zone) {
    return 'Los cultivos en la $zone se acercan al tiempo máximo de estrés por variaciones de radiación.';
  }

  @override
  String get notifInfoTitle => 'Ciclo de Riego Finalizado';

  @override
  String notifInfoDesc(String farm) {
    return 'El cronograma automatizado se completó con éxito en los sectores de $farm.';
  }

  @override
  String get addNewZone => 'Añadir nueva zona';

  @override
  String get addZoneSupportDesc =>
      'Para garantizar la correcta vinculación del hardware (sensores y actuadores) con la plataforma, la creación de nuevas áreas de cultivo es gestionada exclusivamente por nuestro equipo de soporte.';

  @override
  String get supportPhone => '+51 999 999 999';

  @override
  String get understood => 'Entendido';

  @override
  String get aiAnalysisTitle => 'Análisis IA';

  @override
  String get statusLabel => 'Estado';

  @override
  String get healthScoreLabel => 'Health Score';

  @override
  String get observationsLabel => 'Observaciones';

  @override
  String get errorTitle => 'Error';

  @override
  String get aiConnectionError =>
      'No se pudo conectar con el servidor de IA. Verifica que el servidor Python esté corriendo.';

  @override
  String get okButton => 'OK';

  @override
  String get noZonesAvailable => 'No hay zonas disponibles';
}
