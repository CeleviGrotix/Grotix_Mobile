// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String hello(String name) {
    return 'Hello, $name!';
  }

  @override
  String get personalInfo => 'PERSONAL INFO';

  @override
  String get settings => 'SETTINGS';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get role => 'Role';

  @override
  String get profilePicture => 'Profile Picture';

  @override
  String get edit => 'EDIT';

  @override
  String get logout => 'LOG OUT';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get logoutConfirmTitle => 'Log out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get allSensorsActive => 'All sensors are active';

  @override
  String get someSensorsFailing => 'Some sensors are failing';

  @override
  String get noActiveSensors => 'No active sensors';

  @override
  String lastUpdate(String time) {
    return 'Last update $time';
  }

  @override
  String stage(String stage) {
    return 'Stage: $stage';
  }

  @override
  String get cultivationAreas => 'Cultivation Areas';

  @override
  String get searchZones => 'Search zones...';

  @override
  String get noZonesFound => 'No zones found';

  @override
  String get aiImageProcessing => 'AI Image Processing';

  @override
  String get aiTrustLevel => 'AI Trust Level';

  @override
  String get zoneStatus => 'ZONE STATUS';

  @override
  String get taxId => 'Tax ID';

  @override
  String get save => 'SAVE';

  @override
  String get notifications => 'NOTIFICATIONS';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get emailNotifications => 'Email notifications';

  @override
  String get associationName => 'Association Name';

  @override
  String get retry => 'Retry';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get irrigation => 'Irrigation';

  @override
  String get start => 'Start';

  @override
  String get finish => 'Finish';

  @override
  String get selectTimeRange => 'Select a specific time range:';

  @override
  String get generate => 'GENERATE';

  @override
  String get week => '1 week';

  @override
  String get month => '1 month';

  @override
  String get threeMonths => '3 months';

  @override
  String get sixMonths => '6 months';

  @override
  String get year => '1 year';

  @override
  String get mainTab => 'MAIN';

  @override
  String get settingsTab => 'SETTINGS';

  @override
  String get peopleTab => 'PEOPLE';

  @override
  String germinationStage(Object stage) {
    return 'Germination Stage: $stage';
  }

  @override
  String latitude(Object lat) {
    return 'Latitude: $lat';
  }

  @override
  String longitude(Object lng) {
    return 'Longitude: $lng';
  }

  @override
  String get moistureAir => 'Air Moisture';

  @override
  String get moistureSoil => 'Soil Moisture';

  @override
  String get lightRadiation => 'Light/Radiation';

  @override
  String get temperature => 'Temperature';

  @override
  String get optimal => 'Optimal';

  @override
  String get average => 'Average';

  @override
  String get allowAutoIrrigation => 'Allow Automatic Irrigation';

  @override
  String get startManualIrrigation => 'Start Manual Irrigation';

  @override
  String get maxTimeIrrigation => 'Max. time of irrigation';

  @override
  String get criticalLevels => 'Critical Levels';

  @override
  String get agriculturist => 'Agriculturist';

  @override
  String get remove => 'REMOVE';

  @override
  String get invite => 'INVITE';

  @override
  String get searchPeople => 'Search staff...';

  @override
  String get sensors => 'Sensors';

  @override
  String get addSensor => 'ADD SENSOR';

  @override
  String get sensorId => 'Sensor ID';

  @override
  String get ssidNetwork => 'SSID Network';

  @override
  String get password => 'Password';

  @override
  String lastMaintenance(Object date) {
    return 'Last maintenance: $date';
  }

  @override
  String get microcontroller => 'Microcontroller';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to your account';

  @override
  String get signIn => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerLink => 'Register';

  @override
  String get createAccount => 'Create account';

  @override
  String get inviteTokenSubtitle => 'You need an invite token to register';

  @override
  String get inviteToken => 'Invite Token';

  @override
  String get register => 'Register';

  @override
  String get accountCreated => 'Account created!';

  @override
  String get accountCreatedSubtitle =>
      'You can now sign in with your credentials.';

  @override
  String get goToSignIn => 'Go to Sign In';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get errorUpdatingProfile => 'Error updating profile';

  @override
  String get profilePictureUpdated => 'Profile picture updated';

  @override
  String get errorUpdatingPicture => 'Could not update picture';

  @override
  String get sessionExpired => 'Session expired';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get filterAndSort => 'Filter and Order';

  @override
  String get sortBy => 'ORDER BY';

  @override
  String get filterByPhase => 'FILTER BY PHASE';

  @override
  String get nameAz => 'Name (A-Z)';

  @override
  String get nameZa => 'Name (Z-A)';

  @override
  String get newestPhase => 'Most recent';

  @override
  String get oldestPhase => 'Oldest';

  @override
  String get phaseSeed => 'Seed';

  @override
  String get phaseGermination => 'Germination';

  @override
  String get phaseVegetative => 'Vegetative';

  @override
  String get phaseFlowering => 'Flowering';

  @override
  String get phaseFruiting => 'Fruiting';

  @override
  String get phaseHarvest => 'Harvest';

  @override
  String get phaseUnknown => 'Unknown';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get since => 'Since';

  @override
  String get days => 'days';

  @override
  String get zoneUpdated => 'Zone updated';

  @override
  String get zoneUpdateFailed => 'Failed to update zone';

  @override
  String get sectionPhase => 'PHASE';

  @override
  String get sectionCrop => 'CROP';

  @override
  String get sectionLocation => 'LOCATION';

  @override
  String get sectionImageUrl => 'IMAGE URL';

  @override
  String get sectionInfo => 'INFO';

  @override
  String get commonName => 'Common name';

  @override
  String get scientificName => 'Scientific name';

  @override
  String get optimalTemp => 'Optimal temperature';

  @override
  String get optimalHum => 'Optimal humidity';

  @override
  String get optimalLight => 'Optimal light';

  @override
  String get maxStressTime => 'Max stress time';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get zoneId => 'Zone ID';

  @override
  String get farmId => 'Farm ID';

  @override
  String get longitudee => 'Longitude';

  @override
  String get latitudee => 'Latitude';

  @override
  String get selectZone => 'Select zone';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get todaySection => 'Today';

  @override
  String get olderSection => 'Older';

  @override
  String get noNotifications => 'No notifications available';

  @override
  String get notifCriticalTitle => 'Critical Moisture Drop';

  @override
  String notifCriticalDesc(String zone) {
    return 'The substrate humidity levels in $zone have dropped dramatically below the safe threshold.';
  }

  @override
  String get notifWarningTitle => 'High Stress Warning';

  @override
  String notifWarningDesc(String zone) {
    return 'Plants in $zone are approaching maximum stress time due to radiation variance.';
  }

  @override
  String get notifInfoTitle => 'Irrigation Cycle Finished';

  @override
  String notifInfoDesc(String farm) {
    return 'Automated schedule completed successfully across sector grids in $farm.';
  }

  @override
  String get addNewZone => 'Add new zone';

  @override
  String get addZoneSupportDesc =>
      'To guarantee the correct linking of hardware (sensors and actuators) with the platform, the creation of new cultivation areas is managed exclusively by our support team.';

  @override
  String get supportPhone => '+51 999 999 999';

  @override
  String get understood => 'Understood';

  @override
  String get aiAnalysisTitle => 'AI Analysis';

  @override
  String get statusLabel => 'Status';

  @override
  String get healthScoreLabel => 'Health Score';

  @override
  String get observationsLabel => 'Observations';

  @override
  String get errorTitle => 'Error';

  @override
  String get aiConnectionError =>
      'Could not connect to the AI server. Verify that the Python server is running.';

  @override
  String get okButton => 'OK';

  @override
  String get noZonesAvailable => 'No zones available';
}
