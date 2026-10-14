// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Fuselage';

  @override
  String get connectTagline =>
      'Verbinden Sie sich mit Ihrer Drohne, um zu beginnen';

  @override
  String get start => 'Start';

  @override
  String get groundPlan => 'Bodenplan';

  @override
  String get kppTuning => 'K++ Tuning';

  @override
  String get language => 'Sprache';

  @override
  String currentLanguage(String name) {
    return 'Aktuelle Sprache: $name';
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
  String get home => 'Startseite';

  @override
  String get takeoff => 'Starten';

  @override
  String get arm => 'Scharf';

  @override
  String get disarm => 'Entschärfen';

  @override
  String get rtl => 'RTL';

  @override
  String get land => 'Landen';

  @override
  String get landConfirmTitle => 'Landen';

  @override
  String get landConfirmMessage => 'Drohne jetzt landen?';

  @override
  String takeoffConfirmMessage(String meters) {
    return 'Scharf schalten (falls nötig) und auf $meters m starten?';
  }

  @override
  String get armConfirmMessage => 'Live-Drohne scharf schalten?';

  @override
  String get disarmConfirmMessage => 'Live-Drohne entschärfen?';

  @override
  String get rtlConfirmMessage => 'Jetzt zum Startpunkt zurückkehren?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get boundaries => 'Grenzen';

  @override
  String get split => 'Teilen';

  @override
  String get obstacles => 'Hindernisse';

  @override
  String get waypoints => 'Wegpunkte';

  @override
  String get history => 'Verlauf';

  @override
  String get username => 'Benutzername';

  @override
  String get theme => 'Thema';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get units => 'Einheiten';

  @override
  String get unitsMetric => 'Metrisch';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get mapStyle => 'Kartenstil';

  @override
  String get mapStreet => 'Straße';

  @override
  String get mapSatellite => 'Satellit';

  @override
  String get mapDigitalSky => 'Digital Sky';

  @override
  String get kppTuningTitle => 'K++ Tuning';

  @override
  String get kppTuningSubtitle => 'Vollständiger Flugregler-Assistent';

  @override
  String get about => 'Über';

  @override
  String get appTagline =>
      'Fliegen, Missionen planen und K++ tunen — eine App.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get battery => 'Batterie';

  @override
  String get flightParameters => 'Flugparameter';

  @override
  String get firstWarningThreshold => 'Erste Warnschwelle (%)';

  @override
  String get secondWarningThreshold => 'Zweite Warnschwelle (%)';

  @override
  String get criticalBatteryLevel => 'Kritischer Batteriestand (%)';

  @override
  String get maxVoltage => 'Max. Spannung';

  @override
  String get minVoltage => 'Min. Spannung';

  @override
  String get lowVoltageThreshold => 'Niederspannungsschwelle';

  @override
  String get criticalVoltageThreshold => 'Kritische Spannungsschwelle';

  @override
  String get cellCount => 'Zellenzahl';

  @override
  String get calibrateBatteryOnKpp => 'Batterie an K++ kalibrieren';

  @override
  String get maxYawRate => 'Max. Gierrate';

  @override
  String get maxRollAngle => 'Max. Rollwinkel';

  @override
  String get maxPitchAngle => 'Max. Nickwinkel';

  @override
  String get maxSpeed => 'Max. Geschwindigkeit';

  @override
  String get cruiseSpeed => 'Reisegeschwindigkeit';

  @override
  String get saveMission => 'Mission speichern';

  @override
  String get loadMission => 'Mission laden';

  @override
  String get uploadMission => 'Mission hochladen';

  @override
  String get callForJob => 'Auftrag anfordern';

  @override
  String get uploadAndFly => 'Hochladen & fliegen';

  @override
  String get uploadAndStart => 'Hochladen & starten';

  @override
  String get undo => 'Rückgängig';

  @override
  String get redo => 'Wiederholen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get save => 'Speichern';

  @override
  String get heroImageLabel => 'Fuselage Hero-Bild';

  @override
  String get logoImageLabel => 'Fuselage Logo';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get connect => 'Verbinden';

  @override
  String get connected => 'Verbunden';

  @override
  String get disconnected => 'Getrennt';

  @override
  String gpsStatus(String fix, String sats) {
    return 'GPS $fix · $sats Sats';
  }

  @override
  String get gpsUnknown => 'GPS --';

  @override
  String get modeUnknown => 'Modus --';

  @override
  String get calibration => 'Kalibrierung';

  @override
  String get kppTuningFull => 'K++ Tuning (voller Assistent)';

  @override
  String get kppTuningFullSubtitle =>
      'Status, Sensoren, Gains, Logs, Firmware…';

  @override
  String get batteryCritical => 'Batterie kritisch';

  @override
  String get batteryLow => 'Batterie niedrig';

  @override
  String get altitude => 'Höhe';

  @override
  String get distanceToDrone => 'Abstand zur Drohne';

  @override
  String get distanceToLanding => 'Abstand zum Landepunkt';

  @override
  String get speed => 'Geschwindigkeit';

  @override
  String get drawBoundaryBeforeSplit =>
      'Zeichnen Sie mindestens drei Grenzpunkte vor dem Teilen.';

  @override
  String get firstPoint => 'Erster Punkt';

  @override
  String get endPoint => 'Endpunkt';

  @override
  String get undoSplit => 'Teilung rückgängig';

  @override
  String get selectSplitA => 'Teilung A wählen';

  @override
  String get selectSplitB => 'Teilung B wählen';

  @override
  String get setA => 'A setzen';

  @override
  String get setB => 'B setzen';

  @override
  String get missionSpray => 'Sprühen';

  @override
  String get missionSurvey => 'Vermessung';

  @override
  String get missionManual => 'Manuell';

  @override
  String waypointsCount(int count) {
    return 'Wegpunkte ($count)';
  }

  @override
  String get noWaypointsYet => 'Noch keine Wegpunkte';

  @override
  String get waypointDetail => 'Wegpunkt-Details';

  @override
  String get selectWaypoint => 'Wegpunkt wählen';

  @override
  String get waypoint => 'Wegpunkt';

  @override
  String get loiter => 'Kreisen';

  @override
  String get cropRice => 'Reis';

  @override
  String get cropWheat => 'Weizen';

  @override
  String get cropOther => 'Andere';

  @override
  String get connectLiveKpp => 'Live-K++ verbinden';

  @override
  String get usbGround => 'USB (Boden)';

  @override
  String get comPort => 'COM-Port';

  @override
  String get noComPort => 'Kein COM-Port';

  @override
  String get refreshComPorts => 'COM-Ports aktualisieren';

  @override
  String get baud => 'Baud';

  @override
  String get disconnect => 'Trennen';

  @override
  String get connectUsbToKpp => 'USB mit K++ verbinden';

  @override
  String get transmitterBtWifi => 'Sender (Bluetooth / WiFi)';

  @override
  String get airbornePath => 'Luftweg — App → Sender → Fluggerät';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'WiFi';

  @override
  String get bluetoothTransmitter => 'Bluetooth-Sender';

  @override
  String get noBluetoothPort => 'Kein Bluetooth-Port';

  @override
  String get refreshBluetoothPorts => 'Bluetooth-Ports aktualisieren';

  @override
  String get showAllComPorts => 'Alle COM-Ports anzeigen';

  @override
  String get showAllComPortsHint =>
      'Nutzen, wenn TX gekoppelt ist, aber nicht als Bluetooth gelistet';

  @override
  String get connectTransmitterBt => 'Sender verbinden (Bluetooth)';

  @override
  String get disconnectTransmitter => 'Sender trennen';

  @override
  String get g20Preset => 'G20-Voreinstellung';

  @override
  String get useGatewayIp => 'Gateway-IP nutzen';

  @override
  String get refreshNetwork => 'Netzwerk aktualisieren';

  @override
  String get wifiMode => 'WiFi-Modus';

  @override
  String get wifiModeTcp => 'TCP zum Sender-AP';

  @override
  String get wifiModeUdp => 'UDP zum Sender';

  @override
  String get wifiModeUdpListen => 'UDP lauschen (GCS-Port)';

  @override
  String get hostIp => 'Host / IP';

  @override
  String get remotePort => 'Remote-Port';

  @override
  String get localPort => 'Lokaler Port';

  @override
  String get connectTransmitterWifi => 'Sender verbinden (WiFi)';

  @override
  String get autoTryWifi => 'WiFi automatisch versuchen';

  @override
  String get phoneLandscapeTitle => 'In Querformat drehen';

  @override
  String get phoneLandscapeBody => 'Diese App ist für Querformat ausgelegt.';

  @override
  String get returnToLaunch => 'Zum Start zurück';

  @override
  String get lineSpacing => 'Linienabstand';

  @override
  String get coverageAdjust => 'Abdeckung anpassen';

  @override
  String get obstacleCircle => 'Kreis';

  @override
  String get obstaclePolygon => 'Polygon';

  @override
  String get addObstacle => 'Hindernis hinzufügen';

  @override
  String get deleteObstacle => 'Hindernis löschen';

  @override
  String get planHistory => 'Planverlauf';

  @override
  String get imuCalibration => 'IMU-Kalibrierung';

  @override
  String get compassCalibration => 'Kompass-Kalibrierung';

  @override
  String get accelCalibration => 'Beschleunigungssensor-Kalibrierung';

  @override
  String get levelHorizon => 'Horizont ausrichten';

  @override
  String get startCalibration => 'Start';

  @override
  String get stopCalibration => 'Stopp';

  @override
  String get close => 'Schließen';

  @override
  String get delete => 'Löschen';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get mapAttributionEsri =>
      'Kacheln © Esri (Satellitenbild + Ortslabels)';

  @override
  String get mapAttributionOsm => '© OpenStreetMap-Mitwirkende';

  @override
  String get digitalSkyEmbedBlocked =>
      'Digital Sky lässt sich in dieser App nicht öffnen. Die Website blockiert die Einbettung in andere Websites.';

  @override
  String get digitalSkyDidNotLoad => 'Digital Sky konnte nicht geladen werden';

  @override
  String get openDigitalSky => 'Digital Sky öffnen';

  @override
  String get openDigitalSkyInBrowser => 'Digital Sky im Browser öffnen';

  @override
  String get calibrationRadio => 'Funk';

  @override
  String get calibrationImu => 'IMU';

  @override
  String get calibrationCompass => 'Kompass';

  @override
  String get calibrationStatusCalibrating => 'Kalibrierung läuft…';

  @override
  String get calibrationStatusCalibrated => 'Kalibriert';

  @override
  String get calibrationStatusNotCalibrated => 'Nicht kalibriert';

  @override
  String get startCalibrationFull => 'Kalibrierung starten';

  @override
  String connectLiveLink(String link) {
    return 'Live-Verbindung: $link';
  }

  @override
  String get connectUsbIntro =>
      'USB für Bodeneinrichtung. Zum Fliegen die App per Bluetooth oder WiFi mit dem Sender verbinden — Befehle gehen App → TX → Fluggerät.';

  @override
  String get connectWebUnsupported =>
      'Diese Web-Version kann keine USB-, Bluetooth- oder WiFi-Sockets öffnen. Nutzen Sie die Windows- oder Android-App.';

  @override
  String get transmitterPickHint =>
      'Bluetooth oder WiFi je nach Sender wählen. USB oben bleibt für die Bodeneinrichtung.';

  @override
  String get btAbbrev => 'BT';

  @override
  String get transmitterIpHost => 'Sender-IP / Host';

  @override
  String get tcpPort => 'TCP-Port';

  @override
  String get remoteUdpPort => 'Remote-UDP-Port';

  @override
  String get localUdpPort => 'Lokaler UDP-Port';

  @override
  String get tryingWifiPorts => 'Ports werden versucht…';

  @override
  String get autoTryWifiPorts => 'WiFi-Ports automatisch versuchen';

  @override
  String loadingParameters(int received, int total) {
    return 'Parameter werden geladen $received/$total';
  }

  @override
  String get linkLostTransmitter =>
      'Verbindung verloren — Senderstrom, Bluetooth/WiFi und Reichweite prüfen.';

  @override
  String get linkLostUsb =>
      'Verbindung verloren — USB-Kabel und FC-Stromversorgung prüfen.';

  @override
  String get connectLiveHint =>
      'USB: am FC am Boden anschließen. Flug: App mit Sender (Bluetooth oder WiFi) verbinden; Befehle und Telemetrie laufen über den TX zum Fluggerät. RC-Sticks für manuelle Übersteuerung bereithalten.';

  @override
  String get connectErrorUsbNeedsNative =>
      'Live-K++-USB erfordert die Windows- oder Android-Version — Web kann keine seriellen Ports öffnen.';

  @override
  String get connectErrorNoComPort =>
      'Kein COM-Port gefunden. K++-USB-Datenkabel anschließen und aktualisieren.';

  @override
  String connectErrorInvalidPort(String label) {
    return 'Gültigen $label eingeben (1–65535).';
  }

  @override
  String get connectErrorBluetoothNeedsNative =>
      'Bluetooth erfordert die Windows- oder Android-Desktop-/Mobil-Version.';

  @override
  String get connectErrorNoBluetoothSerial =>
      'Kein Bluetooth-Serial-Port gefunden. Sender in den System-Bluetooth-Einstellungen koppeln, dann Aktualisieren. Falls weiterhin fehlend: „Alle COM-Ports anzeigen“ aktivieren.';

  @override
  String get connectErrorWifiNeedsNative =>
      'Sender-WiFi erfordert die Windows- oder Android-Version.';

  @override
  String get connectErrorEnterTxHost =>
      'WiFi-IP / Hostname des Senders eingeben.';

  @override
  String get connectErrorNoWifiGateway =>
      'Kein WiFi-Gateway gefunden. Zuerst dem Sender-WiFi beitreten.';

  @override
  String connectUsingGateway(String gateway) {
    return 'Gateway $gateway wird genutzt — „Sender verbinden (WiFi)“ tippen.';
  }

  @override
  String get connectWifiJoinFirst =>
      'Zuerst dem Sender-WiFi beitreten, dann erneut versuchen.';

  @override
  String connectWifiTcpSuccess(String host, String port) {
    return 'Verbunden über TX-WiFi TCP $host:$port';
  }

  @override
  String get connectWifiG20Success =>
      'Verbunden mit Skydroid G20 TCP 192.168.43.1:5760';

  @override
  String get connectWifiUdpListenSuccess =>
      'UDP 14550 lauscht — TX/Fluggerät einschalten, damit Telemetrie gesendet wird.';

  @override
  String connectWifiAutoTryFailed(String detail) {
    return 'WiFi-Auto-Versuch fehlgeschlagen.\n$detail\n\nFür Skydroid G20: WiFi-Modus = TCP, IP 192.168.43.1, Port 5760. Am G20 WLAN-Hotspot und Datenfreigabe einschalten; Fluggerät + GR01 müssen verbunden sein (Baudrate am FC-Telemetrieport).';
  }

  @override
  String get rtlCommandConfirm => 'Live-Drohne zum Start zurückkehren lassen?';

  @override
  String get connectUsbToKppFirst => 'Zuerst USB mit K++ verbinden';

  @override
  String get noFlyZone => 'Flugverbotszone';

  @override
  String get orientation => 'Ausrichtung';

  @override
  String get autoAlign => 'Automatisch ausrichten';

  @override
  String get edgeMargin => 'Randabstand';

  @override
  String get operationMode => 'Betriebsmodus';

  @override
  String get sprayOn => 'Sprühen ein';

  @override
  String get sprayOff => 'Sprühen aus';

  @override
  String get latitude => 'Breitengrad';

  @override
  String get longitude => 'Längengrad';

  @override
  String get action => 'Aktion';

  @override
  String get selectCrop => 'Kultur wählen';

  @override
  String get sprayRate => 'Sprührate';

  @override
  String get notes => 'Notizen';

  @override
  String get name => 'Name';

  @override
  String get defaultMissionName => 'Mission';

  @override
  String uploadFlyConfirmMessage(int count, String meters) {
    return '$count Wegpunkte auf live K++ hochladen, bei Bedarf scharf schalten und Auto starten (Start $meters m)?';
  }

  @override
  String get missionUploadedSuccess =>
      'Mission hochgeladen — lokal gespeichert und Auto auf live K++ gestartet';

  @override
  String get missionSavedToDatabase => 'Mission in Datenbank gespeichert';

  @override
  String get noSavedMissions => 'Keine gespeicherten Missionen';

  @override
  String get connectKppUsbFirst => 'Zuerst live K++ per USB verbinden';

  @override
  String get enterMeterVoltageInMaxVoltage =>
      'Messerspannung unter Max. Spannung eingeben';

  @override
  String get battVoltMultWritten => 'BATT_VOLT_MULT auf live K++ geschrieben';

  @override
  String savedLocallyFcSyncFailed(String error) {
    return 'Lokal gespeichert; FC-Sync fehlgeschlagen: $error';
  }

  @override
  String get mapHintTapPlacePointA =>
      'Auf die Karte tippen, um Punkt A zu setzen';

  @override
  String get mapHintTapPlacePointB =>
      'Auf die Karte tippen, um Punkt B zu setzen';

  @override
  String get mapHintTapBoundaryForSplit =>
      'Grenze für den gewählten Punkt antippen';

  @override
  String get mapHintTapAddBoundaryPoint =>
      'Auf die Karte tippen, um einen Grenzpunkt hinzuzufügen';

  @override
  String get splitChoosePointsHint =>
      'Ersten oder letzten Punkt wählen, dann Grenzpunkt oder entlang der Grenze antippen.';

  @override
  String get chooseCircleOrPolygon => 'Kreis oder Polygon wählen';

  @override
  String get tapInsideFieldPlaceCircle =>
      'Innerhalb des Feldes tippen, um den Kreis zu platzieren.';

  @override
  String get tapMapPlaceCornersInOrder =>
      'Auf die Karte tippen, um jede Ecke der Reihe nach zu setzen.';
}
