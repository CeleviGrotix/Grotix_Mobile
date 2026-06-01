import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String hello(String name);

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFO'**
  String get personalInfo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get edit;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @allSensorsActive.
  ///
  /// In en, this message translates to:
  /// **'All sensors are active'**
  String get allSensorsActive;

  /// No description provided for @someSensorsFailing.
  ///
  /// In en, this message translates to:
  /// **'Some sensors are failing'**
  String get someSensorsFailing;

  /// No description provided for @noActiveSensors.
  ///
  /// In en, this message translates to:
  /// **'No active sensors'**
  String get noActiveSensors;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update {time}'**
  String lastUpdate(String time);

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'Stage: {stage}'**
  String stage(String stage);

  /// No description provided for @cultivationAreas.
  ///
  /// In en, this message translates to:
  /// **'Cultivation Areas'**
  String get cultivationAreas;

  /// No description provided for @searchZones.
  ///
  /// In en, this message translates to:
  /// **'Search zones...'**
  String get searchZones;

  /// No description provided for @noZonesFound.
  ///
  /// In en, this message translates to:
  /// **'No zones found'**
  String get noZonesFound;

  /// No description provided for @aiImageProcessing.
  ///
  /// In en, this message translates to:
  /// **'AI Image Processing'**
  String get aiImageProcessing;

  /// No description provided for @aiTrustLevel.
  ///
  /// In en, this message translates to:
  /// **'AI Trust Level'**
  String get aiTrustLevel;

  /// No description provided for @zoneStatus.
  ///
  /// In en, this message translates to:
  /// **'ZONE STATUS'**
  String get zoneStatus;

  /// No description provided for @taxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get taxId;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get emailNotifications;

  /// No description provided for @associationName.
  ///
  /// In en, this message translates to:
  /// **'Association Name'**
  String get associationName;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @irrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get irrigation;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @selectTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Select a specific time range:'**
  String get selectTimeRange;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'GENERATE'**
  String get generate;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get month;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get sixMonths;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get year;

  /// No description provided for @mainTab.
  ///
  /// In en, this message translates to:
  /// **'MAIN'**
  String get mainTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTab;

  /// No description provided for @peopleTab.
  ///
  /// In en, this message translates to:
  /// **'PEOPLE'**
  String get peopleTab;

  /// No description provided for @germinationStage.
  ///
  /// In en, this message translates to:
  /// **'Germination Stage: {stage}'**
  String germinationStage(Object stage);

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude: {lat}'**
  String latitude(Object lat);

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude: {lng}'**
  String longitude(Object lng);

  /// No description provided for @moisture.
  ///
  /// In en, this message translates to:
  /// **'Moisture'**
  String get moisture;

  /// No description provided for @lightRadiation.
  ///
  /// In en, this message translates to:
  /// **'Light/Radiation'**
  String get lightRadiation;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @optimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @allowAutoIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Allow Automatic Irrigation'**
  String get allowAutoIrrigation;

  /// No description provided for @startManualIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Start Manual Irrigation'**
  String get startManualIrrigation;

  /// No description provided for @maxTimeIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Max. time of irrigation'**
  String get maxTimeIrrigation;

  /// No description provided for @criticalLevels.
  ///
  /// In en, this message translates to:
  /// **'Critical Levels'**
  String get criticalLevels;

  /// No description provided for @agriculturist.
  ///
  /// In en, this message translates to:
  /// **'Agriculturist'**
  String get agriculturist;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'INVITE'**
  String get invite;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search staff...'**
  String get searchPeople;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @addSensor.
  ///
  /// In en, this message translates to:
  /// **'ADD SENSOR'**
  String get addSensor;

  /// No description provided for @sensorId.
  ///
  /// In en, this message translates to:
  /// **'Sensor ID'**
  String get sensorId;

  /// No description provided for @ssidNetwork.
  ///
  /// In en, this message translates to:
  /// **'SSID Network'**
  String get ssidNetwork;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @lastMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Last maintenance: {date}'**
  String lastMaintenance(Object date);

  /// No description provided for @microcontroller.
  ///
  /// In en, this message translates to:
  /// **'Microcontroller'**
  String get microcontroller;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLink;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @inviteTokenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You need an invite token to register'**
  String get inviteTokenSubtitle;

  /// No description provided for @inviteToken.
  ///
  /// In en, this message translates to:
  /// **'Invite Token'**
  String get inviteToken;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created!'**
  String get accountCreated;

  /// No description provided for @accountCreatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can now sign in with your credentials.'**
  String get accountCreatedSubtitle;

  /// No description provided for @goToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Go to Sign In'**
  String get goToSignIn;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get errorUpdatingProfile;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated'**
  String get profilePictureUpdated;

  /// No description provided for @errorUpdatingPicture.
  ///
  /// In en, this message translates to:
  /// **'Could not update picture'**
  String get errorUpdatingPicture;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpired;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
