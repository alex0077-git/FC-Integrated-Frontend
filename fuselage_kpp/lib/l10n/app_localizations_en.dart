// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class KppLocalizationsEn extends KppLocalizations {
  KppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fuselage-K++';

  @override
  String get groupBasic => 'Basic';

  @override
  String get groupAdvanced => 'Advanced';

  @override
  String get groupTools => 'Tools';

  @override
  String get groupFly => 'Fly';

  @override
  String get destOverview => 'Status';

  @override
  String get destInstallation => 'Installation';

  @override
  String get destRemoteControl => 'Remote control';

  @override
  String get destSensors => 'Sensors';

  @override
  String get destFlight => 'Motors & flight';

  @override
  String get destGains => 'Gains';

  @override
  String get destProtection => 'Protection';

  @override
  String get destPump => 'Pump';

  @override
  String get destLiquid => 'Liquid level';

  @override
  String get destSpraying => 'AB spraying';

  @override
  String get destFence => 'Fence';

  @override
  String get destExtensions => 'Extensions';

  @override
  String get destChannels => 'Channel mapping';

  @override
  String get destMission => 'Mission';

  @override
  String get destLogs => 'Flight logs';

  @override
  String get destParameters => 'All parameters';

  @override
  String get destFirmware => 'Firmware & about';

  @override
  String get mapFly => 'Map / fly';

  @override
  String get groundPlan => 'Ground plan';

  @override
  String get home => 'Home';

  @override
  String get language => 'Language';

  @override
  String get overviewDescription =>
      'Live health of the flight controller and its modules (K++ assistant layout).';

  @override
  String get sensors => 'Sensors';

  @override
  String get imu => 'IMU';

  @override
  String get gps => 'GPS';

  @override
  String get gps1 => 'GPS1';

  @override
  String get gps1Sats => 'GPS1 sats';

  @override
  String get gps2 => 'GPS2';

  @override
  String get gps2Sats => 'GPS2 sats';

  @override
  String get position => 'Position';

  @override
  String get altitude => 'Altitude';

  @override
  String get hdop => 'HDOP';

  @override
  String get powerAndLink => 'Power & link';

  @override
  String get batteryVoltage => 'Battery voltage';

  @override
  String get rcSignal => 'RC signal';

  @override
  String get link => 'Link';

  @override
  String get firmwareVersion => 'Firmware version';

  @override
  String get softwareRevision => 'Software revision';

  @override
  String get parameters => 'Parameters';

  @override
  String get fcMessage => 'Flight controller message';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusFault => 'Fault';

  @override
  String get statusNotConnected => 'Not connected';

  @override
  String get port => 'Port';

  @override
  String get baud => 'Baud';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'WiFi';

  @override
  String get refreshComPorts => 'Refresh COM ports';

  @override
  String get refreshBluetoothPorts => 'Refresh Bluetooth ports';

  @override
  String get setMode => 'Set mode';

  @override
  String get flightModeAuto => 'Auto';

  @override
  String get flightModeGuided => 'Guided';

  @override
  String get flightModeLoiter => 'Loiter';

  @override
  String get flightModeRtl => 'RTL';

  @override
  String get flightModeLand => 'Land';

  @override
  String get defaultAlt => 'Default alt';

  @override
  String get abSpray => 'AB spray';

  @override
  String get download => 'Download';

  @override
  String get upload => 'Upload';

  @override
  String get clear => 'Clear';

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get altitudeM => 'Altitude (m)';

  @override
  String missionItemsHint(int count) {
    return '$count items — tap map to add waypoints';
  }

  @override
  String get setA => 'Set A';

  @override
  String get setB => 'Set B';

  @override
  String get tapMapForFence => 'Tap map for fence…';

  @override
  String get enableCircleFence => 'Enable circle fence';

  @override
  String get editAltitude => 'Edit altitude';

  @override
  String get missionDownloaded => 'Mission downloaded';

  @override
  String get missionUploaded => 'Mission uploaded';

  @override
  String get missionCleared => 'Mission cleared';

  @override
  String get rtlAccepted => 'RTL accepted';

  @override
  String get landAccepted => 'Land accepted';

  @override
  String modeSet(String mode) {
    return 'Mode $mode set';
  }

  @override
  String get setPointsAbFirst => 'Set points A and B on the map first';

  @override
  String abSprayGenerated(int count) {
    return 'AB spray pattern generated ($count items)';
  }

  @override
  String fenceCircleEnabled(String radius) {
    return 'Circle fence enabled, radius $radius m (centred on aircraft when flying)';
  }

  @override
  String exportedTo(String path) {
    return 'Exported $path';
  }

  @override
  String importedItems(int count) {
    return 'Imported $count items';
  }

  @override
  String get rtl => 'RTL';

  @override
  String get land => 'Land';

  @override
  String get armed => 'ARMED';

  @override
  String get disarmed => 'Disarmed';

  @override
  String get notConnected => 'Not connected';

  @override
  String get notConnectedHint =>
      'Connect the flight controller first (USB or transmitter BT/WiFi) in the bar above, then press Connect. Plugging in the GPS puck alone is not enough.';

  @override
  String get cardFrameType => 'Frame type';

  @override
  String get frameTypeSubtitle =>
      'Same as K++ assistant: yellow arm = nose, M1–M8 = FC ports, red CW / blue CCW = propeller spin. Writes FRAME and SHAPE.';

  @override
  String get cardImuGpsMounting => 'IMU & GPS mounting';

  @override
  String get installationDescription =>
      'Choose directions to match how the modules are mounted, and enter their offsets from the airframe\'s centre of gravity in centimetres (blue zone negative, yellow zone positive).';

  @override
  String get remoteControlDescription =>
      'To make sure the failsafe is set correctly, switch the RC off after changing it and check that channels 1–4 jump to centre (about 1500) and channel 5 jumps to its failsafe position.';

  @override
  String get cardRcSettingsFailsafe => 'RC settings & failsafe';

  @override
  String get stickCalibration => 'Stick calibration';

  @override
  String get stickCalibrationIdle =>
      'Current endpoints are shown below. Start to recalibrate channels 1–4.';

  @override
  String get stickCalibrationExtremes =>
      'Push every stick to its maximum and minimum several times, then press Next.';

  @override
  String get stickCalibrationCentre =>
      'Release every stick to the centre, then press Capture centre.';

  @override
  String get stickCalibrationReview =>
      'Check the results, then save them to the flight controller.';

  @override
  String get startCalibration => 'Start calibration';

  @override
  String get captureCentre => 'Capture centre';

  @override
  String get saveCalibration => 'Save calibration';

  @override
  String get next => 'Next';

  @override
  String get channel => 'Channel';

  @override
  String get min => 'Min';

  @override
  String get centre => 'Centre';

  @override
  String get max => 'Max';

  @override
  String get channelMonitor => 'Channel monitor';

  @override
  String get sensorsImuCompassSubtitle =>
      'Raw sensor values from each IMU instance.';

  @override
  String get cardImuCompass => 'IMU & compass';

  @override
  String get cardBarometer => 'Barometer';

  @override
  String get noBarometerData => 'No barometer data';

  @override
  String get imuLevelCalibration => 'IMU level calibration';

  @override
  String get imuLevelCalibrationSubtitle =>
      'Place the flight controller face up and level, then calibrate.';

  @override
  String get compassCalibration => 'Compass calibration';

  @override
  String get compassCalibrationSubtitle =>
      'Rotate the aircraft level and clockwise, then nose-down and clockwise.';

  @override
  String get cardGlobalFlightLimits => 'Global flight limits & motor idle';

  @override
  String get motorTest => 'Motor test';

  @override
  String get motorTestSubtitle =>
      'Spins each motor individually to check order and direction.';

  @override
  String get removePropellers => 'Remove propellers';

  @override
  String get startTest => 'Start test';

  @override
  String motorTestConfirmMessage(int motor, String throttle, String seconds) {
    return 'Motor test will spin M$motor at $throttle% for $seconds s.\nConfirm propellers are removed and the aircraft is secured.';
  }

  @override
  String get testingMotors => 'Testing…';

  @override
  String get testMotors => 'Test motors';

  @override
  String get calibrateImu => 'Calibrate IMU';

  @override
  String get calibratingImu => 'Calibrating…';

  @override
  String get calibrateCompass => 'Calibrate compass';

  @override
  String get calibratingCompass => 'Calibrating…';

  @override
  String get gainsDescription =>
      'Control gains set the pilot\'s feel: higher values respond faster but need more power. Only move the performance tendency towards vibration suppression if the airframe visibly shakes or the motors sound noisy.';

  @override
  String protectionDescription(String voltage) {
    return 'Current voltage: $voltage. Level 2 must be lower than level 1; both levels also flash the lights.';
  }

  @override
  String barometerReading(String pressure, String temperature) {
    return 'Pressure $pressure hPa   ·   Temperature $temperature °C';
  }

  @override
  String get cardBasicGains => 'Basic gains';

  @override
  String get cardControlGains => 'Control gains';

  @override
  String get cardSpeedSensitivity => 'Speed & sensitivity';

  @override
  String get cardVoltageRtlLanding => 'Voltage, return home & landing';

  @override
  String get voltageCalibration => 'Voltage calibration';

  @override
  String get voltageCalibrationSubtitle =>
      'Enter the voltage measured with a meter so the FC reading matches it.';

  @override
  String get meterVoltageV => 'Meter voltage (V)';

  @override
  String get calibrateVoltage => 'Calibrate voltage';

  @override
  String get cardPump => 'Pump';

  @override
  String get cardLevelSensorProtection => 'Level sensor & protection';

  @override
  String get cardAbJobSettings => 'AB job settings';

  @override
  String get cardAbJobProcedure => 'AB job procedure';

  @override
  String get fenceDescription =>
      'Circle and altitude limits. Draw/adjust the circle from the Mission map, or set values here.';

  @override
  String get cardQuickFence => 'Quick fence';

  @override
  String get fenceEnabled => 'Fence is enabled';

  @override
  String get fenceOff => 'Fence is off';

  @override
  String get enableAltitudeAndCircle => 'Enable altitude + circle';

  @override
  String get disableFence => 'Disable fence';

  @override
  String get cardHeightDistanceLimits => 'Height & distance limits';

  @override
  String get cardRtkAntenna => 'RTK antenna';

  @override
  String rtkCurrentPositioning(String fix) {
    return 'Current positioning: $fix';
  }

  @override
  String get cardRadarVision4g => 'Radar, vision & 4G module status';

  @override
  String get extensionsRadarStatusDescription =>
      'Terrain-following radar height, obstacle radar distance, vision module state and the IoT SIM status are shown here in the K++ assistant.';

  @override
  String get channelsDescription =>
      'Check the channel monitor to see which channels your RC uses before assigning functions.';

  @override
  String get cardChannelFunctions => 'Channel functions';

  @override
  String get flightLogsDescription =>
      'Downloaded logs are saved to Documents\\Fuselage-K++\\logs.';

  @override
  String get refreshList => 'Refresh list';

  @override
  String logsOnFlightController(int count) {
    return '$count logs on the flight controller';
  }

  @override
  String parametersDescription(int count) {
    return '$count parameters read from the flight controller.';
  }

  @override
  String get parameterFiles => 'Parameter files';

  @override
  String get reloadFromFc => 'Reload from FC';

  @override
  String get searchByIdOrName => 'Search by id or name';

  @override
  String parametersShown(int count) {
    return '$count shown';
  }

  @override
  String get paramColumnId => 'Id';

  @override
  String get paramColumnName => 'Name';

  @override
  String get paramColumnValue => 'Value';

  @override
  String get paramFormHint =>
      'Type a value and press Enter to write it to the flight controller.';

  @override
  String get paramNotReported => 'Not reported by this flight controller';

  @override
  String paramUnknownOption(String value) {
    return 'Unknown ($value)';
  }

  @override
  String get enterNumber => 'Enter a number';

  @override
  String get writeToFlightControllerTitle => 'Write to flight controller?';

  @override
  String get write => 'Write';

  @override
  String get cardVersions => 'Versions';

  @override
  String get cardVersionsAuthorisation => 'Versions & authorisation';

  @override
  String get firmwareUpgrade => 'Firmware upgrade';

  @override
  String get firmwareUpgradeDescription =>
      'Upload K++ V2 / KX / P3 firmware through the flight controller bootloader. Never remove the device while upgrading.';

  @override
  String get upgradeFirmware => 'Upgrade firmware';

  @override
  String get factoryReset => 'Factory reset';

  @override
  String get factoryResetDescription =>
      'Restore every parameter to the factory defaults.';

  @override
  String get restoreFactorySettings => 'Restore factory settings';

  @override
  String get droneRegistration => 'Drone registration';

  @override
  String get droneRegistrationDescription =>
      'Manufacturer name, aircraft model and aircraft number (网络备案).';

  @override
  String get shape => 'Shape';

  @override
  String validateMinimum(String value) {
    return 'Minimum is $value';
  }

  @override
  String validateMaximum(String value) {
    return 'Maximum is $value';
  }

  @override
  String get validateChooseOption => 'Choose one of the listed options';

  @override
  String get instance => 'Instance';

  @override
  String get accelAxes => 'Accel X / Y / Z';

  @override
  String get gyroAxes => 'Gyro X / Y / Z';

  @override
  String get compassAxes => 'Compass X / Y / Z';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get channelMonitorNoData => 'No RC data received yet.';

  @override
  String get channelMonitorHint =>
      'Move the sticks and switches to see each channel.';

  @override
  String duplicateChannelFunctions(String details) {
    return 'Duplicate channel functions: $details';
  }

  @override
  String get logColumnNo => 'No.';

  @override
  String get logColumnTimeUtc => 'Time (UTC)';

  @override
  String get logColumnSizeBytes => 'Size (bytes)';

  @override
  String get logReview => 'Review';

  @override
  String logSavedTo(int id, String path) {
    return 'Log $id saved to $path';
  }

  @override
  String motorThrottlePercent(String percent) {
    return 'Throttle $percent %';
  }

  @override
  String motorDurationSeconds(String seconds) {
    return 'Duration $seconds s';
  }

  @override
  String motorTestAccepted(int motor) {
    return 'Motor M$motor test accepted';
  }

  @override
  String motorTestFailed(String error) {
    return 'Motor test failed: $error';
  }

  @override
  String get imuCalibrationAccepted => 'IMU calibration accepted';

  @override
  String imuCalibrationFailed(String error) {
    return 'IMU calibration failed: $error';
  }

  @override
  String get compassCalibrationStarted => 'Compass calibration started';

  @override
  String compassCalibrationFailed(String error) {
    return 'Compass calibration failed: $error';
  }

  @override
  String paramSaved(String id, String value) {
    return '$id saved: $value';
  }

  @override
  String paramNotSaved(String id, String error) {
    return '$id not saved: $error';
  }

  @override
  String paramsSavedCount(int count) {
    return '$count parameters saved';
  }

  @override
  String paramsSavedPartial(int saved, int failed, String ids) {
    return '$saved saved, $failed failed: $ids';
  }

  @override
  String stickCalibrationInvalid(String channels) {
    return 'Channel min/max out of range: $channels. Calibration failed — try again.';
  }

  @override
  String fcReadingAndMultiplier(String reading, String mult) {
    return 'FC reading: $reading   ·   multiplier: $mult';
  }

  @override
  String get enterValidMeterVoltage => 'Enter a valid meter voltage';

  @override
  String get noBatteryVoltageYet =>
      'No battery voltage from the flight controller yet';

  @override
  String logParseFailed(String error) {
    return 'Could not parse log: $error';
  }

  @override
  String get logParseFailedHint =>
      'Open the .bin externally for full analysis.';

  @override
  String get logNoTrackSamples => 'No GPS/ATT samples recognised in this log.';

  @override
  String get plotNoSamples => 'No samples';

  @override
  String plotMinMax(String min, String max) {
    return 'min $min  ·  max $max';
  }

  @override
  String exportParametersTo(int count, String path) {
    return 'Exported $count parameters to $path';
  }

  @override
  String importFileFormatError(String message) {
    return 'File format error: $message';
  }

  @override
  String get importNothingMatches =>
      'Nothing to import: every value already matches the flight controller.';

  @override
  String fcFirmwareInfo(String version) {
    return 'Flight controller firmware: $version';
  }

  @override
  String get appAboutLine =>
      'Fuselage-K++ 1.0.0 — built to replace the JIYI K++ assistant (JIYI221014).';

  @override
  String get sprayProcedure1Title => 'Record point A';

  @override
  String get sprayProcedure1Detail =>
      'Flip the AB record switch to the middle position.';

  @override
  String get sprayProcedure2Title => 'Record point B';

  @override
  String get sprayProcedure2Detail =>
      'Flip the AB record switch to the high position.';

  @override
  String get sprayProcedure3Title => 'Start the AB job';

  @override
  String get sprayProcedure3Detail =>
      'Turn on the AB execute switch (or set AB execute as a flight mode).';

  @override
  String get sprayProcedure4Title => 'Choose direction';

  @override
  String get sprayProcedure4Detail =>
      'Push the roll stick towards the side to work.';

  @override
  String get sprayProcedure5Title => 'Clear A and B';

  @override
  String get sprayProcedure5Detail =>
      'Flip the AB record switch back and forth quickly.';

  @override
  String get sprayProcedure6Title => 'Resume after refill';

  @override
  String get sprayProcedure6Detail =>
      'Without clearing A/B, turn on AB execute: the job resumes from the last empty-tank point and direction.';

  @override
  String get waitingForProtocolConfirmation =>
      'Waiting for protocol confirmation';

  @override
  String get pendingFeatureBody =>
      'The K++ assistant uses a JIYI-specific command for this, not standard MAVLink. It stays disabled until a recording of the original app confirms the exact message, so nothing unverified is ever sent to the flight controller.';

  @override
  String get optForward => 'Forward';

  @override
  String get optRight => 'Right';

  @override
  String get optBackward => 'Backward';

  @override
  String get optLeft => 'Left';

  @override
  String get optOff => 'Off';

  @override
  String get optOn => 'On';

  @override
  String get optSinglePump => 'Single pump';

  @override
  String get optDoublePump => 'Double pump';

  @override
  String get optQuadX => 'Quad X';

  @override
  String get optQuadPlus => 'Quad +';

  @override
  String get optHexaX => 'Hexa X';

  @override
  String get optHexaPlus => 'Hexa +';

  @override
  String get optOctoX => 'Octo X';

  @override
  String get optOctoPlus => 'Octo +';

  @override
  String get optStandard => 'Standard';

  @override
  String get optCoaxial => 'Coaxial';

  @override
  String get optY6 => 'Y6';

  @override
  String get optAltitude => 'Altitude';

  @override
  String get optAltitudeCircle => 'Altitude + circle';

  @override
  String get optCircle => 'Circle';

  @override
  String get pLabel_FRAME => 'Frame type';

  @override
  String get pLabel_SHAPE => 'Frame shape';

  @override
  String get pLabel_NAV_IMU_ORIENT => 'IMU direction';

  @override
  String get pLabel_NAV_COMP_ORIENT => 'GPS direction';

  @override
  String get pLabel_NAV_IMU_POS_X => 'IMU position X';

  @override
  String get pLabel_NAV_IMU_POS_Y => 'IMU position Y';

  @override
  String get pLabel_NAV_IMU_POS_Z => 'IMU position Z';

  @override
  String get pLabel_NAV_GPS3_POS_X => 'GPS position X';

  @override
  String get pLabel_NAV_GPS3_POS_Y => 'GPS position Y';

  @override
  String get pLabel_NAV_GPS3_POS_Z => 'GPS position Z';

  @override
  String get pLabel_NAV_IMU_SOURCE => 'IMU source';

  @override
  String get pLabel_RC_TYPE => 'RC type';

  @override
  String get pLabel_FS_THR_ENABLE => 'RC-loss failsafe action';

  @override
  String get pLabel_RC_FS_CONTINUE => 'Continue job when RC is lost';

  @override
  String get pLabel_THR_DZ => 'Throttle mid dead zone';

  @override
  String get pLabel_FLTMODE1 => 'Flight mode 1';

  @override
  String get pLabel_FLTMODE2 => 'Flight mode 2';

  @override
  String get pLabel_FLTMODE3 => 'Flight mode 3';

  @override
  String get pLabel_FLTMODE4 => 'Flight mode 4';

  @override
  String get pLabel_FLTMODE5 => 'Flight mode 5';

  @override
  String get pLabel_FLTMODE6 => 'Flight mode 6';

  @override
  String get pLabel_RC1_MIN => 'CH1 min';

  @override
  String get pLabel_RC1_MAX => 'CH1 max';

  @override
  String get pLabel_RC1_TRIM => 'CH1 trim';

  @override
  String get pLabel_RC2_MIN => 'CH2 min';

  @override
  String get pLabel_RC2_MAX => 'CH2 max';

  @override
  String get pLabel_RC2_TRIM => 'CH2 trim';

  @override
  String get pLabel_RC3_MIN => 'CH3 min';

  @override
  String get pLabel_RC3_MAX => 'CH3 max';

  @override
  String get pLabel_RC3_TRIM => 'CH3 trim';

  @override
  String get pLabel_RC4_MIN => 'CH4 min';

  @override
  String get pLabel_RC4_MAX => 'CH4 max';

  @override
  String get pLabel_RC4_TRIM => 'CH4 trim';

  @override
  String get pLabel_ANGLE_MAX => 'Max tilt angle';

  @override
  String get pLabel_WPNAV_LOIT_SPEED => 'Max horizontal speed';

  @override
  String get pLabel_PILOT_VELZ_UP => 'Max climb speed';

  @override
  String get pLabel_PILOT_VELZ_DOWN => 'Max descent speed';

  @override
  String get pLabel_MOT_SPIN_ARMED => 'Motor idle speed';

  @override
  String get pLabel_GAIN_BASIC_R_PI => 'Roll correction';

  @override
  String get pLabel_GAIN_BASIC_R_D => 'Roll damping';

  @override
  String get pLabel_GAIN_BASIC_P_PI => 'Pitch correction';

  @override
  String get pLabel_GAIN_BASIC_P_D => 'Pitch damping';

  @override
  String get pLabel_GAIN_BASIC_YAW => 'Yaw';

  @override
  String get pLabel_GAIN_BASIC_THR => 'Power (vertical)';

  @override
  String get pLabel_GAIN_CONTROL_RP => 'Roll / pitch';

  @override
  String get pLabel_GAIN_CONTROL_YAW => 'Yaw';

  @override
  String get pLabel_GAIN_CONTROL_THR => 'Vertical';

  @override
  String get pLabel_GAIN_CONTROL_WP => 'Route';

  @override
  String get pLabel_GAIN_CONTROL_MOV => 'Manoeuvre';

  @override
  String get pLabel_GAIN_CONTROL_BRA => 'Brake';

  @override
  String get pLabel_GAIN_CONTROL_SCA => 'Coordination';

  @override
  String get pLabel_GAIN_CONTROL_TKO => 'Take-off';

  @override
  String get pLabel_GAIN_VEL_XY => 'Horizontal speed gain';

  @override
  String get pLabel_GAIN_VEL_Z => 'Vertical speed gain';

  @override
  String get pLabel_GAIN_SEN_ATT => 'Attitude sensitivity';

  @override
  String get pLabel_GAIN_PERFORMANCE => 'Performance tendency';

  @override
  String get pLabel_FS_BATT_ENABLE => 'Low-voltage protection action';

  @override
  String get pLabel_FS_BATT_WARNING => 'Level 1 alarm voltage';

  @override
  String get pLabel_FS_BATT_VOLTAGE => 'Level 2 alarm voltage';

  @override
  String get pLabel_FS_PMU_ENABLE => 'PMU fault protection';

  @override
  String get pLabel_RTL_ALT => 'Return-home height';

  @override
  String get pLabel_LAND_SPEED => 'Landing speed';

  @override
  String get pLabel_SPRAY_PUMP_TYPE => 'Pump type';

  @override
  String get pLabel_LIQUID_TYPE => 'Level sensor type';

  @override
  String get pLabel_FS_LIQ_ENABLE => 'Out-of-liquid protection';

  @override
  String get pLabel_ABPOINT_DIS => 'AB swath width';

  @override
  String get pLabel_ABPOINT_SPEED => 'AB speed';

  @override
  String get pLabel_WPNAV_ENABLE_U => 'U-shaped side shift';

  @override
  String get pLabel_FENCE_ENABLE => 'Fence enable';

  @override
  String get pLabel_FENCE_TYPE => 'Fence type';

  @override
  String get pLabel_FENCE_ALT_MAX => 'Height limit';

  @override
  String get pLabel_FENCE_RADIUS => 'Distance limit (radius)';

  @override
  String get pLabel_FENCE_ACTION => 'Fence breach action';

  @override
  String get pLabel_RTK_ANTI_DEG => 'RTK antenna install angle';

  @override
  String get pLabel_CH6_OPT => 'Channel 6 function';

  @override
  String get pLabel_CH7_OPT => 'Channel 7 function';

  @override
  String get pLabel_CH8_OPT => 'Channel 8 function';

  @override
  String get pLabel_CH9_OPT => 'Channel 9 function';

  @override
  String get pLabel_CH10_OPT => 'Channel 10 function';

  @override
  String get pLabel_CH11_OPT => 'Channel 11 function';

  @override
  String get pLabel_CH12_OPT => 'Channel 12 function';

  @override
  String get pLabel_BATT_VOLT_MULT => 'Battery voltage multiplier';

  @override
  String get pLabel_FWVERSION => 'Firmware version';

  @override
  String get pLabel_SYSID_SW_MREV => 'Software revision';

  @override
  String get pLabel_INS_CAL_TYPE => 'IMU calibration state';

  @override
  String get pLabel_COMPASS_CAL_TYPE => 'Compass calibration state';

  @override
  String get pLabel_REG_ENABLE => 'App unlock authorised';

  @override
  String get helpBasicGain =>
      'Range 0–200 %. Adapts the controller to the airframe.';

  @override
  String get helpControlGain =>
      'Range 0–300 %. Higher = faster response; limited by the airframe\'s power.';

  @override
  String get helpMode =>
      'K++ options include Manual job, AB execute, Route job, GPS speed, Side shift and Terrain follow. Value mapping not yet confirmed.';

  @override
  String get helpChannel =>
      'Function assigned to this RC channel. Each function should be used once; check the channel monitor before changing.';

  @override
  String get help_0 =>
      'Motor count and layout written as FRAME on the K++ bus.';

  @override
  String get help_1 =>
      'Offset from the centre of gravity. Blue zone = negative, yellow zone = positive.';

  @override
  String get help_2 => 'Receiver protocol. Value mapping not yet confirmed.';

  @override
  String get help_3 =>
      'K++ options: Return home, Hover, Land, Hover then land. Value mapping not yet confirmed — test with the RC switched off after changing.';

  @override
  String get help_4 =>
      'In AB / route jobs the drone keeps working instead of running the failsafe. Recommended only with radar.';

  @override
  String get help_5 => 'Centidegrees: 3000 = 30°.';

  @override
  String get help_6 =>
      'K++ options: Disabled, Very slow, Slow, Medium, Very fast. Value mapping not yet confirmed.';

  @override
  String get help_7 =>
      'Acceleration in autonomous flight. Higher = faster speed changes.';

  @override
  String get help_8 => 'Acceleration under pilot control.';

  @override
  String get help_9 => 'Higher = shorter, harder automatic braking.';

  @override
  String get help_10 =>
      'Matches control response to manoeuvres; faster power systems need higher values.';

  @override
  String get help_11 => 'Higher = quicker, crisper take-off.';

  @override
  String get help_12 => 'Normally not adjusted.';

  @override
  String get help_13 => 'How quickly the FC follows stick input.';

  @override
  String get help_14 =>
      'K++ options: Balanced, Sport, Anti-vibration. Only move towards vibration suppression if the airframe visibly shakes. Value mapping not yet confirmed.';

  @override
  String get help_15 =>
      'K++ options: Off, Return home, Land (both levels also flash the lights). Value mapping not yet confirmed.';

  @override
  String get help_16 => 'Must be lower than the level 1 voltage.';

  @override
  String get help_17 =>
      'Single: pump ESC on P1. Double: ESCs on P1 and P2; P1 runs flying forward, P2 flying backward.';

  @override
  String get help_18 =>
      'K++ options: Not used, Switch sensor (FC port K2), Real-time level. Flow meter goes on port K1. Value mapping not yet confirmed.';

  @override
  String get help_19 =>
      'Action when the tank runs dry. Value mapping not yet confirmed.';

  @override
  String get help_20 =>
      'Scale factor used for voltage calibration (meter reading ÷ FC reading).';

  @override
  String get simulatorNoHardware => 'Simulator (no hardware)';

  @override
  String get hideTransmitter => 'Hide transmitter';

  @override
  String get showTransmitter => 'Transmitter BT/WiFi';

  @override
  String get btAbbrev => 'BT';

  @override
  String get noBtSerialRefresh => 'No BT serial port — pair TX then refresh';

  @override
  String get txWifiIp => 'TX WiFi IP';

  @override
  String get tcp => 'TCP';

  @override
  String get linkDisconnected => 'Disconnected';

  @override
  String get linkConnecting => 'Connecting…';

  @override
  String linkReadingParameters(int received, int total) {
    return 'Reading parameters $received/$total';
  }

  @override
  String linkConnected(String link) {
    return 'Connected · $link';
  }

  @override
  String linkLostStatus(String link) {
    return 'Link lost · $link';
  }

  @override
  String get sensorGyroscope => 'Gyroscope';

  @override
  String get sensorAccelerometer => 'Accelerometer';

  @override
  String get sensorCompass => 'Compass';

  @override
  String get sensorBarometer => 'Barometer';

  @override
  String get sensorGps => 'GPS';
}
