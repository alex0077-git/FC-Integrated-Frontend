// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fuselage';

  @override
  String get connectTagline => 'Connect to your drone to begin';

  @override
  String get start => 'Start';

  @override
  String get groundPlan => 'Ground Plan';

  @override
  String get kppTuning => 'K++ Tuning';

  @override
  String get language => 'Language';

  @override
  String currentLanguage(String name) {
    return 'Current language: $name';
  }

  @override
  String get langEnglish => 'English';

  @override
  String get langArabic => 'العربية';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langSpanish => 'Español';

  @override
  String get langHindi => 'हिन्दी';

  @override
  String get home => 'Home';

  @override
  String get takeoff => 'Takeoff';

  @override
  String get arm => 'Arm';

  @override
  String get disarm => 'Disarm';

  @override
  String get rtl => 'RTL';

  @override
  String get land => 'Land';

  @override
  String get landConfirmTitle => 'Land';

  @override
  String get landConfirmMessage => 'Land the drone now?';

  @override
  String takeoffConfirmMessage(String meters) {
    return 'Arm (if needed) and take off to $meters m on the live aircraft?';
  }

  @override
  String get armConfirmMessage => 'Arm the live drone?';

  @override
  String get disarmConfirmMessage => 'Disarm the live drone?';

  @override
  String get rtlConfirmMessage => 'Return to launch now?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get boundaries => 'Boundaries';

  @override
  String get split => 'Split';

  @override
  String get obstacles => 'Obstacles';

  @override
  String get waypoints => 'Waypoints';

  @override
  String get history => 'History';

  @override
  String get username => 'Username';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get units => 'Units';

  @override
  String get unitsMetric => 'Metric';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get mapStyle => 'Map style';

  @override
  String get mapStreet => 'Street';

  @override
  String get mapSatellite => 'Satellite';

  @override
  String get mapDigitalSky => 'Digital Sky';

  @override
  String get kppTuningTitle => 'K++ tuning';

  @override
  String get kppTuningSubtitle => 'Full flight-controller assistant';

  @override
  String get about => 'About';

  @override
  String get appTagline => 'Fly, plan missions, and tune K++ — one app.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get battery => 'Battery';

  @override
  String get flightParameters => 'Flight Parameters';

  @override
  String get firstWarningThreshold => 'First Warning Threshold (%)';

  @override
  String get secondWarningThreshold => 'Second Warning Threshold (%)';

  @override
  String get criticalBatteryLevel => 'Critical Battery Level (%)';

  @override
  String get maxVoltage => 'Max Voltage';

  @override
  String get minVoltage => 'Min Voltage';

  @override
  String get lowVoltageThreshold => 'Low-Voltage Threshold';

  @override
  String get criticalVoltageThreshold => 'Critical-Voltage Threshold';

  @override
  String get cellCount => 'Cell Count';

  @override
  String get calibrateBatteryOnKpp => 'Calibrate Battery on K++';

  @override
  String get maxYawRate => 'Max Yaw Rate';

  @override
  String get maxRollAngle => 'Max Roll Angle';

  @override
  String get maxPitchAngle => 'Max Pitch Angle';

  @override
  String get maxSpeed => 'Max Speed';

  @override
  String get cruiseSpeed => 'Cruise Speed';

  @override
  String get saveMission => 'Save Mission';

  @override
  String get loadMission => 'Load Mission';

  @override
  String get uploadMission => 'Upload Mission';

  @override
  String get callForJob => 'Call for Job';

  @override
  String get uploadAndFly => 'Upload & fly';

  @override
  String get uploadAndStart => 'Upload & start';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get reset => 'Reset';

  @override
  String get save => 'Save';

  @override
  String get heroImageLabel => 'Fuselage Hero Image';

  @override
  String get logoImageLabel => 'Fuselage Logo';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get connect => 'Connect';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String gpsStatus(String fix, String sats) {
    return 'GPS $fix · $sats sats';
  }

  @override
  String get gpsUnknown => 'GPS --';

  @override
  String get modeUnknown => 'Mode --';

  @override
  String get calibration => 'Calibration';

  @override
  String get kppTuningFull => 'K++ tuning (full assistant)';

  @override
  String get kppTuningFullSubtitle => 'Status, sensors, gains, logs, firmware…';

  @override
  String get batteryCritical => 'Battery critical';

  @override
  String get batteryLow => 'Battery low';

  @override
  String get altitude => 'Altitude';

  @override
  String get distanceToDrone => 'Distance to Drone';

  @override
  String get distanceToLanding => 'Distance to Landing Point';

  @override
  String get speed => 'Speed';

  @override
  String get drawBoundaryBeforeSplit =>
      'Draw at least three boundary points before splitting.';

  @override
  String get firstPoint => 'First Point';

  @override
  String get endPoint => 'End Point';

  @override
  String get undoSplit => 'Undo split';

  @override
  String get selectSplitA => 'Select Split A';

  @override
  String get selectSplitB => 'Select Split B';

  @override
  String get setA => 'Set A';

  @override
  String get setB => 'Set B';

  @override
  String get missionSpray => 'Spray';

  @override
  String get missionSurvey => 'Survey';

  @override
  String get missionManual => 'Manual';

  @override
  String waypointsCount(int count) {
    return 'Waypoints ($count)';
  }

  @override
  String get noWaypointsYet => 'No waypoints yet';

  @override
  String get waypointDetail => 'Waypoint detail';

  @override
  String get selectWaypoint => 'Select a waypoint';

  @override
  String get waypoint => 'Waypoint';

  @override
  String get loiter => 'Loiter';

  @override
  String get cropRice => 'Rice';

  @override
  String get cropWheat => 'Wheat';

  @override
  String get cropOther => 'Other';

  @override
  String get connectLiveKpp => 'Connect live K++';

  @override
  String get usbGround => 'USB (ground)';

  @override
  String get comPort => 'COM port';

  @override
  String get noComPort => 'No COM port';

  @override
  String get refreshComPorts => 'Refresh COM ports';

  @override
  String get baud => 'Baud';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connectUsbToKpp => 'Connect USB to K++';

  @override
  String get transmitterBtWifi => 'Transmitter (Bluetooth / WiFi)';

  @override
  String get airbornePath => 'Airborne path — App → transmitter → aircraft';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'WiFi';

  @override
  String get bluetoothTransmitter => 'Bluetooth transmitter';

  @override
  String get noBluetoothPort => 'No Bluetooth port';

  @override
  String get refreshBluetoothPorts => 'Refresh Bluetooth ports';

  @override
  String get showAllComPorts => 'Show all COM ports';

  @override
  String get showAllComPortsHint =>
      'Use if your TX paired but is not listed as Bluetooth';

  @override
  String get connectTransmitterBt => 'Connect transmitter (Bluetooth)';

  @override
  String get disconnectTransmitter => 'Disconnect transmitter';

  @override
  String get g20Preset => 'G20 preset';

  @override
  String get useGatewayIp => 'Use gateway IP';

  @override
  String get refreshNetwork => 'Refresh network';

  @override
  String get wifiMode => 'WiFi mode';

  @override
  String get wifiModeTcp => 'TCP to transmitter AP';

  @override
  String get wifiModeUdp => 'UDP to transmitter';

  @override
  String get wifiModeUdpListen => 'UDP listen (GCS port)';

  @override
  String get hostIp => 'Host / IP';

  @override
  String get remotePort => 'Remote port';

  @override
  String get localPort => 'Local port';

  @override
  String get connectTransmitterWifi => 'Connect transmitter (WiFi)';

  @override
  String get autoTryWifi => 'Auto-try WiFi';

  @override
  String get phoneLandscapeTitle => 'Rotate to landscape';

  @override
  String get phoneLandscapeBody =>
      'This app is designed for landscape orientation.';

  @override
  String get returnToLaunch => 'Return to launch';

  @override
  String get lineSpacing => 'Line spacing';

  @override
  String get coverageAdjust => 'Coverage adjust';

  @override
  String get obstacleCircle => 'Circle';

  @override
  String get obstaclePolygon => 'Polygon';

  @override
  String get addObstacle => 'Add obstacle';

  @override
  String get deleteObstacle => 'Delete obstacle';

  @override
  String get planHistory => 'Plan history';

  @override
  String get imuCalibration => 'IMU Calibration';

  @override
  String get compassCalibration => 'Compass Calibration';

  @override
  String get accelCalibration => 'Accelerometer Calibration';

  @override
  String get levelHorizon => 'Level Horizon';

  @override
  String get startCalibration => 'Start';

  @override
  String get stopCalibration => 'Stop';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get mapAttributionEsri => 'Tiles © Esri (imagery + place labels)';

  @override
  String get mapAttributionOsm => '© OpenStreetMap contributors';

  @override
  String get digitalSkyEmbedBlocked =>
      'Digital Sky will not open inside this app. Their site blocks other websites from showing the map.';

  @override
  String get digitalSkyDidNotLoad => 'Digital Sky did not load';

  @override
  String get openDigitalSky => 'Open Digital Sky';

  @override
  String get openDigitalSkyInBrowser => 'Open Digital Sky in browser';

  @override
  String get calibrationRadio => 'Radio';

  @override
  String get calibrationImu => 'IMU';

  @override
  String get calibrationCompass => 'Compass';

  @override
  String get calibrationStatusCalibrating => 'Calibrating...';

  @override
  String get calibrationStatusCalibrated => 'Calibrated';

  @override
  String get calibrationStatusNotCalibrated => 'Not calibrated';

  @override
  String get startCalibrationFull => 'Start Calibration';

  @override
  String connectLiveLink(String link) {
    return 'Live link: $link';
  }

  @override
  String get connectUsbIntro =>
      'USB for ground setup. For flying, connect the app to the transmitter over Bluetooth or WiFi — commands go App → TX → aircraft.';

  @override
  String get connectWebUnsupported =>
      'This web build cannot open USB, Bluetooth, or WiFi sockets. Run the Windows or Android app.';

  @override
  String get transmitterPickHint =>
      'Pick Bluetooth or WiFi depending on your transmitter. USB above is unchanged for ground setup.';

  @override
  String get btAbbrev => 'BT';

  @override
  String get transmitterIpHost => 'Transmitter IP / host';

  @override
  String get tcpPort => 'TCP port';

  @override
  String get remoteUdpPort => 'Remote UDP port';

  @override
  String get localUdpPort => 'Local UDP port';

  @override
  String get tryingWifiPorts => 'Trying ports…';

  @override
  String get autoTryWifiPorts => 'Auto-try WiFi ports';

  @override
  String loadingParameters(int received, int total) {
    return 'Loading parameters $received/$total';
  }

  @override
  String get linkLostTransmitter =>
      'Link lost — check transmitter power, Bluetooth/WiFi, and range.';

  @override
  String get linkLostUsb => 'Link lost — check the USB cable and FC power.';

  @override
  String get connectLiveHint =>
      'USB: plug into the FC on the ground. Flying: connect this app to the transmitter (Bluetooth or WiFi); commands and telemetry go through the TX to the aircraft. Keep the RC sticks for manual override.';

  @override
  String get connectErrorUsbNeedsNative =>
      'Live K++ USB needs the Windows or Android build — web cannot open serial ports.';

  @override
  String get connectErrorNoComPort =>
      'No COM port found. Plug the K++ USB data cable in and refresh.';

  @override
  String connectErrorInvalidPort(String label) {
    return 'Enter a valid $label (1–65535).';
  }

  @override
  String get connectErrorBluetoothNeedsNative =>
      'Bluetooth needs the Windows or Android desktop/mobile build.';

  @override
  String get connectErrorNoBluetoothSerial =>
      'No Bluetooth serial port found. Pair the transmitter in system Bluetooth settings, then tap Refresh. If it still missing, enable “Show all COM ports”.';

  @override
  String get connectErrorWifiNeedsNative =>
      'Transmitter WiFi needs the Windows or Android build.';

  @override
  String get connectErrorEnterTxHost =>
      'Enter the transmitter WiFi IP / hostname.';

  @override
  String get connectErrorNoWifiGateway =>
      'No WiFi gateway found. Join the transmitter WiFi first.';

  @override
  String connectUsingGateway(String gateway) {
    return 'Using gateway $gateway — tap Connect transmitter (WiFi).';
  }

  @override
  String get connectWifiJoinFirst =>
      'Join transmitter WiFi first, then try again.';

  @override
  String connectWifiTcpSuccess(String host, String port) {
    return 'Connected over TX WiFi TCP $host:$port';
  }

  @override
  String get connectWifiG20Success =>
      'Connected to Skydroid G20 TCP 192.168.43.1:5760';

  @override
  String get connectWifiUdpListenSuccess =>
      'Listening UDP 14550 — power the TX/aircraft so it sends telemetry.';

  @override
  String connectWifiAutoTryFailed(String detail) {
    return 'WiFi auto-try failed.\n$detail\n\nFor Skydroid G20: WiFi mode = TCP, IP 192.168.43.1, port 5760. On the G20 turn on WLAN hotspot and data-transmission sharing; aircraft + GR01 must be linked (baud match on FC telem port).';
  }

  @override
  String get rtlCommandConfirm => 'Command the live drone to return to launch?';

  @override
  String get connectUsbToKppFirst => 'Connect USB to K++ first';

  @override
  String get noFlyZone => 'No-Fly Zone';

  @override
  String get orientation => 'Orientation';

  @override
  String get autoAlign => 'Auto-align';

  @override
  String get edgeMargin => 'Edge margin';

  @override
  String get operationMode => 'Operation Mode';

  @override
  String get sprayOn => 'Spray on';

  @override
  String get sprayOff => 'Spray off';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get action => 'Action';

  @override
  String get selectCrop => 'Select Crop';

  @override
  String get sprayRate => 'Spray Rate';

  @override
  String get notes => 'Notes';

  @override
  String get name => 'Name';

  @override
  String get defaultMissionName => 'Mission';

  @override
  String uploadFlyConfirmMessage(int count, String meters) {
    return 'Upload $count waypoints to the live K++, arm if needed, and start Auto (takeoff $meters m)?';
  }

  @override
  String get missionUploadedSuccess =>
      'Mission uploaded — saved locally and Auto started on live K++';

  @override
  String get missionSavedToDatabase => 'Mission saved to database';

  @override
  String get noSavedMissions => 'No saved missions';

  @override
  String get connectKppUsbFirst => 'Connect a live K++ over USB first';

  @override
  String get enterMeterVoltageInMaxVoltage =>
      'Enter a meter voltage in Max Voltage';

  @override
  String get battVoltMultWritten => 'BATT_VOLT_MULT written to live K++';

  @override
  String savedLocallyFcSyncFailed(String error) {
    return 'Saved locally; FC sync failed: $error';
  }

  @override
  String get mapHintTapPlacePointA => 'Tap the map to place point A';

  @override
  String get mapHintTapPlacePointB => 'Tap the map to place point B';

  @override
  String get mapHintTapBoundaryForSplit =>
      'Tap the boundary for the selected point';

  @override
  String get mapHintTapAddBoundaryPoint =>
      'Tap the map to add a boundary point';

  @override
  String get splitChoosePointsHint =>
      'Choose First Point or End Point, then tap a boundary point or anywhere along the boundary.';

  @override
  String get chooseCircleOrPolygon => 'Choose Circle or Polygon';

  @override
  String get tapInsideFieldPlaceCircle =>
      'Tap inside the field to place the circle.';

  @override
  String get tapMapPlaceCornersInOrder =>
      'Tap the map to place each corner, in order.';
}
