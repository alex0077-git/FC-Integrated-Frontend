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

/// Callers can lookup localized strings with an instance of KppLocalizations
/// returned by `KppLocalizations.of(context)`.
///
/// Applications need to include `KppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: KppLocalizations.localizationsDelegates,
///   supportedLocales: KppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the KppLocalizations.supportedLocales
/// property.
abstract class KppLocalizations {
  KppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static KppLocalizations of(BuildContext context) {
    return Localizations.of<KppLocalizations>(context, KppLocalizations)!;
  }

  static const LocalizationsDelegate<KppLocalizations> delegate =
      _KppLocalizationsDelegate();

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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fuselage-K++'**
  String get appName;

  /// No description provided for @groupBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get groupBasic;

  /// No description provided for @groupAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get groupAdvanced;

  /// No description provided for @groupTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get groupTools;

  /// No description provided for @groupFly.
  ///
  /// In en, this message translates to:
  /// **'Fly'**
  String get groupFly;

  /// No description provided for @destOverview.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get destOverview;

  /// No description provided for @destInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get destInstallation;

  /// No description provided for @destRemoteControl.
  ///
  /// In en, this message translates to:
  /// **'Remote control'**
  String get destRemoteControl;

  /// No description provided for @destSensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get destSensors;

  /// No description provided for @destFlight.
  ///
  /// In en, this message translates to:
  /// **'Motors & flight'**
  String get destFlight;

  /// No description provided for @destGains.
  ///
  /// In en, this message translates to:
  /// **'Gains'**
  String get destGains;

  /// No description provided for @destProtection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get destProtection;

  /// No description provided for @destPump.
  ///
  /// In en, this message translates to:
  /// **'Pump'**
  String get destPump;

  /// No description provided for @destLiquid.
  ///
  /// In en, this message translates to:
  /// **'Liquid level'**
  String get destLiquid;

  /// No description provided for @destSpraying.
  ///
  /// In en, this message translates to:
  /// **'AB spraying'**
  String get destSpraying;

  /// No description provided for @destFence.
  ///
  /// In en, this message translates to:
  /// **'Fence'**
  String get destFence;

  /// No description provided for @destExtensions.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get destExtensions;

  /// No description provided for @destChannels.
  ///
  /// In en, this message translates to:
  /// **'Channel mapping'**
  String get destChannels;

  /// No description provided for @destMission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get destMission;

  /// No description provided for @destLogs.
  ///
  /// In en, this message translates to:
  /// **'Flight logs'**
  String get destLogs;

  /// No description provided for @destParameters.
  ///
  /// In en, this message translates to:
  /// **'All parameters'**
  String get destParameters;

  /// No description provided for @destFirmware.
  ///
  /// In en, this message translates to:
  /// **'Firmware & about'**
  String get destFirmware;

  /// No description provided for @mapFly.
  ///
  /// In en, this message translates to:
  /// **'Map / fly'**
  String get mapFly;

  /// No description provided for @groundPlan.
  ///
  /// In en, this message translates to:
  /// **'Ground plan'**
  String get groundPlan;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @overviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Live health of the flight controller and its modules (K++ assistant layout).'**
  String get overviewDescription;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @imu.
  ///
  /// In en, this message translates to:
  /// **'IMU'**
  String get imu;

  /// No description provided for @gps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get gps;

  /// No description provided for @gps1.
  ///
  /// In en, this message translates to:
  /// **'GPS1'**
  String get gps1;

  /// No description provided for @gps1Sats.
  ///
  /// In en, this message translates to:
  /// **'GPS1 sats'**
  String get gps1Sats;

  /// No description provided for @gps2.
  ///
  /// In en, this message translates to:
  /// **'GPS2'**
  String get gps2;

  /// No description provided for @gps2Sats.
  ///
  /// In en, this message translates to:
  /// **'GPS2 sats'**
  String get gps2Sats;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @altitude.
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get altitude;

  /// No description provided for @hdop.
  ///
  /// In en, this message translates to:
  /// **'HDOP'**
  String get hdop;

  /// No description provided for @powerAndLink.
  ///
  /// In en, this message translates to:
  /// **'Power & link'**
  String get powerAndLink;

  /// No description provided for @batteryVoltage.
  ///
  /// In en, this message translates to:
  /// **'Battery voltage'**
  String get batteryVoltage;

  /// No description provided for @rcSignal.
  ///
  /// In en, this message translates to:
  /// **'RC signal'**
  String get rcSignal;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @firmwareVersion.
  ///
  /// In en, this message translates to:
  /// **'Firmware version'**
  String get firmwareVersion;

  /// No description provided for @softwareRevision.
  ///
  /// In en, this message translates to:
  /// **'Software revision'**
  String get softwareRevision;

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  /// No description provided for @fcMessage.
  ///
  /// In en, this message translates to:
  /// **'Flight controller message'**
  String get fcMessage;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @statusFault.
  ///
  /// In en, this message translates to:
  /// **'Fault'**
  String get statusFault;

  /// No description provided for @statusNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get statusNotConnected;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @baud.
  ///
  /// In en, this message translates to:
  /// **'Baud'**
  String get baud;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

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

  /// No description provided for @refreshComPorts.
  ///
  /// In en, this message translates to:
  /// **'Refresh COM ports'**
  String get refreshComPorts;

  /// No description provided for @refreshBluetoothPorts.
  ///
  /// In en, this message translates to:
  /// **'Refresh Bluetooth ports'**
  String get refreshBluetoothPorts;

  /// No description provided for @setMode.
  ///
  /// In en, this message translates to:
  /// **'Set mode'**
  String get setMode;

  /// No description provided for @flightModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get flightModeAuto;

  /// No description provided for @flightModeGuided.
  ///
  /// In en, this message translates to:
  /// **'Guided'**
  String get flightModeGuided;

  /// No description provided for @flightModeLoiter.
  ///
  /// In en, this message translates to:
  /// **'Loiter'**
  String get flightModeLoiter;

  /// No description provided for @flightModeRtl.
  ///
  /// In en, this message translates to:
  /// **'RTL'**
  String get flightModeRtl;

  /// No description provided for @flightModeLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get flightModeLand;

  /// No description provided for @defaultAlt.
  ///
  /// In en, this message translates to:
  /// **'Default alt'**
  String get defaultAlt;

  /// No description provided for @abSpray.
  ///
  /// In en, this message translates to:
  /// **'AB spray'**
  String get abSpray;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @altitudeM.
  ///
  /// In en, this message translates to:
  /// **'Altitude (m)'**
  String get altitudeM;

  /// No description provided for @missionItemsHint.
  ///
  /// In en, this message translates to:
  /// **'{count} items — tap map to add waypoints'**
  String missionItemsHint(int count);

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

  /// No description provided for @tapMapForFence.
  ///
  /// In en, this message translates to:
  /// **'Tap map for fence…'**
  String get tapMapForFence;

  /// No description provided for @enableCircleFence.
  ///
  /// In en, this message translates to:
  /// **'Enable circle fence'**
  String get enableCircleFence;

  /// No description provided for @editAltitude.
  ///
  /// In en, this message translates to:
  /// **'Edit altitude'**
  String get editAltitude;

  /// No description provided for @missionDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Mission downloaded'**
  String get missionDownloaded;

  /// No description provided for @missionUploaded.
  ///
  /// In en, this message translates to:
  /// **'Mission uploaded'**
  String get missionUploaded;

  /// No description provided for @missionCleared.
  ///
  /// In en, this message translates to:
  /// **'Mission cleared'**
  String get missionCleared;

  /// No description provided for @rtlAccepted.
  ///
  /// In en, this message translates to:
  /// **'RTL accepted'**
  String get rtlAccepted;

  /// No description provided for @landAccepted.
  ///
  /// In en, this message translates to:
  /// **'Land accepted'**
  String get landAccepted;

  /// No description provided for @modeSet.
  ///
  /// In en, this message translates to:
  /// **'Mode {mode} set'**
  String modeSet(String mode);

  /// No description provided for @setPointsAbFirst.
  ///
  /// In en, this message translates to:
  /// **'Set points A and B on the map first'**
  String get setPointsAbFirst;

  /// No description provided for @abSprayGenerated.
  ///
  /// In en, this message translates to:
  /// **'AB spray pattern generated ({count} items)'**
  String abSprayGenerated(int count);

  /// No description provided for @fenceCircleEnabled.
  ///
  /// In en, this message translates to:
  /// **'Circle fence enabled, radius {radius} m (centred on aircraft when flying)'**
  String fenceCircleEnabled(String radius);

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported {path}'**
  String exportedTo(String path);

  /// No description provided for @importedItems.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} items'**
  String importedItems(int count);

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

  /// No description provided for @armed.
  ///
  /// In en, this message translates to:
  /// **'ARMED'**
  String get armed;

  /// No description provided for @disarmed.
  ///
  /// In en, this message translates to:
  /// **'Disarmed'**
  String get disarmed;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @notConnectedHint.
  ///
  /// In en, this message translates to:
  /// **'Connect the flight controller first (USB or transmitter BT/WiFi) in the bar above, then press Connect. Plugging in the GPS puck alone is not enough.'**
  String get notConnectedHint;

  /// No description provided for @cardFrameType.
  ///
  /// In en, this message translates to:
  /// **'Frame type'**
  String get cardFrameType;

  /// No description provided for @frameTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same as K++ assistant: yellow arm = nose, M1–M8 = FC ports, red CW / blue CCW = propeller spin. Writes FRAME and SHAPE.'**
  String get frameTypeSubtitle;

  /// No description provided for @cardImuGpsMounting.
  ///
  /// In en, this message translates to:
  /// **'IMU & GPS mounting'**
  String get cardImuGpsMounting;

  /// No description provided for @installationDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose directions to match how the modules are mounted, and enter their offsets from the airframe\'s centre of gravity in centimetres (blue zone negative, yellow zone positive).'**
  String get installationDescription;

  /// No description provided for @remoteControlDescription.
  ///
  /// In en, this message translates to:
  /// **'To make sure the failsafe is set correctly, switch the RC off after changing it and check that channels 1–4 jump to centre (about 1500) and channel 5 jumps to its failsafe position.'**
  String get remoteControlDescription;

  /// No description provided for @cardRcSettingsFailsafe.
  ///
  /// In en, this message translates to:
  /// **'RC settings & failsafe'**
  String get cardRcSettingsFailsafe;

  /// No description provided for @stickCalibration.
  ///
  /// In en, this message translates to:
  /// **'Stick calibration'**
  String get stickCalibration;

  /// No description provided for @stickCalibrationIdle.
  ///
  /// In en, this message translates to:
  /// **'Current endpoints are shown below. Start to recalibrate channels 1–4.'**
  String get stickCalibrationIdle;

  /// No description provided for @stickCalibrationExtremes.
  ///
  /// In en, this message translates to:
  /// **'Push every stick to its maximum and minimum several times, then press Next.'**
  String get stickCalibrationExtremes;

  /// No description provided for @stickCalibrationCentre.
  ///
  /// In en, this message translates to:
  /// **'Release every stick to the centre, then press Capture centre.'**
  String get stickCalibrationCentre;

  /// No description provided for @stickCalibrationReview.
  ///
  /// In en, this message translates to:
  /// **'Check the results, then save them to the flight controller.'**
  String get stickCalibrationReview;

  /// No description provided for @startCalibration.
  ///
  /// In en, this message translates to:
  /// **'Start calibration'**
  String get startCalibration;

  /// No description provided for @captureCentre.
  ///
  /// In en, this message translates to:
  /// **'Capture centre'**
  String get captureCentre;

  /// No description provided for @saveCalibration.
  ///
  /// In en, this message translates to:
  /// **'Save calibration'**
  String get saveCalibration;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @centre.
  ///
  /// In en, this message translates to:
  /// **'Centre'**
  String get centre;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @channelMonitor.
  ///
  /// In en, this message translates to:
  /// **'Channel monitor'**
  String get channelMonitor;

  /// No description provided for @sensorsImuCompassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Raw sensor values from each IMU instance.'**
  String get sensorsImuCompassSubtitle;

  /// No description provided for @cardImuCompass.
  ///
  /// In en, this message translates to:
  /// **'IMU & compass'**
  String get cardImuCompass;

  /// No description provided for @cardBarometer.
  ///
  /// In en, this message translates to:
  /// **'Barometer'**
  String get cardBarometer;

  /// No description provided for @noBarometerData.
  ///
  /// In en, this message translates to:
  /// **'No barometer data'**
  String get noBarometerData;

  /// No description provided for @imuLevelCalibration.
  ///
  /// In en, this message translates to:
  /// **'IMU level calibration'**
  String get imuLevelCalibration;

  /// No description provided for @imuLevelCalibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place the flight controller face up and level, then calibrate.'**
  String get imuLevelCalibrationSubtitle;

  /// No description provided for @compassCalibration.
  ///
  /// In en, this message translates to:
  /// **'Compass calibration'**
  String get compassCalibration;

  /// No description provided for @compassCalibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rotate the aircraft level and clockwise, then nose-down and clockwise.'**
  String get compassCalibrationSubtitle;

  /// No description provided for @cardGlobalFlightLimits.
  ///
  /// In en, this message translates to:
  /// **'Global flight limits & motor idle'**
  String get cardGlobalFlightLimits;

  /// No description provided for @motorTest.
  ///
  /// In en, this message translates to:
  /// **'Motor test'**
  String get motorTest;

  /// No description provided for @motorTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spins each motor individually to check order and direction.'**
  String get motorTestSubtitle;

  /// No description provided for @removePropellers.
  ///
  /// In en, this message translates to:
  /// **'Remove propellers'**
  String get removePropellers;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get startTest;

  /// No description provided for @motorTestConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Motor test will spin M{motor} at {throttle}% for {seconds} s.\nConfirm propellers are removed and the aircraft is secured.'**
  String motorTestConfirmMessage(int motor, String throttle, String seconds);

  /// No description provided for @testingMotors.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get testingMotors;

  /// No description provided for @testMotors.
  ///
  /// In en, this message translates to:
  /// **'Test motors'**
  String get testMotors;

  /// No description provided for @calibrateImu.
  ///
  /// In en, this message translates to:
  /// **'Calibrate IMU'**
  String get calibrateImu;

  /// No description provided for @calibratingImu.
  ///
  /// In en, this message translates to:
  /// **'Calibrating…'**
  String get calibratingImu;

  /// No description provided for @calibrateCompass.
  ///
  /// In en, this message translates to:
  /// **'Calibrate compass'**
  String get calibrateCompass;

  /// No description provided for @calibratingCompass.
  ///
  /// In en, this message translates to:
  /// **'Calibrating…'**
  String get calibratingCompass;

  /// No description provided for @gainsDescription.
  ///
  /// In en, this message translates to:
  /// **'Control gains set the pilot\'s feel: higher values respond faster but need more power. Only move the performance tendency towards vibration suppression if the airframe visibly shakes or the motors sound noisy.'**
  String get gainsDescription;

  /// No description provided for @protectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Current voltage: {voltage}. Level 2 must be lower than level 1; both levels also flash the lights.'**
  String protectionDescription(String voltage);

  /// No description provided for @barometerReading.
  ///
  /// In en, this message translates to:
  /// **'Pressure {pressure} hPa   ·   Temperature {temperature} °C'**
  String barometerReading(String pressure, String temperature);

  /// No description provided for @cardBasicGains.
  ///
  /// In en, this message translates to:
  /// **'Basic gains'**
  String get cardBasicGains;

  /// No description provided for @cardControlGains.
  ///
  /// In en, this message translates to:
  /// **'Control gains'**
  String get cardControlGains;

  /// No description provided for @cardSpeedSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Speed & sensitivity'**
  String get cardSpeedSensitivity;

  /// No description provided for @cardVoltageRtlLanding.
  ///
  /// In en, this message translates to:
  /// **'Voltage, return home & landing'**
  String get cardVoltageRtlLanding;

  /// No description provided for @voltageCalibration.
  ///
  /// In en, this message translates to:
  /// **'Voltage calibration'**
  String get voltageCalibration;

  /// No description provided for @voltageCalibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the voltage measured with a meter so the FC reading matches it.'**
  String get voltageCalibrationSubtitle;

  /// No description provided for @meterVoltageV.
  ///
  /// In en, this message translates to:
  /// **'Meter voltage (V)'**
  String get meterVoltageV;

  /// No description provided for @calibrateVoltage.
  ///
  /// In en, this message translates to:
  /// **'Calibrate voltage'**
  String get calibrateVoltage;

  /// No description provided for @cardPump.
  ///
  /// In en, this message translates to:
  /// **'Pump'**
  String get cardPump;

  /// No description provided for @cardLevelSensorProtection.
  ///
  /// In en, this message translates to:
  /// **'Level sensor & protection'**
  String get cardLevelSensorProtection;

  /// No description provided for @cardAbJobSettings.
  ///
  /// In en, this message translates to:
  /// **'AB job settings'**
  String get cardAbJobSettings;

  /// No description provided for @cardAbJobProcedure.
  ///
  /// In en, this message translates to:
  /// **'AB job procedure'**
  String get cardAbJobProcedure;

  /// No description provided for @fenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Circle and altitude limits. Draw/adjust the circle from the Mission map, or set values here.'**
  String get fenceDescription;

  /// No description provided for @cardQuickFence.
  ///
  /// In en, this message translates to:
  /// **'Quick fence'**
  String get cardQuickFence;

  /// No description provided for @fenceEnabled.
  ///
  /// In en, this message translates to:
  /// **'Fence is enabled'**
  String get fenceEnabled;

  /// No description provided for @fenceOff.
  ///
  /// In en, this message translates to:
  /// **'Fence is off'**
  String get fenceOff;

  /// No description provided for @enableAltitudeAndCircle.
  ///
  /// In en, this message translates to:
  /// **'Enable altitude + circle'**
  String get enableAltitudeAndCircle;

  /// No description provided for @disableFence.
  ///
  /// In en, this message translates to:
  /// **'Disable fence'**
  String get disableFence;

  /// No description provided for @cardHeightDistanceLimits.
  ///
  /// In en, this message translates to:
  /// **'Height & distance limits'**
  String get cardHeightDistanceLimits;

  /// No description provided for @cardRtkAntenna.
  ///
  /// In en, this message translates to:
  /// **'RTK antenna'**
  String get cardRtkAntenna;

  /// No description provided for @rtkCurrentPositioning.
  ///
  /// In en, this message translates to:
  /// **'Current positioning: {fix}'**
  String rtkCurrentPositioning(String fix);

  /// No description provided for @cardRadarVision4g.
  ///
  /// In en, this message translates to:
  /// **'Radar, vision & 4G module status'**
  String get cardRadarVision4g;

  /// No description provided for @extensionsRadarStatusDescription.
  ///
  /// In en, this message translates to:
  /// **'Terrain-following radar height, obstacle radar distance, vision module state and the IoT SIM status are shown here in the K++ assistant.'**
  String get extensionsRadarStatusDescription;

  /// No description provided for @channelsDescription.
  ///
  /// In en, this message translates to:
  /// **'Check the channel monitor to see which channels your RC uses before assigning functions.'**
  String get channelsDescription;

  /// No description provided for @cardChannelFunctions.
  ///
  /// In en, this message translates to:
  /// **'Channel functions'**
  String get cardChannelFunctions;

  /// No description provided for @flightLogsDescription.
  ///
  /// In en, this message translates to:
  /// **'Downloaded logs are saved to Documents\\Fuselage-K++\\logs.'**
  String get flightLogsDescription;

  /// No description provided for @refreshList.
  ///
  /// In en, this message translates to:
  /// **'Refresh list'**
  String get refreshList;

  /// No description provided for @logsOnFlightController.
  ///
  /// In en, this message translates to:
  /// **'{count} logs on the flight controller'**
  String logsOnFlightController(int count);

  /// No description provided for @parametersDescription.
  ///
  /// In en, this message translates to:
  /// **'{count} parameters read from the flight controller.'**
  String parametersDescription(int count);

  /// No description provided for @parameterFiles.
  ///
  /// In en, this message translates to:
  /// **'Parameter files'**
  String get parameterFiles;

  /// No description provided for @reloadFromFc.
  ///
  /// In en, this message translates to:
  /// **'Reload from FC'**
  String get reloadFromFc;

  /// No description provided for @searchByIdOrName.
  ///
  /// In en, this message translates to:
  /// **'Search by id or name'**
  String get searchByIdOrName;

  /// No description provided for @parametersShown.
  ///
  /// In en, this message translates to:
  /// **'{count} shown'**
  String parametersShown(int count);

  /// No description provided for @paramColumnId.
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get paramColumnId;

  /// No description provided for @paramColumnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get paramColumnName;

  /// No description provided for @paramColumnValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get paramColumnValue;

  /// No description provided for @paramFormHint.
  ///
  /// In en, this message translates to:
  /// **'Type a value and press Enter to write it to the flight controller.'**
  String get paramFormHint;

  /// No description provided for @paramNotReported.
  ///
  /// In en, this message translates to:
  /// **'Not reported by this flight controller'**
  String get paramNotReported;

  /// No description provided for @paramUnknownOption.
  ///
  /// In en, this message translates to:
  /// **'Unknown ({value})'**
  String paramUnknownOption(String value);

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @writeToFlightControllerTitle.
  ///
  /// In en, this message translates to:
  /// **'Write to flight controller?'**
  String get writeToFlightControllerTitle;

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write;

  /// No description provided for @cardVersions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get cardVersions;

  /// No description provided for @cardVersionsAuthorisation.
  ///
  /// In en, this message translates to:
  /// **'Versions & authorisation'**
  String get cardVersionsAuthorisation;

  /// No description provided for @firmwareUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Firmware upgrade'**
  String get firmwareUpgrade;

  /// No description provided for @firmwareUpgradeDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload K++ V2 / KX / P3 firmware through the flight controller bootloader. Never remove the device while upgrading.'**
  String get firmwareUpgradeDescription;

  /// No description provided for @upgradeFirmware.
  ///
  /// In en, this message translates to:
  /// **'Upgrade firmware'**
  String get upgradeFirmware;

  /// No description provided for @factoryReset.
  ///
  /// In en, this message translates to:
  /// **'Factory reset'**
  String get factoryReset;

  /// No description provided for @factoryResetDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore every parameter to the factory defaults.'**
  String get factoryResetDescription;

  /// No description provided for @restoreFactorySettings.
  ///
  /// In en, this message translates to:
  /// **'Restore factory settings'**
  String get restoreFactorySettings;

  /// No description provided for @droneRegistration.
  ///
  /// In en, this message translates to:
  /// **'Drone registration'**
  String get droneRegistration;

  /// No description provided for @droneRegistrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer name, aircraft model and aircraft number (网络备案).'**
  String get droneRegistrationDescription;

  /// No description provided for @shape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get shape;

  /// No description provided for @validateMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum is {value}'**
  String validateMinimum(String value);

  /// No description provided for @validateMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum is {value}'**
  String validateMaximum(String value);

  /// No description provided for @validateChooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose one of the listed options'**
  String get validateChooseOption;

  /// No description provided for @instance.
  ///
  /// In en, this message translates to:
  /// **'Instance'**
  String get instance;

  /// No description provided for @accelAxes.
  ///
  /// In en, this message translates to:
  /// **'Accel X / Y / Z'**
  String get accelAxes;

  /// No description provided for @gyroAxes.
  ///
  /// In en, this message translates to:
  /// **'Gyro X / Y / Z'**
  String get gyroAxes;

  /// No description provided for @compassAxes.
  ///
  /// In en, this message translates to:
  /// **'Compass X / Y / Z'**
  String get compassAxes;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @channelMonitorNoData.
  ///
  /// In en, this message translates to:
  /// **'No RC data received yet.'**
  String get channelMonitorNoData;

  /// No description provided for @channelMonitorHint.
  ///
  /// In en, this message translates to:
  /// **'Move the sticks and switches to see each channel.'**
  String get channelMonitorHint;

  /// No description provided for @duplicateChannelFunctions.
  ///
  /// In en, this message translates to:
  /// **'Duplicate channel functions: {details}'**
  String duplicateChannelFunctions(String details);

  /// No description provided for @logColumnNo.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get logColumnNo;

  /// No description provided for @logColumnTimeUtc.
  ///
  /// In en, this message translates to:
  /// **'Time (UTC)'**
  String get logColumnTimeUtc;

  /// No description provided for @logColumnSizeBytes.
  ///
  /// In en, this message translates to:
  /// **'Size (bytes)'**
  String get logColumnSizeBytes;

  /// No description provided for @logReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get logReview;

  /// No description provided for @logSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Log {id} saved to {path}'**
  String logSavedTo(int id, String path);

  /// No description provided for @motorThrottlePercent.
  ///
  /// In en, this message translates to:
  /// **'Throttle {percent} %'**
  String motorThrottlePercent(String percent);

  /// No description provided for @motorDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'Duration {seconds} s'**
  String motorDurationSeconds(String seconds);

  /// No description provided for @motorTestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Motor M{motor} test accepted'**
  String motorTestAccepted(int motor);

  /// No description provided for @motorTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Motor test failed: {error}'**
  String motorTestFailed(String error);

  /// No description provided for @imuCalibrationAccepted.
  ///
  /// In en, this message translates to:
  /// **'IMU calibration accepted'**
  String get imuCalibrationAccepted;

  /// No description provided for @imuCalibrationFailed.
  ///
  /// In en, this message translates to:
  /// **'IMU calibration failed: {error}'**
  String imuCalibrationFailed(String error);

  /// No description provided for @compassCalibrationStarted.
  ///
  /// In en, this message translates to:
  /// **'Compass calibration started'**
  String get compassCalibrationStarted;

  /// No description provided for @compassCalibrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Compass calibration failed: {error}'**
  String compassCalibrationFailed(String error);

  /// No description provided for @paramSaved.
  ///
  /// In en, this message translates to:
  /// **'{id} saved: {value}'**
  String paramSaved(String id, String value);

  /// No description provided for @paramNotSaved.
  ///
  /// In en, this message translates to:
  /// **'{id} not saved: {error}'**
  String paramNotSaved(String id, String error);

  /// No description provided for @paramsSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} parameters saved'**
  String paramsSavedCount(int count);

  /// No description provided for @paramsSavedPartial.
  ///
  /// In en, this message translates to:
  /// **'{saved} saved, {failed} failed: {ids}'**
  String paramsSavedPartial(int saved, int failed, String ids);

  /// No description provided for @stickCalibrationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Channel min/max out of range: {channels}. Calibration failed — try again.'**
  String stickCalibrationInvalid(String channels);

  /// No description provided for @fcReadingAndMultiplier.
  ///
  /// In en, this message translates to:
  /// **'FC reading: {reading}   ·   multiplier: {mult}'**
  String fcReadingAndMultiplier(String reading, String mult);

  /// No description provided for @enterValidMeterVoltage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid meter voltage'**
  String get enterValidMeterVoltage;

  /// No description provided for @noBatteryVoltageYet.
  ///
  /// In en, this message translates to:
  /// **'No battery voltage from the flight controller yet'**
  String get noBatteryVoltageYet;

  /// No description provided for @logParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not parse log: {error}'**
  String logParseFailed(String error);

  /// No description provided for @logParseFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Open the .bin externally for full analysis.'**
  String get logParseFailedHint;

  /// No description provided for @logNoTrackSamples.
  ///
  /// In en, this message translates to:
  /// **'No GPS/ATT samples recognised in this log.'**
  String get logNoTrackSamples;

  /// No description provided for @plotNoSamples.
  ///
  /// In en, this message translates to:
  /// **'No samples'**
  String get plotNoSamples;

  /// No description provided for @plotMinMax.
  ///
  /// In en, this message translates to:
  /// **'min {min}  ·  max {max}'**
  String plotMinMax(String min, String max);

  /// No description provided for @exportParametersTo.
  ///
  /// In en, this message translates to:
  /// **'Exported {count} parameters to {path}'**
  String exportParametersTo(int count, String path);

  /// No description provided for @importFileFormatError.
  ///
  /// In en, this message translates to:
  /// **'File format error: {message}'**
  String importFileFormatError(String message);

  /// No description provided for @importNothingMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing to import: every value already matches the flight controller.'**
  String get importNothingMatches;

  /// No description provided for @fcFirmwareInfo.
  ///
  /// In en, this message translates to:
  /// **'Flight controller firmware: {version}'**
  String fcFirmwareInfo(String version);

  /// No description provided for @appAboutLine.
  ///
  /// In en, this message translates to:
  /// **'Fuselage-K++ 1.0.0 — built to replace the JIYI K++ assistant (JIYI221014).'**
  String get appAboutLine;

  /// No description provided for @sprayProcedure1Title.
  ///
  /// In en, this message translates to:
  /// **'Record point A'**
  String get sprayProcedure1Title;

  /// No description provided for @sprayProcedure1Detail.
  ///
  /// In en, this message translates to:
  /// **'Flip the AB record switch to the middle position.'**
  String get sprayProcedure1Detail;

  /// No description provided for @sprayProcedure2Title.
  ///
  /// In en, this message translates to:
  /// **'Record point B'**
  String get sprayProcedure2Title;

  /// No description provided for @sprayProcedure2Detail.
  ///
  /// In en, this message translates to:
  /// **'Flip the AB record switch to the high position.'**
  String get sprayProcedure2Detail;

  /// No description provided for @sprayProcedure3Title.
  ///
  /// In en, this message translates to:
  /// **'Start the AB job'**
  String get sprayProcedure3Title;

  /// No description provided for @sprayProcedure3Detail.
  ///
  /// In en, this message translates to:
  /// **'Turn on the AB execute switch (or set AB execute as a flight mode).'**
  String get sprayProcedure3Detail;

  /// No description provided for @sprayProcedure4Title.
  ///
  /// In en, this message translates to:
  /// **'Choose direction'**
  String get sprayProcedure4Title;

  /// No description provided for @sprayProcedure4Detail.
  ///
  /// In en, this message translates to:
  /// **'Push the roll stick towards the side to work.'**
  String get sprayProcedure4Detail;

  /// No description provided for @sprayProcedure5Title.
  ///
  /// In en, this message translates to:
  /// **'Clear A and B'**
  String get sprayProcedure5Title;

  /// No description provided for @sprayProcedure5Detail.
  ///
  /// In en, this message translates to:
  /// **'Flip the AB record switch back and forth quickly.'**
  String get sprayProcedure5Detail;

  /// No description provided for @sprayProcedure6Title.
  ///
  /// In en, this message translates to:
  /// **'Resume after refill'**
  String get sprayProcedure6Title;

  /// No description provided for @sprayProcedure6Detail.
  ///
  /// In en, this message translates to:
  /// **'Without clearing A/B, turn on AB execute: the job resumes from the last empty-tank point and direction.'**
  String get sprayProcedure6Detail;

  /// No description provided for @waitingForProtocolConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for protocol confirmation'**
  String get waitingForProtocolConfirmation;

  /// No description provided for @pendingFeatureBody.
  ///
  /// In en, this message translates to:
  /// **'The K++ assistant uses a JIYI-specific command for this, not standard MAVLink. It stays disabled until a recording of the original app confirms the exact message, so nothing unverified is ever sent to the flight controller.'**
  String get pendingFeatureBody;

  /// No description provided for @optForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get optForward;

  /// No description provided for @optRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get optRight;

  /// No description provided for @optBackward.
  ///
  /// In en, this message translates to:
  /// **'Backward'**
  String get optBackward;

  /// No description provided for @optLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get optLeft;

  /// No description provided for @optOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get optOff;

  /// No description provided for @optOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get optOn;

  /// No description provided for @optSinglePump.
  ///
  /// In en, this message translates to:
  /// **'Single pump'**
  String get optSinglePump;

  /// No description provided for @optDoublePump.
  ///
  /// In en, this message translates to:
  /// **'Double pump'**
  String get optDoublePump;

  /// No description provided for @optQuadX.
  ///
  /// In en, this message translates to:
  /// **'Quad X'**
  String get optQuadX;

  /// No description provided for @optQuadPlus.
  ///
  /// In en, this message translates to:
  /// **'Quad +'**
  String get optQuadPlus;

  /// No description provided for @optHexaX.
  ///
  /// In en, this message translates to:
  /// **'Hexa X'**
  String get optHexaX;

  /// No description provided for @optHexaPlus.
  ///
  /// In en, this message translates to:
  /// **'Hexa +'**
  String get optHexaPlus;

  /// No description provided for @optOctoX.
  ///
  /// In en, this message translates to:
  /// **'Octo X'**
  String get optOctoX;

  /// No description provided for @optOctoPlus.
  ///
  /// In en, this message translates to:
  /// **'Octo +'**
  String get optOctoPlus;

  /// No description provided for @optStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get optStandard;

  /// No description provided for @optCoaxial.
  ///
  /// In en, this message translates to:
  /// **'Coaxial'**
  String get optCoaxial;

  /// No description provided for @optY6.
  ///
  /// In en, this message translates to:
  /// **'Y6'**
  String get optY6;

  /// No description provided for @optAltitude.
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get optAltitude;

  /// No description provided for @optAltitudeCircle.
  ///
  /// In en, this message translates to:
  /// **'Altitude + circle'**
  String get optAltitudeCircle;

  /// No description provided for @optCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get optCircle;

  /// No description provided for @pLabel_FRAME.
  ///
  /// In en, this message translates to:
  /// **'Frame type'**
  String get pLabel_FRAME;

  /// No description provided for @pLabel_SHAPE.
  ///
  /// In en, this message translates to:
  /// **'Frame shape'**
  String get pLabel_SHAPE;

  /// No description provided for @pLabel_NAV_IMU_ORIENT.
  ///
  /// In en, this message translates to:
  /// **'IMU direction'**
  String get pLabel_NAV_IMU_ORIENT;

  /// No description provided for @pLabel_NAV_COMP_ORIENT.
  ///
  /// In en, this message translates to:
  /// **'GPS direction'**
  String get pLabel_NAV_COMP_ORIENT;

  /// No description provided for @pLabel_NAV_IMU_POS_X.
  ///
  /// In en, this message translates to:
  /// **'IMU position X'**
  String get pLabel_NAV_IMU_POS_X;

  /// No description provided for @pLabel_NAV_IMU_POS_Y.
  ///
  /// In en, this message translates to:
  /// **'IMU position Y'**
  String get pLabel_NAV_IMU_POS_Y;

  /// No description provided for @pLabel_NAV_IMU_POS_Z.
  ///
  /// In en, this message translates to:
  /// **'IMU position Z'**
  String get pLabel_NAV_IMU_POS_Z;

  /// No description provided for @pLabel_NAV_GPS3_POS_X.
  ///
  /// In en, this message translates to:
  /// **'GPS position X'**
  String get pLabel_NAV_GPS3_POS_X;

  /// No description provided for @pLabel_NAV_GPS3_POS_Y.
  ///
  /// In en, this message translates to:
  /// **'GPS position Y'**
  String get pLabel_NAV_GPS3_POS_Y;

  /// No description provided for @pLabel_NAV_GPS3_POS_Z.
  ///
  /// In en, this message translates to:
  /// **'GPS position Z'**
  String get pLabel_NAV_GPS3_POS_Z;

  /// No description provided for @pLabel_NAV_IMU_SOURCE.
  ///
  /// In en, this message translates to:
  /// **'IMU source'**
  String get pLabel_NAV_IMU_SOURCE;

  /// No description provided for @pLabel_RC_TYPE.
  ///
  /// In en, this message translates to:
  /// **'RC type'**
  String get pLabel_RC_TYPE;

  /// No description provided for @pLabel_FS_THR_ENABLE.
  ///
  /// In en, this message translates to:
  /// **'RC-loss failsafe action'**
  String get pLabel_FS_THR_ENABLE;

  /// No description provided for @pLabel_RC_FS_CONTINUE.
  ///
  /// In en, this message translates to:
  /// **'Continue job when RC is lost'**
  String get pLabel_RC_FS_CONTINUE;

  /// No description provided for @pLabel_THR_DZ.
  ///
  /// In en, this message translates to:
  /// **'Throttle mid dead zone'**
  String get pLabel_THR_DZ;

  /// No description provided for @pLabel_FLTMODE1.
  ///
  /// In en, this message translates to:
  /// **'Flight mode 1'**
  String get pLabel_FLTMODE1;

  /// No description provided for @pLabel_FLTMODE2.
  ///
  /// In en, this message translates to:
  /// **'Flight mode 2'**
  String get pLabel_FLTMODE2;

  /// No description provided for @pLabel_FLTMODE3.
  ///
  /// In en, this message translates to:
  /// **'Flight mode 3'**
  String get pLabel_FLTMODE3;

  /// No description provided for @pLabel_FLTMODE4.
  ///
  /// In en, this message translates to:
  /// **'Flight mode 4'**
  String get pLabel_FLTMODE4;

  /// No description provided for @pLabel_FLTMODE5.
  ///
  /// In en, this message translates to:
  /// **'Flight mode 5'**
  String get pLabel_FLTMODE5;

  /// No description provided for @pLabel_FLTMODE6.
  ///
  /// In en, this message translates to:
  /// **'Flight mode 6'**
  String get pLabel_FLTMODE6;

  /// No description provided for @pLabel_RC1_MIN.
  ///
  /// In en, this message translates to:
  /// **'CH1 min'**
  String get pLabel_RC1_MIN;

  /// No description provided for @pLabel_RC1_MAX.
  ///
  /// In en, this message translates to:
  /// **'CH1 max'**
  String get pLabel_RC1_MAX;

  /// No description provided for @pLabel_RC1_TRIM.
  ///
  /// In en, this message translates to:
  /// **'CH1 trim'**
  String get pLabel_RC1_TRIM;

  /// No description provided for @pLabel_RC2_MIN.
  ///
  /// In en, this message translates to:
  /// **'CH2 min'**
  String get pLabel_RC2_MIN;

  /// No description provided for @pLabel_RC2_MAX.
  ///
  /// In en, this message translates to:
  /// **'CH2 max'**
  String get pLabel_RC2_MAX;

  /// No description provided for @pLabel_RC2_TRIM.
  ///
  /// In en, this message translates to:
  /// **'CH2 trim'**
  String get pLabel_RC2_TRIM;

  /// No description provided for @pLabel_RC3_MIN.
  ///
  /// In en, this message translates to:
  /// **'CH3 min'**
  String get pLabel_RC3_MIN;

  /// No description provided for @pLabel_RC3_MAX.
  ///
  /// In en, this message translates to:
  /// **'CH3 max'**
  String get pLabel_RC3_MAX;

  /// No description provided for @pLabel_RC3_TRIM.
  ///
  /// In en, this message translates to:
  /// **'CH3 trim'**
  String get pLabel_RC3_TRIM;

  /// No description provided for @pLabel_RC4_MIN.
  ///
  /// In en, this message translates to:
  /// **'CH4 min'**
  String get pLabel_RC4_MIN;

  /// No description provided for @pLabel_RC4_MAX.
  ///
  /// In en, this message translates to:
  /// **'CH4 max'**
  String get pLabel_RC4_MAX;

  /// No description provided for @pLabel_RC4_TRIM.
  ///
  /// In en, this message translates to:
  /// **'CH4 trim'**
  String get pLabel_RC4_TRIM;

  /// No description provided for @pLabel_ANGLE_MAX.
  ///
  /// In en, this message translates to:
  /// **'Max tilt angle'**
  String get pLabel_ANGLE_MAX;

  /// No description provided for @pLabel_WPNAV_LOIT_SPEED.
  ///
  /// In en, this message translates to:
  /// **'Max horizontal speed'**
  String get pLabel_WPNAV_LOIT_SPEED;

  /// No description provided for @pLabel_PILOT_VELZ_UP.
  ///
  /// In en, this message translates to:
  /// **'Max climb speed'**
  String get pLabel_PILOT_VELZ_UP;

  /// No description provided for @pLabel_PILOT_VELZ_DOWN.
  ///
  /// In en, this message translates to:
  /// **'Max descent speed'**
  String get pLabel_PILOT_VELZ_DOWN;

  /// No description provided for @pLabel_MOT_SPIN_ARMED.
  ///
  /// In en, this message translates to:
  /// **'Motor idle speed'**
  String get pLabel_MOT_SPIN_ARMED;

  /// No description provided for @pLabel_GAIN_BASIC_R_PI.
  ///
  /// In en, this message translates to:
  /// **'Roll correction'**
  String get pLabel_GAIN_BASIC_R_PI;

  /// No description provided for @pLabel_GAIN_BASIC_R_D.
  ///
  /// In en, this message translates to:
  /// **'Roll damping'**
  String get pLabel_GAIN_BASIC_R_D;

  /// No description provided for @pLabel_GAIN_BASIC_P_PI.
  ///
  /// In en, this message translates to:
  /// **'Pitch correction'**
  String get pLabel_GAIN_BASIC_P_PI;

  /// No description provided for @pLabel_GAIN_BASIC_P_D.
  ///
  /// In en, this message translates to:
  /// **'Pitch damping'**
  String get pLabel_GAIN_BASIC_P_D;

  /// No description provided for @pLabel_GAIN_BASIC_YAW.
  ///
  /// In en, this message translates to:
  /// **'Yaw'**
  String get pLabel_GAIN_BASIC_YAW;

  /// No description provided for @pLabel_GAIN_BASIC_THR.
  ///
  /// In en, this message translates to:
  /// **'Power (vertical)'**
  String get pLabel_GAIN_BASIC_THR;

  /// No description provided for @pLabel_GAIN_CONTROL_RP.
  ///
  /// In en, this message translates to:
  /// **'Roll / pitch'**
  String get pLabel_GAIN_CONTROL_RP;

  /// No description provided for @pLabel_GAIN_CONTROL_YAW.
  ///
  /// In en, this message translates to:
  /// **'Yaw'**
  String get pLabel_GAIN_CONTROL_YAW;

  /// No description provided for @pLabel_GAIN_CONTROL_THR.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get pLabel_GAIN_CONTROL_THR;

  /// No description provided for @pLabel_GAIN_CONTROL_WP.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get pLabel_GAIN_CONTROL_WP;

  /// No description provided for @pLabel_GAIN_CONTROL_MOV.
  ///
  /// In en, this message translates to:
  /// **'Manoeuvre'**
  String get pLabel_GAIN_CONTROL_MOV;

  /// No description provided for @pLabel_GAIN_CONTROL_BRA.
  ///
  /// In en, this message translates to:
  /// **'Brake'**
  String get pLabel_GAIN_CONTROL_BRA;

  /// No description provided for @pLabel_GAIN_CONTROL_SCA.
  ///
  /// In en, this message translates to:
  /// **'Coordination'**
  String get pLabel_GAIN_CONTROL_SCA;

  /// No description provided for @pLabel_GAIN_CONTROL_TKO.
  ///
  /// In en, this message translates to:
  /// **'Take-off'**
  String get pLabel_GAIN_CONTROL_TKO;

  /// No description provided for @pLabel_GAIN_VEL_XY.
  ///
  /// In en, this message translates to:
  /// **'Horizontal speed gain'**
  String get pLabel_GAIN_VEL_XY;

  /// No description provided for @pLabel_GAIN_VEL_Z.
  ///
  /// In en, this message translates to:
  /// **'Vertical speed gain'**
  String get pLabel_GAIN_VEL_Z;

  /// No description provided for @pLabel_GAIN_SEN_ATT.
  ///
  /// In en, this message translates to:
  /// **'Attitude sensitivity'**
  String get pLabel_GAIN_SEN_ATT;

  /// No description provided for @pLabel_GAIN_PERFORMANCE.
  ///
  /// In en, this message translates to:
  /// **'Performance tendency'**
  String get pLabel_GAIN_PERFORMANCE;

  /// No description provided for @pLabel_FS_BATT_ENABLE.
  ///
  /// In en, this message translates to:
  /// **'Low-voltage protection action'**
  String get pLabel_FS_BATT_ENABLE;

  /// No description provided for @pLabel_FS_BATT_WARNING.
  ///
  /// In en, this message translates to:
  /// **'Level 1 alarm voltage'**
  String get pLabel_FS_BATT_WARNING;

  /// No description provided for @pLabel_FS_BATT_VOLTAGE.
  ///
  /// In en, this message translates to:
  /// **'Level 2 alarm voltage'**
  String get pLabel_FS_BATT_VOLTAGE;

  /// No description provided for @pLabel_FS_PMU_ENABLE.
  ///
  /// In en, this message translates to:
  /// **'PMU fault protection'**
  String get pLabel_FS_PMU_ENABLE;

  /// No description provided for @pLabel_RTL_ALT.
  ///
  /// In en, this message translates to:
  /// **'Return-home height'**
  String get pLabel_RTL_ALT;

  /// No description provided for @pLabel_LAND_SPEED.
  ///
  /// In en, this message translates to:
  /// **'Landing speed'**
  String get pLabel_LAND_SPEED;

  /// No description provided for @pLabel_SPRAY_PUMP_TYPE.
  ///
  /// In en, this message translates to:
  /// **'Pump type'**
  String get pLabel_SPRAY_PUMP_TYPE;

  /// No description provided for @pLabel_LIQUID_TYPE.
  ///
  /// In en, this message translates to:
  /// **'Level sensor type'**
  String get pLabel_LIQUID_TYPE;

  /// No description provided for @pLabel_FS_LIQ_ENABLE.
  ///
  /// In en, this message translates to:
  /// **'Out-of-liquid protection'**
  String get pLabel_FS_LIQ_ENABLE;

  /// No description provided for @pLabel_ABPOINT_DIS.
  ///
  /// In en, this message translates to:
  /// **'AB swath width'**
  String get pLabel_ABPOINT_DIS;

  /// No description provided for @pLabel_ABPOINT_SPEED.
  ///
  /// In en, this message translates to:
  /// **'AB speed'**
  String get pLabel_ABPOINT_SPEED;

  /// No description provided for @pLabel_WPNAV_ENABLE_U.
  ///
  /// In en, this message translates to:
  /// **'U-shaped side shift'**
  String get pLabel_WPNAV_ENABLE_U;

  /// No description provided for @pLabel_FENCE_ENABLE.
  ///
  /// In en, this message translates to:
  /// **'Fence enable'**
  String get pLabel_FENCE_ENABLE;

  /// No description provided for @pLabel_FENCE_TYPE.
  ///
  /// In en, this message translates to:
  /// **'Fence type'**
  String get pLabel_FENCE_TYPE;

  /// No description provided for @pLabel_FENCE_ALT_MAX.
  ///
  /// In en, this message translates to:
  /// **'Height limit'**
  String get pLabel_FENCE_ALT_MAX;

  /// No description provided for @pLabel_FENCE_RADIUS.
  ///
  /// In en, this message translates to:
  /// **'Distance limit (radius)'**
  String get pLabel_FENCE_RADIUS;

  /// No description provided for @pLabel_FENCE_ACTION.
  ///
  /// In en, this message translates to:
  /// **'Fence breach action'**
  String get pLabel_FENCE_ACTION;

  /// No description provided for @pLabel_RTK_ANTI_DEG.
  ///
  /// In en, this message translates to:
  /// **'RTK antenna install angle'**
  String get pLabel_RTK_ANTI_DEG;

  /// No description provided for @pLabel_CH6_OPT.
  ///
  /// In en, this message translates to:
  /// **'Channel 6 function'**
  String get pLabel_CH6_OPT;

  /// No description provided for @pLabel_CH7_OPT.
  ///
  /// In en, this message translates to:
  /// **'Channel 7 function'**
  String get pLabel_CH7_OPT;

  /// No description provided for @pLabel_CH8_OPT.
  ///
  /// In en, this message translates to:
  /// **'Channel 8 function'**
  String get pLabel_CH8_OPT;

  /// No description provided for @pLabel_CH9_OPT.
  ///
  /// In en, this message translates to:
  /// **'Channel 9 function'**
  String get pLabel_CH9_OPT;

  /// No description provided for @pLabel_CH10_OPT.
  ///
  /// In en, this message translates to:
  /// **'Channel 10 function'**
  String get pLabel_CH10_OPT;

  /// No description provided for @pLabel_CH11_OPT.
  ///
  /// In en, this message translates to:
  /// **'Channel 11 function'**
  String get pLabel_CH11_OPT;

  /// No description provided for @pLabel_CH12_OPT.
  ///
  /// In en, this message translates to:
  /// **'Channel 12 function'**
  String get pLabel_CH12_OPT;

  /// No description provided for @pLabel_BATT_VOLT_MULT.
  ///
  /// In en, this message translates to:
  /// **'Battery voltage multiplier'**
  String get pLabel_BATT_VOLT_MULT;

  /// No description provided for @pLabel_FWVERSION.
  ///
  /// In en, this message translates to:
  /// **'Firmware version'**
  String get pLabel_FWVERSION;

  /// No description provided for @pLabel_SYSID_SW_MREV.
  ///
  /// In en, this message translates to:
  /// **'Software revision'**
  String get pLabel_SYSID_SW_MREV;

  /// No description provided for @pLabel_INS_CAL_TYPE.
  ///
  /// In en, this message translates to:
  /// **'IMU calibration state'**
  String get pLabel_INS_CAL_TYPE;

  /// No description provided for @pLabel_COMPASS_CAL_TYPE.
  ///
  /// In en, this message translates to:
  /// **'Compass calibration state'**
  String get pLabel_COMPASS_CAL_TYPE;

  /// No description provided for @pLabel_REG_ENABLE.
  ///
  /// In en, this message translates to:
  /// **'App unlock authorised'**
  String get pLabel_REG_ENABLE;

  /// No description provided for @helpBasicGain.
  ///
  /// In en, this message translates to:
  /// **'Range 0–200 %. Adapts the controller to the airframe.'**
  String get helpBasicGain;

  /// No description provided for @helpControlGain.
  ///
  /// In en, this message translates to:
  /// **'Range 0–300 %. Higher = faster response; limited by the airframe\'s power.'**
  String get helpControlGain;

  /// No description provided for @helpMode.
  ///
  /// In en, this message translates to:
  /// **'K++ options include Manual job, AB execute, Route job, GPS speed, Side shift and Terrain follow. Value mapping not yet confirmed.'**
  String get helpMode;

  /// No description provided for @helpChannel.
  ///
  /// In en, this message translates to:
  /// **'Function assigned to this RC channel. Each function should be used once; check the channel monitor before changing.'**
  String get helpChannel;

  /// No description provided for @help_0.
  ///
  /// In en, this message translates to:
  /// **'Motor count and layout written as FRAME on the K++ bus.'**
  String get help_0;

  /// No description provided for @help_1.
  ///
  /// In en, this message translates to:
  /// **'Offset from the centre of gravity. Blue zone = negative, yellow zone = positive.'**
  String get help_1;

  /// No description provided for @help_2.
  ///
  /// In en, this message translates to:
  /// **'Receiver protocol. Value mapping not yet confirmed.'**
  String get help_2;

  /// No description provided for @help_3.
  ///
  /// In en, this message translates to:
  /// **'K++ options: Return home, Hover, Land, Hover then land. Value mapping not yet confirmed — test with the RC switched off after changing.'**
  String get help_3;

  /// No description provided for @help_4.
  ///
  /// In en, this message translates to:
  /// **'In AB / route jobs the drone keeps working instead of running the failsafe. Recommended only with radar.'**
  String get help_4;

  /// No description provided for @help_5.
  ///
  /// In en, this message translates to:
  /// **'Centidegrees: 3000 = 30°.'**
  String get help_5;

  /// No description provided for @help_6.
  ///
  /// In en, this message translates to:
  /// **'K++ options: Disabled, Very slow, Slow, Medium, Very fast. Value mapping not yet confirmed.'**
  String get help_6;

  /// No description provided for @help_7.
  ///
  /// In en, this message translates to:
  /// **'Acceleration in autonomous flight. Higher = faster speed changes.'**
  String get help_7;

  /// No description provided for @help_8.
  ///
  /// In en, this message translates to:
  /// **'Acceleration under pilot control.'**
  String get help_8;

  /// No description provided for @help_9.
  ///
  /// In en, this message translates to:
  /// **'Higher = shorter, harder automatic braking.'**
  String get help_9;

  /// No description provided for @help_10.
  ///
  /// In en, this message translates to:
  /// **'Matches control response to manoeuvres; faster power systems need higher values.'**
  String get help_10;

  /// No description provided for @help_11.
  ///
  /// In en, this message translates to:
  /// **'Higher = quicker, crisper take-off.'**
  String get help_11;

  /// No description provided for @help_12.
  ///
  /// In en, this message translates to:
  /// **'Normally not adjusted.'**
  String get help_12;

  /// No description provided for @help_13.
  ///
  /// In en, this message translates to:
  /// **'How quickly the FC follows stick input.'**
  String get help_13;

  /// No description provided for @help_14.
  ///
  /// In en, this message translates to:
  /// **'K++ options: Balanced, Sport, Anti-vibration. Only move towards vibration suppression if the airframe visibly shakes. Value mapping not yet confirmed.'**
  String get help_14;

  /// No description provided for @help_15.
  ///
  /// In en, this message translates to:
  /// **'K++ options: Off, Return home, Land (both levels also flash the lights). Value mapping not yet confirmed.'**
  String get help_15;

  /// No description provided for @help_16.
  ///
  /// In en, this message translates to:
  /// **'Must be lower than the level 1 voltage.'**
  String get help_16;

  /// No description provided for @help_17.
  ///
  /// In en, this message translates to:
  /// **'Single: pump ESC on P1. Double: ESCs on P1 and P2; P1 runs flying forward, P2 flying backward.'**
  String get help_17;

  /// No description provided for @help_18.
  ///
  /// In en, this message translates to:
  /// **'K++ options: Not used, Switch sensor (FC port K2), Real-time level. Flow meter goes on port K1. Value mapping not yet confirmed.'**
  String get help_18;

  /// No description provided for @help_19.
  ///
  /// In en, this message translates to:
  /// **'Action when the tank runs dry. Value mapping not yet confirmed.'**
  String get help_19;

  /// No description provided for @help_20.
  ///
  /// In en, this message translates to:
  /// **'Scale factor used for voltage calibration (meter reading ÷ FC reading).'**
  String get help_20;

  /// No description provided for @simulatorNoHardware.
  ///
  /// In en, this message translates to:
  /// **'Simulator (no hardware)'**
  String get simulatorNoHardware;

  /// No description provided for @hideTransmitter.
  ///
  /// In en, this message translates to:
  /// **'Hide transmitter'**
  String get hideTransmitter;

  /// No description provided for @showTransmitter.
  ///
  /// In en, this message translates to:
  /// **'Transmitter BT/WiFi'**
  String get showTransmitter;

  /// No description provided for @btAbbrev.
  ///
  /// In en, this message translates to:
  /// **'BT'**
  String get btAbbrev;

  /// No description provided for @noBtSerialRefresh.
  ///
  /// In en, this message translates to:
  /// **'No BT serial port — pair TX then refresh'**
  String get noBtSerialRefresh;

  /// No description provided for @txWifiIp.
  ///
  /// In en, this message translates to:
  /// **'TX WiFi IP'**
  String get txWifiIp;

  /// No description provided for @tcp.
  ///
  /// In en, this message translates to:
  /// **'TCP'**
  String get tcp;

  /// No description provided for @linkDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get linkDisconnected;

  /// No description provided for @linkConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get linkConnecting;

  /// No description provided for @linkReadingParameters.
  ///
  /// In en, this message translates to:
  /// **'Reading parameters {received}/{total}'**
  String linkReadingParameters(int received, int total);

  /// No description provided for @linkConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected · {link}'**
  String linkConnected(String link);

  /// No description provided for @linkLostStatus.
  ///
  /// In en, this message translates to:
  /// **'Link lost · {link}'**
  String linkLostStatus(String link);

  /// No description provided for @sensorGyroscope.
  ///
  /// In en, this message translates to:
  /// **'Gyroscope'**
  String get sensorGyroscope;

  /// No description provided for @sensorAccelerometer.
  ///
  /// In en, this message translates to:
  /// **'Accelerometer'**
  String get sensorAccelerometer;

  /// No description provided for @sensorCompass.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get sensorCompass;

  /// No description provided for @sensorBarometer.
  ///
  /// In en, this message translates to:
  /// **'Barometer'**
  String get sensorBarometer;

  /// No description provided for @sensorGps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get sensorGps;
}

class _KppLocalizationsDelegate
    extends LocalizationsDelegate<KppLocalizations> {
  const _KppLocalizationsDelegate();

  @override
  Future<KppLocalizations> load(Locale locale) {
    return SynchronousFuture<KppLocalizations>(lookupKppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'es', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_KppLocalizationsDelegate old) => false;
}

KppLocalizations lookupKppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return KppLocalizationsAr();
    case 'de':
      return KppLocalizationsDe();
    case 'en':
      return KppLocalizationsEn();
    case 'es':
      return KppLocalizationsEs();
    case 'hi':
      return KppLocalizationsHi();
  }

  throw FlutterError(
    'KppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
