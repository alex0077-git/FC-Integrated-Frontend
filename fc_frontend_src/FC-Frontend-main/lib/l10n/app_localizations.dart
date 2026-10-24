import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fuselage'**
  String get appTitle;

  /// No description provided for @connectTagline.
  ///
  /// In en, this message translates to:
  /// **'Connect to your drone to begin'**
  String get connectTagline;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @groundPlan.
  ///
  /// In en, this message translates to:
  /// **'Ground Plan'**
  String get groundPlan;

  /// No description provided for @kppTuning.
  ///
  /// In en, this message translates to:
  /// **'K++ Tuning'**
  String get kppTuning;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language: {name}'**
  String currentLanguage(String name);

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get langArabic;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get langGerman;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get langHindi;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @takeoff.
  ///
  /// In en, this message translates to:
  /// **'Takeoff'**
  String get takeoff;

  /// No description provided for @arm.
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get arm;

  /// No description provided for @disarm.
  ///
  /// In en, this message translates to:
  /// **'Disarm'**
  String get disarm;

  /// No description provided for @rtl.
  ///
  /// In en, this message translates to:
  /// **'RTL'**
  String get rtl;

  /// No description provided for @land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get land;

  /// No description provided for @landConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get landConfirmTitle;

  /// No description provided for @landConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Land the drone now?'**
  String get landConfirmMessage;

  /// No description provided for @takeoffConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Arm (if needed) and take off to {meters} m on the live aircraft?'**
  String takeoffConfirmMessage(String meters);

  /// No description provided for @armConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Arm the live drone?'**
  String get armConfirmMessage;

  /// No description provided for @disarmConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Disarm the live drone?'**
  String get disarmConfirmMessage;

  /// No description provided for @rtlConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Return to launch now?'**
  String get rtlConfirmMessage;

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

  /// No description provided for @boundaries.
  ///
  /// In en, this message translates to:
  /// **'Boundaries'**
  String get boundaries;

  /// No description provided for @split.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get split;

  /// No description provided for @obstacles.
  ///
  /// In en, this message translates to:
  /// **'Obstacles'**
  String get obstacles;

  /// No description provided for @waypoints.
  ///
  /// In en, this message translates to:
  /// **'Waypoints'**
  String get waypoints;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitsImperial;

  /// No description provided for @mapStyle.
  ///
  /// In en, this message translates to:
  /// **'Map style'**
  String get mapStyle;

  /// No description provided for @mapStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get mapStreet;

  /// No description provided for @mapSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get mapSatellite;

  /// No description provided for @mapDigitalSky.
  ///
  /// In en, this message translates to:
  /// **'Digital Sky'**
  String get mapDigitalSky;

  /// No description provided for @kppTuningTitle.
  ///
  /// In en, this message translates to:
  /// **'K++ tuning'**
  String get kppTuningTitle;

  /// No description provided for @kppTuningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full flight-controller assistant'**
  String get kppTuningSubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Fly, plan missions, and tune K++ — one app.'**
  String get appTagline;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @flightParameters.
  ///
  /// In en, this message translates to:
  /// **'Flight Parameters'**
  String get flightParameters;

  /// No description provided for @firstWarningThreshold.
  ///
  /// In en, this message translates to:
  /// **'First Warning Threshold (%)'**
  String get firstWarningThreshold;

  /// No description provided for @secondWarningThreshold.
  ///
  /// In en, this message translates to:
  /// **'Second Warning Threshold (%)'**
  String get secondWarningThreshold;

  /// No description provided for @criticalBatteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Critical Battery Level (%)'**
  String get criticalBatteryLevel;

  /// No description provided for @maxVoltage.
  ///
  /// In en, this message translates to:
  /// **'Max Voltage'**
  String get maxVoltage;

  /// No description provided for @minVoltage.
  ///
  /// In en, this message translates to:
  /// **'Min Voltage'**
  String get minVoltage;

  /// No description provided for @lowVoltageThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low-Voltage Threshold'**
  String get lowVoltageThreshold;

  /// No description provided for @criticalVoltageThreshold.
  ///
  /// In en, this message translates to:
  /// **'Critical-Voltage Threshold'**
  String get criticalVoltageThreshold;

  /// No description provided for @cellCount.
  ///
  /// In en, this message translates to:
  /// **'Cell Count'**
  String get cellCount;

  /// No description provided for @calibrateBatteryOnKpp.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Battery on K++'**
  String get calibrateBatteryOnKpp;

  /// No description provided for @maxYawRate.
  ///
  /// In en, this message translates to:
  /// **'Max Yaw Rate'**
  String get maxYawRate;

  /// No description provided for @maxRollAngle.
  ///
  /// In en, this message translates to:
  /// **'Max Roll Angle'**
  String get maxRollAngle;

  /// No description provided for @maxPitchAngle.
  ///
  /// In en, this message translates to:
  /// **'Max Pitch Angle'**
  String get maxPitchAngle;

  /// No description provided for @maxSpeed.
  ///
  /// In en, this message translates to:
  /// **'Max Speed'**
  String get maxSpeed;

  /// No description provided for @cruiseSpeed.
  ///
  /// In en, this message translates to:
  /// **'Cruise Speed'**
  String get cruiseSpeed;

  /// No description provided for @saveMission.
  ///
  /// In en, this message translates to:
  /// **'Save Mission'**
  String get saveMission;

  /// No description provided for @loadMission.
  ///
  /// In en, this message translates to:
  /// **'Load Mission'**
  String get loadMission;

  /// No description provided for @uploadMission.
  ///
  /// In en, this message translates to:
  /// **'Upload Mission'**
  String get uploadMission;

  /// No description provided for @callForJob.
  ///
  /// In en, this message translates to:
  /// **'Call for Job'**
  String get callForJob;

  /// No description provided for @uploadAndFly.
  ///
  /// In en, this message translates to:
  /// **'Upload & fly'**
  String get uploadAndFly;

  /// No description provided for @uploadAndStart.
  ///
  /// In en, this message translates to:
  /// **'Upload & start'**
  String get uploadAndStart;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @heroImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuselage Hero Image'**
  String get heroImageLabel;

  /// No description provided for @logoImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuselage Logo'**
  String get logoImageLabel;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @gpsStatus.
  ///
  /// In en, this message translates to:
  /// **'GPS {fix} · {sats} sats'**
  String gpsStatus(String fix, String sats);

  /// No description provided for @gpsUnknown.
  ///
  /// In en, this message translates to:
  /// **'GPS --'**
  String get gpsUnknown;

  /// No description provided for @modeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Mode --'**
  String get modeUnknown;

  /// No description provided for @calibration.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get calibration;

  /// No description provided for @kppTuningFull.
  ///
  /// In en, this message translates to:
  /// **'K++ tuning (full assistant)'**
  String get kppTuningFull;

  /// No description provided for @kppTuningFullSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Status, sensors, gains, logs, firmware…'**
  String get kppTuningFullSubtitle;

  /// No description provided for @batteryCritical.
  ///
  /// In en, this message translates to:
  /// **'Battery critical'**
  String get batteryCritical;

  /// No description provided for @batteryLow.
  ///
  /// In en, this message translates to:
  /// **'Battery low'**
  String get batteryLow;

  /// No description provided for @batteryFirstWarning.
  ///
  /// In en, this message translates to:
  /// **'Battery first warning'**
  String get batteryFirstWarning;

  /// No description provided for @batterySecondWarningRtl.
  ///
  /// In en, this message translates to:
  /// **'Battery second warning — returning home (RTL)'**
  String get batterySecondWarningRtl;

  /// No description provided for @altitude.
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get altitude;

  /// No description provided for @distanceToDrone.
  ///
  /// In en, this message translates to:
  /// **'Distance to Drone'**
  String get distanceToDrone;

  /// No description provided for @distanceToLanding.
  ///
  /// In en, this message translates to:
  /// **'Distance to Landing Point'**
  String get distanceToLanding;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @drawBoundaryBeforeSplit.
  ///
  /// In en, this message translates to:
  /// **'Draw at least three boundary points before splitting.'**
  String get drawBoundaryBeforeSplit;

  /// No description provided for @firstPoint.
  ///
  /// In en, this message translates to:
  /// **'First Point'**
  String get firstPoint;

  /// No description provided for @endPoint.
  ///
  /// In en, this message translates to:
  /// **'End Point'**
  String get endPoint;

  /// No description provided for @undoSplit.
  ///
  /// In en, this message translates to:
  /// **'Undo split'**
  String get undoSplit;

  /// No description provided for @selectSplitA.
  ///
  /// In en, this message translates to:
  /// **'Select Split A'**
  String get selectSplitA;

  /// No description provided for @selectSplitB.
  ///
  /// In en, this message translates to:
  /// **'Select Split B'**
  String get selectSplitB;

  /// No description provided for @setA.
  ///
  /// In en, this message translates to:
  /// **'Set A'**
  String get setA;

  /// No description provided for @setB.
  ///
  /// In en, this message translates to:
  /// **'Set B'**
  String get setB;

  /// No description provided for @missionSpray.
  ///
  /// In en, this message translates to:
  /// **'Spray'**
  String get missionSpray;

  /// No description provided for @missionSurvey.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get missionSurvey;

  /// No description provided for @missionManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get missionManual;

  /// No description provided for @waypointsCount.
  ///
  /// In en, this message translates to:
  /// **'Waypoints ({count})'**
  String waypointsCount(int count);

  /// No description provided for @noWaypointsYet.
  ///
  /// In en, this message translates to:
  /// **'No waypoints yet'**
  String get noWaypointsYet;

  /// No description provided for @waypointDetail.
  ///
  /// In en, this message translates to:
  /// **'Waypoint detail'**
  String get waypointDetail;

  /// No description provided for @selectWaypoint.
  ///
  /// In en, this message translates to:
  /// **'Select a waypoint'**
  String get selectWaypoint;

  /// No description provided for @waypoint.
  ///
  /// In en, this message translates to:
  /// **'Waypoint'**
  String get waypoint;

  /// No description provided for @loiter.
  ///
  /// In en, this message translates to:
  /// **'Loiter'**
  String get loiter;

  /// No description provided for @cropRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get cropRice;

  /// No description provided for @cropWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get cropWheat;

  /// No description provided for @cropOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cropOther;

  /// No description provided for @connectLiveKpp.
  ///
  /// In en, this message translates to:
  /// **'Connect live K++'**
  String get connectLiveKpp;

  /// No description provided for @usbGround.
  ///
  /// In en, this message translates to:
  /// **'USB (ground)'**
  String get usbGround;

  /// No description provided for @comPort.
  ///
  /// In en, this message translates to:
  /// **'COM port'**
  String get comPort;

  /// No description provided for @noComPort.
  ///
  /// In en, this message translates to:
  /// **'No COM port'**
  String get noComPort;

  /// No description provided for @refreshComPorts.
  ///
  /// In en, this message translates to:
  /// **'Refresh COM ports'**
  String get refreshComPorts;

  /// No description provided for @baud.
  ///
  /// In en, this message translates to:
  /// **'Baud'**
  String get baud;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @connectUsbToKpp.
  ///
  /// In en, this message translates to:
  /// **'Connect USB to K++'**
  String get connectUsbToKpp;

  /// No description provided for @transmitterBtWifi.
  ///
  /// In en, this message translates to:
  /// **'Transmitter (Bluetooth / WiFi)'**
  String get transmitterBtWifi;

  /// No description provided for @airbornePath.
  ///
  /// In en, this message translates to:
  /// **'Airborne path — App → transmitter → aircraft'**
  String get airbornePath;

  /// No description provided for @bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get wifi;

  /// No description provided for @bluetoothTransmitter.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth transmitter'**
  String get bluetoothTransmitter;

  /// No description provided for @noBluetoothPort.
  ///
  /// In en, this message translates to:
  /// **'No Bluetooth port'**
  String get noBluetoothPort;

  /// No description provided for @refreshBluetoothPorts.
  ///
  /// In en, this message translates to:
  /// **'Refresh Bluetooth ports'**
  String get refreshBluetoothPorts;

  /// No description provided for @showAllComPorts.
  ///
  /// In en, this message translates to:
  /// **'Show all COM ports'**
  String get showAllComPorts;

  /// No description provided for @showAllComPortsHint.
  ///
  /// In en, this message translates to:
  /// **'Use if your TX paired but is not listed as Bluetooth'**
  String get showAllComPortsHint;

  /// No description provided for @connectTransmitterBt.
  ///
  /// In en, this message translates to:
  /// **'Connect transmitter (Bluetooth)'**
  String get connectTransmitterBt;

  /// No description provided for @disconnectTransmitter.
  ///
  /// In en, this message translates to:
  /// **'Disconnect transmitter'**
  String get disconnectTransmitter;

  /// No description provided for @g20Preset.
  ///
  /// In en, this message translates to:
  /// **'G20 preset'**
  String get g20Preset;

  /// No description provided for @useGatewayIp.
  ///
  /// In en, this message translates to:
  /// **'Use gateway IP'**
  String get useGatewayIp;

  /// No description provided for @refreshNetwork.
  ///
  /// In en, this message translates to:
  /// **'Refresh network'**
  String get refreshNetwork;

  /// No description provided for @wifiMode.
  ///
  /// In en, this message translates to:
  /// **'WiFi mode'**
  String get wifiMode;

  /// No description provided for @wifiModeTcp.
  ///
  /// In en, this message translates to:
  /// **'TCP to transmitter AP'**
  String get wifiModeTcp;

  /// No description provided for @wifiModeUdp.
  ///
  /// In en, this message translates to:
  /// **'UDP to transmitter'**
  String get wifiModeUdp;

  /// No description provided for @wifiModeUdpListen.
  ///
  /// In en, this message translates to:
  /// **'UDP listen (GCS port)'**
  String get wifiModeUdpListen;

  /// No description provided for @hostIp.
  ///
  /// In en, this message translates to:
  /// **'Host / IP'**
  String get hostIp;

  /// No description provided for @remotePort.
  ///
  /// In en, this message translates to:
  /// **'Remote port'**
  String get remotePort;

  /// No description provided for @localPort.
  ///
  /// In en, this message translates to:
  /// **'Local port'**
  String get localPort;

  /// No description provided for @connectTransmitterWifi.
  ///
  /// In en, this message translates to:
  /// **'Connect transmitter (WiFi)'**
  String get connectTransmitterWifi;

  /// No description provided for @autoTryWifi.
  ///
  /// In en, this message translates to:
  /// **'Auto-try WiFi'**
  String get autoTryWifi;

  /// No description provided for @phoneLandscapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Rotate to landscape'**
  String get phoneLandscapeTitle;

  /// No description provided for @phoneLandscapeBody.
  ///
  /// In en, this message translates to:
  /// **'This app is designed for landscape orientation.'**
  String get phoneLandscapeBody;

  /// No description provided for @returnToLaunch.
  ///
  /// In en, this message translates to:
  /// **'Return to launch'**
  String get returnToLaunch;

  /// No description provided for @lineSpacing.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get lineSpacing;

  /// No description provided for @coverageAdjust.
  ///
  /// In en, this message translates to:
  /// **'Coverage adjust'**
  String get coverageAdjust;

  /// No description provided for @obstacleCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get obstacleCircle;

  /// No description provided for @obstaclePolygon.
  ///
  /// In en, this message translates to:
  /// **'Polygon'**
  String get obstaclePolygon;

  /// No description provided for @addObstacle.
  ///
  /// In en, this message translates to:
  /// **'Add obstacle'**
  String get addObstacle;

  /// No description provided for @deleteObstacle.
  ///
  /// In en, this message translates to:
  /// **'Delete obstacle'**
  String get deleteObstacle;

  /// No description provided for @planHistory.
  ///
  /// In en, this message translates to:
  /// **'Plan history'**
  String get planHistory;

  /// No description provided for @imuCalibration.
  ///
  /// In en, this message translates to:
  /// **'IMU Calibration'**
  String get imuCalibration;

  /// No description provided for @compassCalibration.
  ///
  /// In en, this message translates to:
  /// **'Compass Calibration'**
  String get compassCalibration;

  /// No description provided for @accelCalibration.
  ///
  /// In en, this message translates to:
  /// **'Accelerometer Calibration'**
  String get accelCalibration;

  /// No description provided for @levelHorizon.
  ///
  /// In en, this message translates to:
  /// **'Level Horizon'**
  String get levelHorizon;

  /// No description provided for @startCalibration.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startCalibration;

  /// No description provided for @stopCalibration.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopCalibration;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @mapAttributionEsri.
  ///
  /// In en, this message translates to:
  /// **'Tiles © Esri (imagery + place labels)'**
  String get mapAttributionEsri;

  /// No description provided for @mapAttributionOsm.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get mapAttributionOsm;

  /// No description provided for @digitalSkyEmbedBlocked.
  ///
  /// In en, this message translates to:
  /// **'Digital Sky will not open inside this app. Their site blocks other websites from showing the map.'**
  String get digitalSkyEmbedBlocked;

  /// No description provided for @digitalSkyDidNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Digital Sky did not load'**
  String get digitalSkyDidNotLoad;

  /// No description provided for @openDigitalSky.
  ///
  /// In en, this message translates to:
  /// **'Open Digital Sky'**
  String get openDigitalSky;

  /// No description provided for @openDigitalSkyInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open Digital Sky in browser'**
  String get openDigitalSkyInBrowser;

  /// No description provided for @calibrationRadio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get calibrationRadio;

  /// No description provided for @calibrationImu.
  ///
  /// In en, this message translates to:
  /// **'IMU'**
  String get calibrationImu;

  /// No description provided for @calibrationCompass.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get calibrationCompass;

  /// No description provided for @calibrationStatusCalibrating.
  ///
  /// In en, this message translates to:
  /// **'Calibrating...'**
  String get calibrationStatusCalibrating;

  /// No description provided for @calibrationStatusCalibrated.
  ///
  /// In en, this message translates to:
  /// **'Calibrated'**
  String get calibrationStatusCalibrated;

  /// No description provided for @calibrationStatusNotCalibrated.
  ///
  /// In en, this message translates to:
  /// **'Not calibrated'**
  String get calibrationStatusNotCalibrated;

  /// No description provided for @startCalibrationFull.
  ///
  /// In en, this message translates to:
  /// **'Start Calibration'**
  String get startCalibrationFull;

  /// No description provided for @connectLiveLink.
  ///
  /// In en, this message translates to:
  /// **'Live link: {link}'**
  String connectLiveLink(String link);

  /// No description provided for @connectUsbIntro.
  ///
  /// In en, this message translates to:
  /// **'USB for ground setup. For flying, connect the app to the transmitter over Bluetooth or WiFi — commands go App → TX → aircraft.'**
  String get connectUsbIntro;

  /// No description provided for @connectWebUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This web build cannot open USB, Bluetooth, or WiFi sockets. Run the Windows or Android app.'**
  String get connectWebUnsupported;

  /// No description provided for @transmitterPickHint.
  ///
  /// In en, this message translates to:
  /// **'Pick Bluetooth or WiFi depending on your transmitter. USB above is unchanged for ground setup.'**
  String get transmitterPickHint;

  /// No description provided for @btAbbrev.
  ///
  /// In en, this message translates to:
  /// **'BT'**
  String get btAbbrev;

  /// No description provided for @transmitterIpHost.
  ///
  /// In en, this message translates to:
  /// **'Transmitter IP / host'**
  String get transmitterIpHost;

  /// No description provided for @tcpPort.
  ///
  /// In en, this message translates to:
  /// **'TCP port'**
  String get tcpPort;

  /// No description provided for @remoteUdpPort.
  ///
  /// In en, this message translates to:
  /// **'Remote UDP port'**
  String get remoteUdpPort;

  /// No description provided for @localUdpPort.
  ///
  /// In en, this message translates to:
  /// **'Local UDP port'**
  String get localUdpPort;

  /// No description provided for @tryingWifiPorts.
  ///
  /// In en, this message translates to:
  /// **'Trying ports…'**
  String get tryingWifiPorts;

  /// No description provided for @autoTryWifiPorts.
  ///
  /// In en, this message translates to:
  /// **'Auto-try WiFi ports'**
  String get autoTryWifiPorts;

  /// No description provided for @loadingParameters.
  ///
  /// In en, this message translates to:
  /// **'Loading parameters {received}/{total}'**
  String loadingParameters(int received, int total);

  /// No description provided for @linkLostTransmitter.
  ///
  /// In en, this message translates to:
  /// **'Link lost — check transmitter power, Bluetooth/WiFi, and range.'**
  String get linkLostTransmitter;

  /// No description provided for @linkLostUsb.
  ///
  /// In en, this message translates to:
  /// **'Link lost — check the USB cable and FC power.'**
  String get linkLostUsb;

  /// No description provided for @connectLiveHint.
  ///
  /// In en, this message translates to:
  /// **'USB: plug into the FC on the ground. Flying: connect this app to the transmitter (Bluetooth or WiFi); commands and telemetry go through the TX to the aircraft. Keep the RC sticks for manual override.'**
  String get connectLiveHint;

  /// No description provided for @connectErrorUsbNeedsNative.
  ///
  /// In en, this message translates to:
  /// **'Live K++ USB needs the Windows or Android build — web cannot open serial ports.'**
  String get connectErrorUsbNeedsNative;

  /// No description provided for @connectErrorNoComPort.
  ///
  /// In en, this message translates to:
  /// **'No COM port found. Plug the K++ USB data cable in and refresh.'**
  String get connectErrorNoComPort;

  /// No description provided for @connectErrorInvalidPort.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid {label} (1–65535).'**
  String connectErrorInvalidPort(String label);

  /// No description provided for @connectErrorBluetoothNeedsNative.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth needs the Windows or Android desktop/mobile build.'**
  String get connectErrorBluetoothNeedsNative;

  /// No description provided for @connectErrorNoBluetoothSerial.
  ///
  /// In en, this message translates to:
  /// **'No Bluetooth serial port found. Pair the transmitter in system Bluetooth settings, then tap Refresh. If it still missing, enable “Show all COM ports”.'**
  String get connectErrorNoBluetoothSerial;

  /// No description provided for @connectErrorWifiNeedsNative.
  ///
  /// In en, this message translates to:
  /// **'Transmitter WiFi needs the Windows or Android build.'**
  String get connectErrorWifiNeedsNative;

  /// No description provided for @connectErrorEnterTxHost.
  ///
  /// In en, this message translates to:
  /// **'Enter the transmitter WiFi IP / hostname.'**
  String get connectErrorEnterTxHost;

  /// No description provided for @connectErrorNoWifiGateway.
  ///
  /// In en, this message translates to:
  /// **'No WiFi gateway found. Join the transmitter WiFi first.'**
  String get connectErrorNoWifiGateway;

  /// No description provided for @connectUsingGateway.
  ///
  /// In en, this message translates to:
  /// **'Using gateway {gateway} — tap Connect transmitter (WiFi).'**
  String connectUsingGateway(String gateway);

  /// No description provided for @connectWifiJoinFirst.
  ///
  /// In en, this message translates to:
  /// **'Join transmitter WiFi first, then try again.'**
  String get connectWifiJoinFirst;

  /// No description provided for @connectWifiTcpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connected over TX WiFi TCP {host}:{port}'**
  String connectWifiTcpSuccess(String host, String port);

  /// No description provided for @connectWifiG20Success.
  ///
  /// In en, this message translates to:
  /// **'Connected to Skydroid G20 TCP 192.168.43.1:5760'**
  String get connectWifiG20Success;

  /// No description provided for @connectWifiUdpListenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listening UDP 14550 — power the TX/aircraft so it sends telemetry.'**
  String get connectWifiUdpListenSuccess;

  /// No description provided for @connectWifiAutoTryFailed.
  ///
  /// In en, this message translates to:
  /// **'WiFi auto-try failed.\n{detail}\n\nFor Skydroid G20: WiFi mode = TCP, IP 192.168.43.1, port 5760. On the G20 turn on WLAN hotspot and data-transmission sharing; aircraft + GR01 must be linked (baud match on FC telem port).'**
  String connectWifiAutoTryFailed(String detail);

  /// No description provided for @rtlCommandConfirm.
  ///
  /// In en, this message translates to:
  /// **'Command the live drone to return to launch?'**
  String get rtlCommandConfirm;

  /// No description provided for @connectUsbToKppFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect USB to K++ first'**
  String get connectUsbToKppFirst;

  /// No description provided for @noFlyZone.
  ///
  /// In en, this message translates to:
  /// **'No-Fly Zone'**
  String get noFlyZone;

  /// No description provided for @orientation.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get orientation;

  /// No description provided for @autoAlign.
  ///
  /// In en, this message translates to:
  /// **'Auto-align'**
  String get autoAlign;

  /// No description provided for @edgeMargin.
  ///
  /// In en, this message translates to:
  /// **'Edge margin'**
  String get edgeMargin;

  /// No description provided for @operationMode.
  ///
  /// In en, this message translates to:
  /// **'Operation Mode'**
  String get operationMode;

  /// No description provided for @sprayOn.
  ///
  /// In en, this message translates to:
  /// **'Spray on'**
  String get sprayOn;

  /// No description provided for @sprayOff.
  ///
  /// In en, this message translates to:
  /// **'Spray off'**
  String get sprayOff;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @selectCrop.
  ///
  /// In en, this message translates to:
  /// **'Select Crop'**
  String get selectCrop;

  /// No description provided for @sprayRate.
  ///
  /// In en, this message translates to:
  /// **'Spray Rate'**
  String get sprayRate;

  /// No description provided for @flowRate.
  ///
  /// In en, this message translates to:
  /// **'Flow rate'**
  String get flowRate;

  /// No description provided for @liquidLevel.
  ///
  /// In en, this message translates to:
  /// **'Liquid'**
  String get liquidLevel;

  /// No description provided for @setTakeoffAltitude.
  ///
  /// In en, this message translates to:
  /// **'Set takeoff altitude'**
  String get setTakeoffAltitude;

  /// No description provided for @takeoffAltitudeMeters.
  ///
  /// In en, this message translates to:
  /// **'Altitude (m)'**
  String get takeoffAltitudeMeters;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @defaultMissionName.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get defaultMissionName;

  /// No description provided for @uploadFlyConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Upload {count} waypoints to the live K++, arm if needed, and start Auto (takeoff {meters} m)?'**
  String uploadFlyConfirmMessage(int count, String meters);

  /// No description provided for @missionUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mission uploaded — saved locally and Auto started on live K++'**
  String get missionUploadedSuccess;

  /// No description provided for @missionSavedToDatabase.
  ///
  /// In en, this message translates to:
  /// **'Mission saved to database'**
  String get missionSavedToDatabase;

  /// No description provided for @noSavedMissions.
  ///
  /// In en, this message translates to:
  /// **'No saved missions'**
  String get noSavedMissions;

  /// No description provided for @connectKppUsbFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect a live K++ over USB first'**
  String get connectKppUsbFirst;

  /// No description provided for @enterMeterVoltageInMaxVoltage.
  ///
  /// In en, this message translates to:
  /// **'Enter a meter voltage in Max Voltage'**
  String get enterMeterVoltageInMaxVoltage;

  /// No description provided for @battVoltMultWritten.
  ///
  /// In en, this message translates to:
  /// **'BATT_VOLT_MULT written to live K++'**
  String get battVoltMultWritten;

  /// No description provided for @savedLocallyFcSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Saved locally; FC sync failed: {error}'**
  String savedLocallyFcSyncFailed(String error);

  /// No description provided for @mapHintTapPlacePointA.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place point A'**
  String get mapHintTapPlacePointA;

  /// No description provided for @mapHintTapPlacePointB.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place point B'**
  String get mapHintTapPlacePointB;

  /// No description provided for @mapHintTapBoundaryForSplit.
  ///
  /// In en, this message translates to:
  /// **'Tap the boundary for the selected point'**
  String get mapHintTapBoundaryForSplit;

  /// No description provided for @mapHintTapAddBoundaryPoint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to add a boundary point'**
  String get mapHintTapAddBoundaryPoint;

  /// No description provided for @splitChoosePointsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose First Point or End Point, then tap a boundary point or anywhere along the boundary.'**
  String get splitChoosePointsHint;

  /// No description provided for @chooseCircleOrPolygon.
  ///
  /// In en, this message translates to:
  /// **'Choose Circle or Polygon'**
  String get chooseCircleOrPolygon;

  /// No description provided for @tapInsideFieldPlaceCircle.
  ///
  /// In en, this message translates to:
  /// **'Tap inside the field to place the circle.'**
  String get tapInsideFieldPlaceCircle;

  /// No description provided for @tapMapPlaceCornersInOrder.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place each corner, in order.'**
  String get tapMapPlaceCornersInOrder;
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
      <String>['ar', 'de', 'en', 'es', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
