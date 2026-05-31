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
  String get sixMonths => '6 meses';

  @override
  String get year => '1 year';
}
