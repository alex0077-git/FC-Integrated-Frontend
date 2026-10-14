// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class KppLocalizationsDe extends KppLocalizations {
  KppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => '<g id=\"1\">G0</g>';

  @override
  String get groupBasic => 'Basis';

  @override
  String get groupAdvanced => 'Erweitert';

  @override
  String get groupTools => 'Werkzeuge';

  @override
  String get groupFly => 'Flug';

  @override
  String get destOverview => 'Status';

  @override
  String get destInstallation => 'Installation';

  @override
  String get destRemoteControl => 'Fernsteuerung';

  @override
  String get destSensors => 'Sensoren';

  @override
  String get destFlight => 'Motoren & Flug';

  @override
  String get destGains => 'Gewinne';

  @override
  String get destProtection => 'Schutz';

  @override
  String get destPump => 'Pumpe';

  @override
  String get destLiquid => 'Füllstand';

  @override
  String get destSpraying => 'AB-Sprühen';

  @override
  String get destFence => 'Zaun';

  @override
  String get destExtensions => 'Erweiterungen';

  @override
  String get destChannels => 'Kanalzuordnung';

  @override
  String get destMission => 'Mission';

  @override
  String get destLogs => 'Flugprotokolle';

  @override
  String get destParameters => 'Alle Parameter';

  @override
  String get destFirmware => 'Firmware & Info';

  @override
  String get mapFly => 'Karte / Flug';

  @override
  String get groundPlan => 'Bodenplan';

  @override
  String get home => 'Startseite';

  @override
  String get language => 'Sprache';

  @override
  String get overviewDescription =>
      'Live-Gesundheit des Flugcontrollers und seiner Module (K++-Assistenten-Layout).';

  @override
  String get sensors => 'Sensoren';

  @override
  String get imu => 'G3 ';

  @override
  String get gps => 'G2';

  @override
  String get gps1 => 'GPS1';

  @override
  String get gps1Sats => 'GPS1 Satelliten';

  @override
  String get gps2 => 'GPS2';

  @override
  String get gps2Sats => 'GPS2 Satelliten';

  @override
  String get position => 'Position';

  @override
  String get altitude => 'Höhe';

  @override
  String get hdop => 'G18';

  @override
  String get powerAndLink => 'Strom & Verbindung';

  @override
  String get batteryVoltage => 'Batteriespannung';

  @override
  String get rcSignal => 'RC-Signal';

  @override
  String get link => 'Verbindung';

  @override
  String get firmwareVersion => 'Firmware-Version';

  @override
  String get softwareRevision => 'Software-Revision';

  @override
  String get parameters => 'Parameter';

  @override
  String get fcMessage => 'Flugcontroller-Meldung';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusFault => 'Fehler';

  @override
  String get statusNotConnected => 'Nicht verbunden';

  @override
  String get port => 'Port';

  @override
  String get baud => 'Baud';

  @override
  String get connect => 'Verbinden';

  @override
  String get disconnect => 'Trennen';

  @override
  String get bluetooth => 'G13.\t';

  @override
  String get wifi => 'G12.\t';

  @override
  String get refreshComPorts => 'COM-Ports aktualisieren';

  @override
  String get refreshBluetoothPorts => 'Bluetooth-Ports aktualisieren';

  @override
  String get setMode => 'Modus setzen';

  @override
  String get flightModeAuto => 'Automatisch';

  @override
  String get flightModeGuided => 'G15';

  @override
  String get flightModeLoiter => 'G16';

  @override
  String get flightModeRtl => 'G14.\t';

  @override
  String get flightModeLand => 'Landen';

  @override
  String get defaultAlt => 'Standardhöhe';

  @override
  String get abSpray => 'AB-Sprühen';

  @override
  String get download => 'Herunterladen';

  @override
  String get upload => 'Hochladen';

  @override
  String get clear => 'Löschen';

  @override
  String get import => 'Importieren';

  @override
  String get export => 'Exportieren';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'i.O.';

  @override
  String get altitudeM => 'Höhe (m)';

  @override
  String missionItemsHint(int count) {
    return '$count Einträge — Karte antippen für Wegpunkte';
  }

  @override
  String get setA => 'A setzen';

  @override
  String get setB => 'B setzen';

  @override
  String get tapMapForFence => 'Karte für Zaun antippen…';

  @override
  String get enableCircleFence => 'Kreiszaun aktivieren';

  @override
  String get editAltitude => 'Höhe bearbeiten';

  @override
  String get missionDownloaded => 'Mission heruntergeladen';

  @override
  String get missionUploaded => 'Mission hochgeladen';

  @override
  String get missionCleared => 'Mission gelöscht';

  @override
  String get rtlAccepted => 'RTL akzeptiert';

  @override
  String get landAccepted => 'Landen akzeptiert';

  @override
  String modeSet(String mode) {
    return 'Modus $mode gesetzt';
  }

  @override
  String get setPointsAbFirst =>
      'Setzen Sie zuerst Punkte A und B auf der Karte';

  @override
  String abSprayGenerated(int count) {
    return 'AB-Sprühmuster erzeugt ($count Einträge)';
  }

  @override
  String fenceCircleEnabled(String radius) {
    return 'Kreiszaun aktiv, Radius $radius m (beim Flug um Fluggerät zentriert)';
  }

  @override
  String exportedTo(String path) {
    return 'Exportiert nach $path';
  }

  @override
  String importedItems(int count) {
    return '$count Einträge importiert';
  }

  @override
  String get rtl => 'G14.\t';

  @override
  String get land => 'Landen';

  @override
  String get armed => 'SCHARF';

  @override
  String get disarmed => 'Entschärft';

  @override
  String get notConnected => 'Nicht verbunden';

  @override
  String get notConnectedHint =>
      'Wählen Sie ⟦einen⟧ G6-Anschluss (oder den Simulator) in der Leiste oben und drücken Sie auf Verbinden.';

  @override
  String get cardFrameType => 'Rahmentyp';

  @override
  String get frameTypeSubtitle =>
      'Wie G1-Assistent⟦:⟧ gelber Arm = Nase, M1–M8 = FC-Anschlüsse, rot CW / blau CCW = Propellerdrehung. Schreibt FRAME und SHAPE.';

  @override
  String get cardImuGpsMounting => '⟦G3-⟧ & ⟦⟧ G2-Montage';

  @override
  String get installationDescription =>
      'Wählen Sie die Richtungen, die der Montage der Module entsprechen, und geben Sie ihre Versätze vom Schwerpunkt der Flugzeugzelle in Zentimetern ein (blaue Zone negativ, gelbe Zone positiv).';

  @override
  String get remoteControlDescription =>
      'Um sicherzustellen, dass die Ausfallsicherung richtig eingestellt ist, schalten Sie die ⟦G4 nach dem Wechsel⟧ aus und überprüfen Sie, ob die Kanäle 1–4 in die Mitte springen (ca. 1500) und Kanal 5 in seine ausfallsichere Position springt.';

  @override
  String get cardRcSettingsFailsafe => '⟦G4-Einstellungen⟧ & Failsafe';

  @override
  String get stickCalibration => 'Stick-Kalibrierung';

  @override
  String get stickCalibrationIdle =>
      'Die aktuellen Endpunkte sind unten dargestellt. Beginnen Sie mit der Neukalibrierung der Kanäle 1-4.';

  @override
  String get stickCalibrationExtremes =>
      'Drücken Sie jeden Stick mehrmals auf sein Maximum und Minimum und drücken Sie dann auf Weiter.';

  @override
  String get stickCalibrationCentre =>
      'Lassen Sie jeden Stick in der Mitte los und drücken Sie dann auf Capture Center.';

  @override
  String get stickCalibrationReview =>
      'Überprüfen Sie die Ergebnisse und speichern Sie sie dann auf dem Flugcontroller.';

  @override
  String get startCalibration => 'Kalibrierung starten';

  @override
  String get captureCentre => 'Capture-Center';

  @override
  String get saveCalibration => 'Kalibrierung speichern';

  @override
  String get next => 'Weiter';

  @override
  String get channel => 'Kanal';

  @override
  String get min => 'Min.';

  @override
  String get centre => 'Zentrieren';

  @override
  String get max => 'Max.';

  @override
  String get channelMonitor => 'Kanäle';

  @override
  String get sensorsImuCompassSubtitle =>
      'Sensorrohwerte von jeder ⟦G3-Instanz⟧.';

  @override
  String get cardImuCompass => 'IMU & Kompass';

  @override
  String get cardBarometer => 'Luftdruck';

  @override
  String get noBarometerData => 'Keine Barometerdaten';

  @override
  String get imuLevelCalibration => '⟦⟧ G3-Level-Kalibrierung';

  @override
  String get imuLevelCalibrationSubtitle =>
      'Platzieren Sie den Flugregler nach oben und waagerecht, dann kalibrieren Sie ihn.';

  @override
  String get compassCalibration => 'Kompasskalibrierung.';

  @override
  String get compassCalibrationSubtitle =>
      'Drehen Sie das Flugzeug waagerecht und im Uhrzeigersinn, dann mit der Nase nach unten und im Uhrzeigersinn.';

  @override
  String get cardGlobalFlightLimits =>
      'Globale Flugbeschränkungen & Motorstillstand';

  @override
  String get motorTest => 'Motor test.';

  @override
  String get motorTestSubtitle =>
      'Dreht jeden Motor einzeln, um die Reihenfolge und Richtung zu überprüfen.';

  @override
  String get removePropellers => 'Propeller entfernen';

  @override
  String get startTest => 'Test starten';

  @override
  String motorTestConfirmMessage(int motor, String throttle, String seconds) {
    return 'Der Motortest dreht M$motor bei $throttle % für $seconds s.\nVergewissern Sie sich, dass die Propeller entfernt und das Flugzeug gesichert ist.';
  }

  @override
  String get testingMotors => 'Testverfahren';

  @override
  String get testMotors => 'Testmotoren';

  @override
  String get calibrateImu => '⟦G3 kalibrieren⟧';

  @override
  String get calibratingImu => 'Kalibrieren';

  @override
  String get calibrateCompass => 'Kalibrieren Sie den Kompass.';

  @override
  String get calibratingCompass => 'Kalibrieren';

  @override
  String get gainsDescription =>
      'Regelverstärkungen bestimmen das Gefühl des Piloten: Höhere Werte reagieren schneller, benötigen aber mehr Leistung. Bewegen Sie die Leistungstendenz nur dann in Richtung Vibrationsunterdrückung, wenn die Zelle sichtbar wackelt oder die Motoren laut klingen.';

  @override
  String protectionDescription(String voltage) {
    return 'Aktuelle Spannung: $voltage. Stufe 2 muss niedriger als Stufe 1 sein; beide Stufen blinken auch die Lichter.';
  }

  @override
  String barometerReading(String pressure, String temperature) {
    return 'Druck $pressure hPa   ·   Temperatur $temperature °C';
  }

  @override
  String get cardBasicGains => 'Grundgewinne';

  @override
  String get cardControlGains => 'Kontrollgewinne';

  @override
  String get cardSpeedSensitivity =>
      '2.2.2 Prüfung der Geschwindigkeitsempfindlichkeit';

  @override
  String get cardVoltageRtlLanding => 'Spannung, Rückkehr nach Hause & Landung';

  @override
  String get voltageCalibration => 'Spannungskalibrierung';

  @override
  String get voltageCalibrationSubtitle =>
      'Geben Sie die mit einem Messgerät gemessene Spannung ein, damit der FC-Wert mit ihr übereinstimmt.';

  @override
  String get meterVoltageV => 'Zählerspannung (V)';

  @override
  String get calibrateVoltage => 'Spannung kalibrieren';

  @override
  String get cardPump => 'Pumpe';

  @override
  String get cardLevelSensorProtection => 'Füllstandssensor & Schutz';

  @override
  String get cardAbJobSettings => '⟦⟧ G8-Job-Einstellungen';

  @override
  String get cardAbJobProcedure => '⟦⟧ G8-JOB-VERFAHR';

  @override
  String get fenceDescription =>
      'Kreis- und Höhenbegrenzungen. Zeichnen/passen Sie den Kreis aus der Mission-Karte an oder legen Sie hier Werte fest.';

  @override
  String get cardQuickFence => 'Schnellzaun';

  @override
  String get fenceEnabled => 'Zaun ist aktiviert';

  @override
  String get fenceOff => 'Zaun ist aus';

  @override
  String get enableAltitudeAndCircle => 'Höhe + Kreis aktivieren';

  @override
  String get disableFence => 'Zaun deaktivieren';

  @override
  String get cardHeightDistanceLimits => 'Höhen- und Abstandsbegrenzungen';

  @override
  String get cardRtkAntenna => '⟦G9-Antenne⟧';

  @override
  String rtkCurrentPositioning(String fix) {
    return 'Aktuelle Positionierung: $fix';
  }

  @override
  String get cardRadarVision4g => 'Radar-, Sicht- und 4G-Modulstatus';

  @override
  String get extensionsRadarStatusDescription =>
      'Höhe des Geländefolgeradars, Hindernisradarabstand, Zustand des Visionmoduls und IoT-SIM-Status werden hier wie im K++-Assistenten angezeigt.';

  @override
  String get channelsDescription =>
      'Überprüfen Sie den Kanalmonitor, um zu sehen, welche Kanäle Ihr RC verwendet, bevor Sie Funktionen zuweisen.';

  @override
  String get cardChannelFunctions => 'Kanalfunktionen';

  @override
  String get flightLogsDescription =>
      'Heruntergeladene Protokolle werden in Dokumente\\Fuselage-K++\\Protokolle gespeichert.';

  @override
  String get refreshList => 'Liste aktualisieren';

  @override
  String logsOnFlightController(int count) {
    return '⟦PH0-Protokolle⟧ auf dem Flugsteuergerät';
  }

  @override
  String parametersDescription(int count) {
    return '⟦PH0-Parameter,⟧ die vom Flugregler gelesen werden.';
  }

  @override
  String get parameterFiles => '===> Parameter Files';

  @override
  String get reloadFromFc => 'Von FC neu laden';

  @override
  String get searchByIdOrName => 'Suche nach ID oder name';

  @override
  String parametersShown(int count) {
    return '$count abgebildet';
  }

  @override
  String get paramColumnId => 'ID';

  @override
  String get paramColumnName => 'Name';

  @override
  String get paramColumnValue => 'Wert';

  @override
  String get paramFormHint =>
      'Geben Sie einen Wert ein und drücken Sie die Eingabetaste, um ihn in den Flugregler zu schreiben.';

  @override
  String get paramNotReported => 'Nicht von diesem Fluglotsen gemeldet';

  @override
  String paramUnknownOption(String value) {
    return 'Unbekannt ($value)';
  }

  @override
  String get enterNumber => 'Gib eine Nummer ein';

  @override
  String get writeToFlightControllerTitle => 'An den Fluglotsen schreiben?';

  @override
  String get write => 'Schreiben';

  @override
  String get cardVersions => 'Revisionen';

  @override
  String get cardVersionsAuthorisation => 'Versionen & Berechtigungen';

  @override
  String get firmwareUpgrade => 'Firmware-Upgrade';

  @override
  String get firmwareUpgradeDescription =>
      'Laden Sie die K++ V2 / KX /P3-Firmware über den Flugsteuerungs-Bootloader hoch. Entfernen Sie das Gerät während des Upgrades niemals.';

  @override
  String get upgradeFirmware => 'Firmware aktualisieren';

  @override
  String get factoryReset => 'Zurücksetzen auf Werkseinstellungen';

  @override
  String get factoryResetDescription =>
      'Stellen Sie jeden Parameter auf die Werkseinstellungen zurück.';

  @override
  String get restoreFactorySettings => 'Zurücksetzen auf Werkseinstellungen';

  @override
  String get droneRegistration => 'Drohnenregistrierung';

  @override
  String get droneRegistrationDescription =>
      'Herstellername, Flugzeugmodell und Flugzeugnummer (网络备案).';

  @override
  String get shape => 'Form';

  @override
  String validateMinimum(String value) {
    return 'Minimum ist $value';
  }

  @override
  String validateMaximum(String value) {
    return 'Maximum ist $value';
  }

  @override
  String get validateChooseOption =>
      'Wählen Sie eine der aufgeführten Optionen';

  @override
  String get instance => 'Instanz';

  @override
  String get accelAxes => 'Accel X / Y / Z';

  @override
  String get gyroAxes => 'Gyro X / Y / Z';

  @override
  String get compassAxes => 'Kompass X / Y / Z';

  @override
  String get comingSoon => 'Demnächst verfügbar';

  @override
  String get channelMonitorNoData => 'Noch ⟦keine G4-Daten⟧ empfangen.';

  @override
  String get channelMonitorHint =>
      'Bewegen Sie die Sticks und Schalter, um jeden Kanal zu sehen.';

  @override
  String duplicateChannelFunctions(String details) {
    return 'Doppelte Kanalfunktionen: $details';
  }

  @override
  String get logColumnNo => 'Nein.';

  @override
  String get logColumnTimeUtc => 'Uhrzeit (UTC)';

  @override
  String get logColumnSizeBytes => 'Größe (Bytes)';

  @override
  String get logReview => 'Wiederholung';

  @override
  String logSavedTo(int id, String path) {
    return 'Protokoll ⟦PH0 auf $path gespeichert⟧';
  }

  @override
  String motorThrottlePercent(String percent) {
    return 'Drossel $percent %';
  }

  @override
  String motorDurationSeconds(String seconds) {
    return 'Dauer $seconds s';
  }

  @override
  String motorTestAccepted(int motor) {
    return 'Motor ⟦M⟧ PH0-Test akzeptiert';
  }

  @override
  String motorTestFailed(String error) {
    return 'Motortest fehlgeschlagen: $error';
  }

  @override
  String get imuCalibrationAccepted => '⟦G3-Kalibrierung⟧ akzeptiert';

  @override
  String imuCalibrationFailed(String error) {
    return '⟦G3-Kalibrierung⟧ fehlgeschlagen: $error';
  }

  @override
  String get compassCalibrationStarted => 'Kompasskalibrierung gestartet';

  @override
  String compassCalibrationFailed(String error) {
    return 'Kompasskalibrierung fehlgeschlagen: $error';
  }

  @override
  String paramSaved(String id, String value) {
    return '$id gespeichert: $value';
  }

  @override
  String paramNotSaved(String id, String error) {
    return '$id nicht gespeichert: $error';
  }

  @override
  String paramsSavedCount(int count) {
    return '⟦PH0-Parameter⟧ gespeichert';
  }

  @override
  String paramsSavedPartial(int saved, int failed, String ids) {
    return '$saved gespeichert, $failed fehlgeschlagen: $ids';
  }

  @override
  String stickCalibrationInvalid(String channels) {
    return 'Kanal min/max außerhalb des Bereichs: $channels. Kalibrierung fehlgeschlagen — versuchen Sie es erneut.';
  }

  @override
  String fcReadingAndMultiplier(String reading, String mult) {
    return 'FC-Messwert: $reading   ·   Multiplikator: $mult';
  }

  @override
  String get enterValidMeterVoltage =>
      'Geben Sie eine gültige Zählerspannung ein';

  @override
  String get noBatteryVoltageYet =>
      'Noch keine Batteriespannung vom Flugregler';

  @override
  String logParseFailed(String error) {
    return 'Protokoll konnte nicht analysiert werden: $error';
  }

  @override
  String get logParseFailedHint =>
      'Öffnen Sie die .bin extern für eine vollständige Analyse.';

  @override
  String get logNoTrackSamples =>
      'Keine GPS/ATT-Proben in diesem Protokoll erkannt.';

  @override
  String get plotNoSamples => 'keine Proben';

  @override
  String plotMinMax(String min, String max) {
    return 'min $min  ·  max $max';
  }

  @override
  String exportParametersTo(int count, String path) {
    return 'PH0-Parameter ⟦in⟧ ⟦PH1 exportiert⟧';
  }

  @override
  String importFileFormatError(String message) {
    return 'Dateiformatfehler: $message';
  }

  @override
  String get importNothingMatches =>
      'Nichts zu importieren: Jeder Wert stimmt bereits mit dem Flugregler überein.';

  @override
  String fcFirmwareInfo(String version) {
    return 'Flugsteuerungs-Firmware: $version';
  }

  @override
  String get appAboutLine =>
      'Fuselage-K++ 1.0.0 — gebaut, um den ⟦G11 G1-Assistenten⟧ ⟦(⟧ JIYI221014) zu ersetzen.';

  @override
  String get sprayProcedure1Title => 'Aufzeichnungspunkt A';

  @override
  String get sprayProcedure1Detail =>
      'Drehen Sie ⟦den⟧ G8-Aufnahmeschalter in die mittlere Position.';

  @override
  String get sprayProcedure2Title => 'Aufzeichnungspunkt B';

  @override
  String get sprayProcedure2Detail =>
      'Drehen Sie ⟦den⟧ G8-Aufnahmeschalter in die obere Position.';

  @override
  String get sprayProcedure3Title => 'Starten Sie ⟦⟧ den G8-Job';

  @override
  String get sprayProcedure3Detail =>
      'Schalten Sie den ⟦⟧ G8-Ausführungsschalter ein (oder stellen ⟦⟧ Sie G8-Ausführung als Flugmodus ein).';

  @override
  String get sprayProcedure4Title => 'Richtung wählen';

  @override
  String get sprayProcedure4Detail =>
      'Drücken Sie den Rollenstab zur Seite, um zu arbeiten.';

  @override
  String get sprayProcedure5Title => 'A und B löschen';

  @override
  String get sprayProcedure5Detail =>
      'Drehen Sie ⟦den⟧ G8-Aufnahmeschalter schnell hin und her.';

  @override
  String get sprayProcedure6Title => 'Fortsetzen nach dem Nachfüllen';

  @override
  String get sprayProcedure6Detail =>
      'Ohne A/B zu löschen, schalten Sie AB Execute ein: Der Job wird vom letzten Leertankpunkt und der Richtung fortgesetzt.';

  @override
  String get waitingForProtocolConfirmation =>
      'Warten auf Protokollbestätigung';

  @override
  String get pendingFeatureBody =>
      'Der ⟦G1-Assistent⟧ verwendet dafür einen ⟦⟧G11-spezifischen Befehl, nicht den ⟦Standard-G10⟧. Es bleibt deaktiviert, bis eine Aufzeichnung der ursprünglichen App die genaue Nachricht bestätigt, sodass niemals etwas Unverifiziertes an den Flugcontroller gesendet wird.';

  @override
  String get optForward => 'Vorwärts';

  @override
  String get optRight => 'Rechts';

  @override
  String get optBackward => 'Rückwärts';

  @override
  String get optLeft => 'Links';

  @override
  String get optOff => 'Aus';

  @override
  String get optOn => 'Ein';

  @override
  String get optSinglePump => 'Einzelpumpe';

  @override
  String get optDoublePump => 'Dopelte pumpe';

  @override
  String get optQuadX => 'Quad X';

  @override
  String get optQuadPlus => 'G51';

  @override
  String get optHexaX => 'Hexa X';

  @override
  String get optHexaPlus => 'G53';

  @override
  String get optOctoX => 'Octo X';

  @override
  String get optOctoPlus => 'G55';

  @override
  String get optStandard => 'Norm';

  @override
  String get optCoaxial => 'Coaxial';

  @override
  String get optY6 => 'G56';

  @override
  String get optAltitude => 'Höhe';

  @override
  String get optAltitudeCircle => 'Höhe + Kreis';

  @override
  String get optCircle => 'Kreis';

  @override
  String get pLabel_FRAME => 'Rahmentyp';

  @override
  String get pLabel_SHAPE => 'Gestellform';

  @override
  String get pLabel_NAV_IMU_ORIENT => '⟦⟧ G3-Richtung';

  @override
  String get pLabel_NAV_COMP_ORIENT => '⟦⟧ G2-Richtung';

  @override
  String get pLabel_NAV_IMU_POS_X => 'IMU Position X';

  @override
  String get pLabel_NAV_IMU_POS_Y => 'IMU Position Y';

  @override
  String get pLabel_NAV_IMU_POS_Z => 'IMU Position Z';

  @override
  String get pLabel_NAV_GPS3_POS_X => 'GPS Position X';

  @override
  String get pLabel_NAV_GPS3_POS_Y => 'GPS Position Y';

  @override
  String get pLabel_NAV_GPS3_POS_Z => 'GPS Position Z';

  @override
  String get pLabel_NAV_IMU_SOURCE => '⟦⟧ G3-Quelle';

  @override
  String get pLabel_RC_TYPE => '⟦⟧ G4-Typ';

  @override
  String get pLabel_FS_THR_ENABLE => 'RC-Verlust fehlersichere Aktion';

  @override
  String get pLabel_RC_FS_CONTINUE => 'Job fortsetzen, wenn ⟦G4 verloren⟧ geht';

  @override
  String get pLabel_THR_DZ => 'Mittlere Totzone drosseln';

  @override
  String get pLabel_FLTMODE1 => 'Flugmodus 1';

  @override
  String get pLabel_FLTMODE2 => 'Flugmodus 2';

  @override
  String get pLabel_FLTMODE3 => 'Flugmodus 3';

  @override
  String get pLabel_FLTMODE4 => 'Flugmodus 4';

  @override
  String get pLabel_FLTMODE5 => 'Flugmodus 5';

  @override
  String get pLabel_FLTMODE6 => 'Flugmodus 6';

  @override
  String get pLabel_RC1_MIN => 'CH1 min';

  @override
  String get pLabel_RC1_MAX => 'CH1 max';

  @override
  String get pLabel_RC1_TRIM => 'CH1 Verkleidung';

  @override
  String get pLabel_RC2_MIN => 'CH2 min';

  @override
  String get pLabel_RC2_MAX => 'CH2 max';

  @override
  String get pLabel_RC2_TRIM => 'CH2 Verkleidung';

  @override
  String get pLabel_RC3_MIN => 'CH3 min';

  @override
  String get pLabel_RC3_MAX => 'CH3 max';

  @override
  String get pLabel_RC3_TRIM => 'CH3 Verkleidung';

  @override
  String get pLabel_RC4_MIN => 'CH4 min';

  @override
  String get pLabel_RC4_MAX => 'CH4 max';

  @override
  String get pLabel_RC4_TRIM => 'CH4 Verkleidung';

  @override
  String get pLabel_ANGLE_MAX => 'Neigungswinkel';

  @override
  String get pLabel_WPNAV_LOIT_SPEED => 'Maximale horizontale Geschwindigkeit';

  @override
  String get pLabel_PILOT_VELZ_UP => 'steiggeschwindigkeit';

  @override
  String get pLabel_PILOT_VELZ_DOWN => 'Max. Abstiegsgeschwindigkeit';

  @override
  String get pLabel_MOT_SPIN_ARMED => 'Motorleerlaufdrehzahl';

  @override
  String get pLabel_GAIN_BASIC_R_PI => 'Wankkorrektur';

  @override
  String get pLabel_GAIN_BASIC_R_D => 'Rolldämpfung';

  @override
  String get pLabel_GAIN_BASIC_P_PI => 'Tonhöhenkorrektur';

  @override
  String get pLabel_GAIN_BASIC_P_D => 'Nickdämpfung';

  @override
  String get pLabel_GAIN_BASIC_YAW => 'Gieren ';

  @override
  String get pLabel_GAIN_BASIC_THR => 'Leistung (vertikal)';

  @override
  String get pLabel_GAIN_CONTROL_RP => 'Roll / Pitch';

  @override
  String get pLabel_GAIN_CONTROL_YAW => 'Gieren ';

  @override
  String get pLabel_GAIN_CONTROL_THR => 'Hochkant';

  @override
  String get pLabel_GAIN_CONTROL_WP => 'Weiterleiten';

  @override
  String get pLabel_GAIN_CONTROL_MOV => 'Manöver';

  @override
  String get pLabel_GAIN_CONTROL_BRA => 'Bremsen';

  @override
  String get pLabel_GAIN_CONTROL_SCA => 'Koordination';

  @override
  String get pLabel_GAIN_CONTROL_TKO => 'Start';

  @override
  String get pLabel_GAIN_VEL_XY => 'Horizontaler Geschwindigkeitsgewinn';

  @override
  String get pLabel_GAIN_VEL_Z => 'Vertikale Geschwindigkeitsverstärkung';

  @override
  String get pLabel_GAIN_SEN_ATT => 'Haltungssensitivität';

  @override
  String get pLabel_GAIN_PERFORMANCE => 'Leistungstendenz';

  @override
  String get pLabel_FS_BATT_ENABLE => 'Niederspannungsschutzwirkung';

  @override
  String get pLabel_FS_BATT_WARNING => 'Alarmspannung Stufe 1';

  @override
  String get pLabel_FS_BATT_VOLTAGE => 'Alarmspannung Stufe 2';

  @override
  String get pLabel_FS_PMU_ENABLE => 'PMU Fehlerschutz';

  @override
  String get pLabel_RTL_ALT => 'Return-Home-Höhe';

  @override
  String get pLabel_LAND_SPEED => 'Landegeschwindigkeit:';

  @override
  String get pLabel_SPRAY_PUMP_TYPE => 'Pumpentyp';

  @override
  String get pLabel_LIQUID_TYPE => 'Füllstandsensor';

  @override
  String get pLabel_FS_LIQ_ENABLE => 'OUT-OF-LIQUID-SCHUTZ';

  @override
  String get pLabel_ABPOINT_DIS => 'AB Schwadbreite';

  @override
  String get pLabel_ABPOINT_SPEED => '⟦⟧ G8-Geschwindigkeit';

  @override
  String get pLabel_WPNAV_ENABLE_U => 'U-förmige Seitenverschiebung';

  @override
  String get pLabel_FENCE_ENABLE => 'Zaun aktivieren';

  @override
  String get pLabel_FENCE_TYPE => 'Zauntyp';

  @override
  String get pLabel_FENCE_ALT_MAX => 'Hight limit';

  @override
  String get pLabel_FENCE_RADIUS => 'Entfernungsgrenze (Radius)';

  @override
  String get pLabel_FENCE_ACTION => 'Zaunbruch-Aktion';

  @override
  String get pLabel_RTK_ANTI_DEG => '⟦Einbauwinkel⟧ der G9-Antenne';

  @override
  String get pLabel_CH6_OPT => 'Kanal 6 Funktion';

  @override
  String get pLabel_CH7_OPT => 'Kanal 7 Funktion';

  @override
  String get pLabel_CH8_OPT => 'Kanal 8 Funktion';

  @override
  String get pLabel_CH9_OPT => 'Kanal 9 Funktion';

  @override
  String get pLabel_CH10_OPT => 'Kanal 10 Funktion';

  @override
  String get pLabel_CH11_OPT => 'Kanal-11-Funktion';

  @override
  String get pLabel_CH12_OPT => 'Kanal 12 Funktion';

  @override
  String get pLabel_BATT_VOLT_MULT => 'Batteriespannungsvervielfacher';

  @override
  String get pLabel_FWVERSION => 'Firmware-Version';

  @override
  String get pLabel_SYSID_SW_MREV => 'Software-Revision';

  @override
  String get pLabel_INS_CAL_TYPE => '⟦⟧ G3-Kalibrierungsstatus';

  @override
  String get pLabel_COMPASS_CAL_TYPE => 'KOMPASS-KALIBRI';

  @override
  String get pLabel_REG_ENABLE => 'App-Freischaltung autorisiert';

  @override
  String get helpBasicGain =>
      'Bereich 0–200 %. Passt den Regler an die Flugzeugzelle an.';

  @override
  String get helpControlGain =>
      'Bereich 0–300 %. Höher = schnelleres Ansprechen; begrenzt durch die Leistung der Flugzeugzelle.';

  @override
  String get helpMode =>
      '⟦Zu den G1-Optionen⟧ gehören manueller ⟦Job⟧, G8-Ausführung, Routenjob⟦,⟧ G2-Geschwindigkeit, Seitenverschiebung und Geländeverfolgung. Value Mapping noch nicht bestätigt.';

  @override
  String get helpChannel =>
      'Diesem G4-Kanal zugewiesene Funktion⟦.⟧ Jede Funktion sollte einmal verwendet werden. Überprüfen Sie den Kanalmonitor, bevor Sie ihn wechseln.';

  @override
  String get help_0 =>
      'Motoranzahl und Layout als FRAME auf⟧ dem ⟦G1-Bus geschrieben.';

  @override
  String get help_1 =>
      'Versatz zum Schwerpunkt. Blaue Zone = negativ, gelbe Zone = positiv.';

  @override
  String get help_2 =>
      'Empfängerprotokoll. Wertzuordnung noch nicht bestätigt.';

  @override
  String get help_3 =>
      '⟦G1-Optionen⟧: Zurück nach Hause, Hover, Land, Hover und dann Land. Value Mapping noch nicht bestätigt — Test mit⟧ ausgeschaltetem ⟦G4 nach Änderung.';

  @override
  String get help_4 =>
      'In ⟦G8-⟧/ Routenjobs arbeitet die Drohne weiter, anstatt den Fail-Safe zu betreiben. Nur mit Radar zu empfehlen.';

  @override
  String get help_5 => 'Zentidegrees: 3000 = 30°.';

  @override
  String get help_6 =>
      '⟦G1-Optionen⟧: Deaktiviert, Sehr langsam, Langsam, Mittel, Sehr schnell. Value Mapping noch nicht bestätigt.';

  @override
  String get help_7 =>
      'Beschleunigung im autonomen Flug. Höher = schnellere Geschwindigkeitsänderungen.';

  @override
  String get help_8 => 'Beschleunigung unter Vorsteuerung.';

  @override
  String get help_9 => 'Höher = kürzeres, härteres automatisches Bremsen';

  @override
  String get help_10 =>
      'Entspricht der Reaktion der Steuerung auf Manöver; schnellere Energiesysteme benötigen höhere Werte.';

  @override
  String get help_11 => 'Höher = schneller, schärferer Start.';

  @override
  String get help_12 => 'Normalerweise nicht angepasst.';

  @override
  String get help_13 => 'Wie schnell der FC der Stick-Eingabe folgt.';

  @override
  String get help_14 =>
      'K++-Optionen: Ausgewogen, Sport, Antivibration. Nur bei sichtbarem Flattern des Fluggeräts Richtung Schwingungsdämpfung gehen. Wertzuordnung noch nicht bestätigt.';

  @override
  String get help_15 =>
      'K++-Optionen: Aus, Return home, Land (beide Stufen blinken auch die Lichter). Wertzuordnung noch nicht bestätigt.';

  @override
  String get help_16 => 'Muss niedriger als die Spannung Stufe 1 sein.';

  @override
  String get help_17 =>
      'Einzel: Pumpen-ESC an P1. Doppel: ESCs an P1 und P2; P1 vorwärts, P2 rückwärts.';

  @override
  String get help_18 =>
      'K++-Optionen: Nicht verwendet, Schalter-Sensor (FC-Port K2), Echtzeit-Füllstand. Durchflussmesser an Port K1. Wertzuordnung noch nicht bestätigt.';

  @override
  String get help_19 =>
      'Aktion bei leerem Tank. Wertzuordnung noch nicht bestätigt.';

  @override
  String get help_20 =>
      'Skalierungsfaktor für Spannungskalibrierung (Messgerät ÷ FC-Anzeige).';

  @override
  String get simulatorNoHardware => 'Simulator (keine Hardware)';

  @override
  String get hideTransmitter => 'Sender ausblenden';

  @override
  String get showTransmitter => 'Sender BT/WiFi';

  @override
  String get btAbbrev => 'BT';

  @override
  String get noBtSerialRefresh =>
      'Kein BT-Seriellport — TX koppeln, dann aktualisieren';

  @override
  String get txWifiIp => 'TX-WiFi-IP';

  @override
  String get tcp => 'TCP';

  @override
  String get linkDisconnected => 'Getrennt';

  @override
  String get linkConnecting => 'Verbinden…';

  @override
  String linkReadingParameters(int received, int total) {
    return 'Parameter lesen $received/$total';
  }

  @override
  String linkConnected(String link) {
    return 'Verbunden · $link';
  }

  @override
  String linkLostStatus(String link) {
    return 'Verbindung verloren · $link';
  }

  @override
  String get sensorGyroscope => 'Kreisel';

  @override
  String get sensorAccelerometer => 'Beschleunigungssensor';

  @override
  String get sensorCompass => 'Kompass';

  @override
  String get sensorBarometer => 'Barometer';

  @override
  String get sensorGps => 'GPS';
}
