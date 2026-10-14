// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class KppLocalizationsEs extends KppLocalizations {
  KppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Fuselage-K++';

  @override
  String get groupBasic => 'Básico';

  @override
  String get groupAdvanced => 'Avanzado';

  @override
  String get groupTools => 'Herramientas';

  @override
  String get groupFly => 'Vuelo';

  @override
  String get destOverview => 'Estado';

  @override
  String get destInstallation => 'Instalación';

  @override
  String get destRemoteControl => 'Control remoto';

  @override
  String get destSensors => 'Sensores';

  @override
  String get destFlight => 'Motores y vuelo';

  @override
  String get destGains => 'Ganancias';

  @override
  String get destProtection => 'Protección';

  @override
  String get destPump => 'Bomba';

  @override
  String get destLiquid => 'Nivel de líquido';

  @override
  String get destSpraying => 'Pulverización AB';

  @override
  String get destFence => 'Cerca';

  @override
  String get destExtensions => 'Extensiones';

  @override
  String get destChannels => 'Mapeo de canales';

  @override
  String get destMission => 'Misión';

  @override
  String get destLogs => 'Registros de vuelo';

  @override
  String get destParameters => 'Todos los parámetros';

  @override
  String get destFirmware => 'Firmware y acerca de';

  @override
  String get mapFly => 'Mapa / vuelo';

  @override
  String get groundPlan => 'Plan de tierra';

  @override
  String get home => 'Inicio';

  @override
  String get language => 'Idioma';

  @override
  String get overviewDescription =>
      'Estado en vivo del controlador de vuelo y sus módulos (diseño del asistente K++).';

  @override
  String get sensors => 'Sensores';

  @override
  String get imu => 'ZIMU';

  @override
  String get gps => 'ZGPS';

  @override
  String get gps1 => 'ZZZZG2ZZ1';

  @override
  String get gps1Sats => 'Satélites GPS1';

  @override
  String get gps2 => 'ZZZZG2ZZ2';

  @override
  String get gps2Sats => 'Satélites GPS2';

  @override
  String get position => 'Posición';

  @override
  String get altitude => 'Altitud';

  @override
  String get hdop => 'ZHDOP';

  @override
  String get powerAndLink => 'Energía y enlace';

  @override
  String get batteryVoltage => 'Voltaje de batería';

  @override
  String get rcSignal => 'Señal RC';

  @override
  String get link => 'Enlace';

  @override
  String get firmwareVersion => 'Versión de firmware';

  @override
  String get softwareRevision => 'Revisión de software';

  @override
  String get parameters => 'Parámetros';

  @override
  String get fcMessage => 'Mensaje del controlador de vuelo';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusFault => 'Fallo';

  @override
  String get statusNotConnected => 'No conectado';

  @override
  String get port => 'Puerto';

  @override
  String get baud => 'Baudios';

  @override
  String get connect => 'Conectar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'ZZZZG12ZZ';

  @override
  String get refreshComPorts => 'Actualizar puertos COM';

  @override
  String get refreshBluetoothPorts => 'Actualizar puertos Bluetooth';

  @override
  String get setMode => 'Establecer modo';

  @override
  String get flightModeAuto => 'Auto';

  @override
  String get flightModeGuided => 'ZZZZG15ZZ';

  @override
  String get flightModeLoiter => 'Loiter';

  @override
  String get flightModeRtl => 'RTL';

  @override
  String get flightModeLand => 'Aterrizar';

  @override
  String get defaultAlt => 'Altitud predeterminada';

  @override
  String get abSpray => 'Pulverización AB';

  @override
  String get download => 'Descargar';

  @override
  String get upload => 'Subir';

  @override
  String get clear => 'Borrar';

  @override
  String get import => 'Importar';

  @override
  String get export => 'Exportar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get altitudeM => 'Altitud (m)';

  @override
  String missionItemsHint(int count) {
    return '$count elementos — toque el mapa para añadir waypoints';
  }

  @override
  String get setA => 'Establecer A';

  @override
  String get setB => 'Establecer B';

  @override
  String get tapMapForFence => 'Toque el mapa para la cerca…';

  @override
  String get enableCircleFence => 'Activar cerca circular';

  @override
  String get editAltitude => 'Editar altitud';

  @override
  String get missionDownloaded => 'Misión descargada';

  @override
  String get missionUploaded => 'Misión subida';

  @override
  String get missionCleared => 'Misión borrada';

  @override
  String get rtlAccepted => 'RTL aceptado';

  @override
  String get landAccepted => 'Aterrizaje aceptado';

  @override
  String modeSet(String mode) {
    return 'Modo $mode establecido';
  }

  @override
  String get setPointsAbFirst =>
      'Establezca primero los puntos A y B en el mapa';

  @override
  String abSprayGenerated(int count) {
    return 'Patrón AB generado ($count elementos)';
  }

  @override
  String fenceCircleEnabled(String radius) {
    return 'Cerca circular activada, radio $radius m (centrada en la aeronave en vuelo)';
  }

  @override
  String exportedTo(String path) {
    return 'Exportado a $path';
  }

  @override
  String importedItems(int count) {
    return 'Importados $count elementos';
  }

  @override
  String get rtl => 'RTL';

  @override
  String get land => 'Aterrizar';

  @override
  String get armed => 'ARMADO';

  @override
  String get disarmed => 'Desarmado';

  @override
  String get notConnected => 'No conectado';

  @override
  String get notConnectedHint =>
      'Elija un puerto ZZG6ZZZZ (o el simulador) en la barra de arriba y pulse Connect.';

  @override
  String get cardFrameType => 'Tipo de marco';

  @override
  String get frameTypeSubtitle =>
      'Igual que ZZZG1ZZ asistente: brazo amarillo = nariz, M1–M8 = puertos FC, rojo CW / azul CCW = giro hélice. Escribe FRAME y ZZG22ZZZZ.';

  @override
  String get cardImuGpsMounting => 'IMUZ &amp; ZZG2ZZZ';

  @override
  String get installationDescription =>
      'Elija direcciones para que coincidan cómo se montan los módulos, e ingrese sus compensaciones desde el centro de gravedad de la estructura aérea en centímetros (zona azul negativa, zona amarilla positiva).';

  @override
  String get remoteControlDescription =>
      'Para asegurarse de que el seguro de fallo está ajustado correctamente, cambie el RC después de cambiarlo y compruebe que los canales 1–4 saltan al centro (unos 1500) y el canal 5 salta a su posición insegura.';

  @override
  String get cardRcSettingsFailsafe => 'Ajustes RCZ &quot; failsafe';

  @override
  String get stickCalibration => 'Calibración de palos';

  @override
  String get stickCalibrationIdle =>
      'Los puntos finales actuales se muestran a continuación. Empieza a recalibrar los canales 1-4.';

  @override
  String get stickCalibrationExtremes =>
      'Empuja cada palo a su máximo y mínimo varias veces, luego presiona Siguiente.';

  @override
  String get stickCalibrationCentre =>
      'Libere cada palo al centro, luego presione el centro de Captura.';

  @override
  String get stickCalibrationReview =>
      'Compruebe los resultados, a continuación, guardarlos al controlador de vuelo.';

  @override
  String get startCalibration => 'Calibración inicial';

  @override
  String get captureCentre => 'Centro de captura';

  @override
  String get saveCalibration => 'Guardar calibración';

  @override
  String get next => 'Siguiente';

  @override
  String get channel => 'Canal';

  @override
  String get min => 'Min';

  @override
  String get centre => 'Centre';

  @override
  String get max => 'Max';

  @override
  String get channelMonitor => 'Monitor de canal';

  @override
  String get sensorsImuCompassSubtitle =>
      'Valores de sensores brutos de cada instancia ZZG3ZZZZ.';

  @override
  String get cardImuCompass => 'IMU';

  @override
  String get cardBarometer => 'Barómetro';

  @override
  String get noBarometerData => 'No hay datos del barómetro';

  @override
  String get imuLevelCalibration => 'Calibración de nivel ZZZZZZ';

  @override
  String get imuLevelCalibrationSubtitle =>
      'Coloque el controlador de vuelo hacia arriba y nivel, luego calibrar.';

  @override
  String get compassCalibration => 'Calibración de compás';

  @override
  String get compassCalibrationSubtitle =>
      'Girar el nivel de los aviones y el reloj, luego la nariz y el reloj.';

  @override
  String get cardGlobalFlightLimits => 'Límites globales de vuelo';

  @override
  String get motorTest => 'Prueba de motor';

  @override
  String get motorTestSubtitle =>
      'Gire cada motor individualmente para comprobar el orden y la dirección.';

  @override
  String get removePropellers => 'Quitar hélices';

  @override
  String get startTest => 'Prueba de inicio';

  @override
  String motorTestConfirmMessage(int motor, String throttle, String seconds) {
    return 'Prueba de motor girará M${motor}Z en ZZPH1ZZ% para ZZZPH2ZZS.\nConfirmar hélices son removidas y el avión está asegurado.';
  }

  @override
  String get testingMotors => 'Probando...';

  @override
  String get testMotors => 'Motores de ensayo';

  @override
  String get calibrateImu => 'Calibrar IMU';

  @override
  String get calibratingImu => 'Calibrando...';

  @override
  String get calibrateCompass => 'Calibrar la brújula';

  @override
  String get calibratingCompass => 'Calibrando...';

  @override
  String get gainsDescription =>
      'Las ganancias de control establecen la sensación del piloto: los valores superiores responden más rápido pero necesitan más energía. Sólo mueve la tendencia de rendimiento hacia la supresión de vibraciones si el marco de aire sacude visiblemente o los motores son ruidosos.';

  @override
  String protectionDescription(String voltage) {
    return 'Tensión actual: $voltage. El nivel 2 debe ser inferior al nivel 1; ambos niveles también flashean las luces.';
  }

  @override
  String barometerReading(String pressure, String temperature) {
    return 'Presión ZZPH0ZZZZ hPa · Temperatura ZZPH1ZZ °C';
  }

  @override
  String get cardBasicGains => 'Ganancias básicas';

  @override
  String get cardControlGains => 'Ganancias de control';

  @override
  String get cardSpeedSensitivity => 'Sensibilidad de velocidad';

  @override
  String get cardVoltageRtlLanding =>
      'Voltaje, regreso a casa &quot; aterrizaje';

  @override
  String get voltageCalibration => 'Calibración de tensión';

  @override
  String get voltageCalibrationSubtitle =>
      'Introduzca el voltaje medido con un metro para que la lectura del FC coincida con él.';

  @override
  String get meterVoltageV => 'Tensión de medición (V)';

  @override
  String get calibrateVoltage => 'Tensión calibrada';

  @override
  String get cardPump => 'Bomba';

  @override
  String get cardLevelSensorProtection => 'Sensor de nivel y protección';

  @override
  String get cardAbJobSettings => 'Ajustes de empleo de AB';

  @override
  String get cardAbJobProcedure => 'Procedimiento de trabajo ABZZZ';

  @override
  String get fenceDescription =>
      'Círculo y límites de altitud. Dibuja/ajusta el círculo del mapa de la Misión, o establece valores aquí.';

  @override
  String get cardQuickFence => 'Cierre rápido';

  @override
  String get fenceEnabled => 'Fence está habilitado';

  @override
  String get fenceOff => 'Fence está fuera';

  @override
  String get enableAltitudeAndCircle => 'Capacidad de altitud + círculo';

  @override
  String get disableFence => 'Cierre deshabilitable';

  @override
  String get cardHeightDistanceLimits => 'Altura y límites de distancia';

  @override
  String get cardRtkAntenna => 'RTK antena';

  @override
  String rtkCurrentPositioning(String fix) {
    return 'Posición actual: ZZZPH0ZZ';
  }

  @override
  String get cardRadarVision4g => 'Radar, visión y estado del módulo 4G';

  @override
  String get extensionsRadarStatusDescription =>
      'La altura del radar, la distancia por radar de obstáculos, el estado del módulo de visión y el estado de IoT SIM se muestran aquí en el asistente ZZG1ZZZ.';

  @override
  String get channelsDescription =>
      'Compruebe el monitor del canal para ver qué canales utiliza su RC antes de asignar funciones.';

  @override
  String get cardChannelFunctions => 'Funciones del canal';

  @override
  String get flightLogsDescription =>
      'Los registros descargados se guardan en Documentos\\ZZG0ZZ\\logs.';

  @override
  String get refreshList => 'Lista de referencia';

  @override
  String logsOnFlightController(int count) {
    return 'Registros $count en el controlador de vuelo';
  }

  @override
  String parametersDescription(int count) {
    return 'Parámetros $count leídos desde el controlador de vuelo.';
  }

  @override
  String get parameterFiles => 'Archivo de parámetros';

  @override
  String get reloadFromFc => 'Reload from FC';

  @override
  String get searchByIdOrName => 'Búsqueda por id o nombre';

  @override
  String parametersShown(int count) {
    return 'Z$count mostrado';
  }

  @override
  String get paramColumnId => 'Id';

  @override
  String get paramColumnName => 'Nombre';

  @override
  String get paramColumnValue => 'Valor';

  @override
  String get paramFormHint =>
      'Escriba un valor y pulse Enter para escribirlo al controlador de vuelo.';

  @override
  String get paramNotReported => 'No reportado por este controlador de vuelo';

  @override
  String paramUnknownOption(String value) {
    return 'Unknown ($value)';
  }

  @override
  String get enterNumber => 'Introduzca un número';

  @override
  String get writeToFlightControllerTitle =>
      '¿Escribir al controlador de vuelo?';

  @override
  String get write => 'Escriba';

  @override
  String get cardVersions => 'Versiones';

  @override
  String get cardVersionsAuthorisation =>
      'Versiones &quot; autorización &quot;';

  @override
  String get firmwareUpgrade => 'Actualización de firmware';

  @override
  String get firmwareUpgradeDescription =>
      'Cargue el firmware ZZG1ZZ V2 / KX / P3 a través del arranque del controlador de vuelo. Nunca quite el dispositivo mientras se actualiza.';

  @override
  String get upgradeFirmware => 'Firmware de actualización';

  @override
  String get factoryReset => 'restablecimiento de fábrica';

  @override
  String get factoryResetDescription =>
      'Restaurar cada parámetro a los defectos de fábrica.';

  @override
  String get restoreFactorySettings => 'Restaurar la configuración de fábrica';

  @override
  String get droneRegistration => 'Registro de secano';

  @override
  String get droneRegistrationDescription =>
      'Nombre del fabricante, modelo de avión y número de aeronaves (ZZG25ZZZ).';

  @override
  String get shape => 'Forma';

  @override
  String validateMinimum(String value) {
    return 'Mínimo ZZPH0ZZZ';
  }

  @override
  String validateMaximum(String value) {
    return 'Máximo es ZZZPH0ZZ';
  }

  @override
  String get validateChooseOption => 'Elija una de las opciones enumeradas';

  @override
  String get instance => 'Instance';

  @override
  String get accelAxes => 'Accel X / Y / Z';

  @override
  String get gyroAxes => 'Gyro X / Y / Z';

  @override
  String get compassAxes => 'Compass X / Y / Z';

  @override
  String get comingSoon => 'Pronto.';

  @override
  String get channelMonitorNoData => 'Aún no se han recibido datos RC.';

  @override
  String get channelMonitorHint =>
      'Mueva los palos y los interruptores para ver cada canal.';

  @override
  String duplicateChannelFunctions(String details) {
    return 'Funciones de canal duplicadas: ZZZPH0ZZ';
  }

  @override
  String get logColumnNo => 'No.';

  @override
  String get logColumnTimeUtc => 'Hora (UTC)';

  @override
  String get logColumnSizeBytes => 'Tamaño (bytes)';

  @override
  String get logReview => 'Examen';

  @override
  String logSavedTo(int id, String path) {
    return 'Log ZZPH0ZZZ salvado a $path';
  }

  @override
  String motorThrottlePercent(String percent) {
    return 'Throttle ZZZPH0ZZ %';
  }

  @override
  String motorDurationSeconds(String seconds) {
    return 'Duración ZZZPH0ZZ';
  }

  @override
  String motorTestAccepted(int motor) {
    return 'Prueba M${motor}Z aceptado';
  }

  @override
  String motorTestFailed(String error) {
    return 'Prueba de motor falló: $error';
  }

  @override
  String get imuCalibrationAccepted => 'Calibración IMU aceptada';

  @override
  String imuCalibrationFailed(String error) {
    return 'Calibración IMUZ falló: $error';
  }

  @override
  String get compassCalibrationStarted => 'Calibración de la brújula comenzó';

  @override
  String compassCalibrationFailed(String error) {
    return 'Falló la calibración de la brújula: ZZPH0ZZ';
  }

  @override
  String paramSaved(String id, String value) {
    return 'Z$id salvó: $value';
  }

  @override
  String paramNotSaved(String id, String error) {
    return '${id}Z no se salvó: $error';
  }

  @override
  String paramsSavedCount(int count) {
    return 'Parámetros ZZZPH0ZZ';
  }

  @override
  String paramsSavedPartial(int saved, int failed, String ids) {
    return '$saved salvado, $failed falló: ${ids}Z';
  }

  @override
  String stickCalibrationInvalid(String channels) {
    return 'Canal min/max fuera de rango: $channels. Falló la calibración — inténtelo de nuevo.';
  }

  @override
  String fcReadingAndMultiplier(String reading, String mult) {
    return 'lectura del FC: ZZZPH0ZZ · multiplicador: $mult';
  }

  @override
  String get enterValidMeterVoltage => 'Introduzca un voltaje medidor válido';

  @override
  String get noBatteryVoltageYet =>
      'No hay tensión de batería del controlador de vuelo todavía';

  @override
  String logParseFailed(String error) {
    return 'No podía analizar el registro: $error';
  }

  @override
  String get logParseFailedHint =>
      'Abra el .bin externamente para el análisis completo.';

  @override
  String get logNoTrackSamples =>
      'No se han reconocido muestras ZZG2ZZ/ATT en este registro.';

  @override
  String get plotNoSamples => 'No hay muestras';

  @override
  String plotMinMax(String min, String max) {
    return 'min ZZPH0ZZZ · max ${max}Z';
  }

  @override
  String exportParametersTo(int count, String path) {
    return 'Parámetros ZZPH0ZZZ exportados a ZZZPH1ZZ';
  }

  @override
  String importFileFormatError(String message) {
    return 'Error del formato de archivo: $message';
  }

  @override
  String get importNothingMatches =>
      'Nada que importar: todo valor ya coincide con el controlador de vuelo.';

  @override
  String fcFirmwareInfo(String version) {
    return 'Firme de controlador de vuelo: $version';
  }

  @override
  String get appAboutLine =>
      'ZZZZG0ZZ 1.0.0 — built to replace the JIYIZZZG1ZZ Assistant (ZZZG11ZZ221014).';

  @override
  String get sprayProcedure1Title => 'Punto de grabación A';

  @override
  String get sprayProcedure1Detail =>
      'Flip el interruptor de registro ZZG8ZZZZ a la posición media.';

  @override
  String get sprayProcedure2Title => 'Punto de grabación B';

  @override
  String get sprayProcedure2Detail =>
      'Flip el interruptor de registro ABZ a la posición alta.';

  @override
  String get sprayProcedure3Title => 'Iniciar el trabajo AB';

  @override
  String get sprayProcedure3Detail =>
      'Enciende el interruptor de ejecución AB (o establece ZZG8ZZZ ejecutar como modo de vuelo).';

  @override
  String get sprayProcedure4Title => 'Elija la dirección';

  @override
  String get sprayProcedure4Detail =>
      'Empuja el palo de rodillo hacia el lado para trabajar.';

  @override
  String get sprayProcedure5Title => 'Clear A and B';

  @override
  String get sprayProcedure5Detail =>
      'Flip el interruptor de registro AB de ida y vuelta rápidamente.';

  @override
  String get sprayProcedure6Title => 'Resumir después de recargar';

  @override
  String get sprayProcedure6Detail =>
      'Sin aclarar A/B, gire en ZZG8ZZZZ ejecutar: el trabajo se reanudará desde el último punto y dirección vacío.';

  @override
  String get waitingForProtocolConfirmation =>
      'Esperando confirmación del protocolo';

  @override
  String get pendingFeatureBody =>
      'El asistente K++Z utiliza un comando JIYIZ específico para esto, no estándar MAVLink. Se mantiene deshabilitado hasta que una grabación de la aplicación original confirma el mensaje exacto, por lo que nada no verificado se envía al controlador de vuelo.';

  @override
  String get optForward => 'Adelante.';

  @override
  String get optRight => 'Bien.';

  @override
  String get optBackward => 'Atrás';

  @override
  String get optLeft => 'Izquierda';

  @override
  String get optOff => 'Fuera.';

  @override
  String get optOn => 'On';

  @override
  String get optSinglePump => 'Bomba individual';

  @override
  String get optDoublePump => 'Bomba doble';

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
  String get optStandard => 'Estándar';

  @override
  String get optCoaxial => 'Coaxial';

  @override
  String get optY6 => 'Y6';

  @override
  String get optAltitude => 'Altitud';

  @override
  String get optAltitudeCircle => 'Altitud + círculo';

  @override
  String get optCircle => 'Circle';

  @override
  String get pLabel_FRAME => 'Tipo de marco';

  @override
  String get pLabel_SHAPE => 'Forma de marco';

  @override
  String get pLabel_NAV_IMU_ORIENT => 'IMUdirección';

  @override
  String get pLabel_NAV_COMP_ORIENT => 'Dirección GPSZZ';

  @override
  String get pLabel_NAV_IMU_POS_X => 'IMU posición X';

  @override
  String get pLabel_NAV_IMU_POS_Y => 'IMU posición Y';

  @override
  String get pLabel_NAV_IMU_POS_Z => 'IMU Posición Z';

  @override
  String get pLabel_NAV_GPS3_POS_X => 'GPS posición X';

  @override
  String get pLabel_NAV_GPS3_POS_Y => 'GPS posición Y';

  @override
  String get pLabel_NAV_GPS3_POS_Z => 'GPS Posición Z';

  @override
  String get pLabel_NAV_IMU_SOURCE => 'Fuente IMU';

  @override
  String get pLabel_RC_TYPE => 'Tipo RC';

  @override
  String get pLabel_FS_THR_ENABLE => 'RCZ-loss failsafe action';

  @override
  String get pLabel_RC_FS_CONTINUE =>
      'Continuar el trabajo cuando ZZG4ZZZ se pierde';

  @override
  String get pLabel_THR_DZ => 'Umbral de la zona muerta';

  @override
  String get pLabel_FLTMODE1 => 'Modo de vuelo 1';

  @override
  String get pLabel_FLTMODE2 => 'Modo de vuelo 2';

  @override
  String get pLabel_FLTMODE3 => 'Modo de vuelo 3';

  @override
  String get pLabel_FLTMODE4 => 'Modo de vuelo 4';

  @override
  String get pLabel_FLTMODE5 => 'Modo de vuelo 5';

  @override
  String get pLabel_FLTMODE6 => 'Modo de vuelo 6';

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
  String get pLabel_ANGLE_MAX => 'Ángulo de inclinación';

  @override
  String get pLabel_WPNAV_LOIT_SPEED => 'Velocidad horizontal';

  @override
  String get pLabel_PILOT_VELZ_UP => 'Velocidad de escalada';

  @override
  String get pLabel_PILOT_VELZ_DOWN => 'Velocidad máxima de descenso';

  @override
  String get pLabel_MOT_SPIN_ARMED => 'Velocidad de vela motorizada';

  @override
  String get pLabel_GAIN_BASIC_R_PI => 'Corrección';

  @override
  String get pLabel_GAIN_BASIC_R_D => 'Roll damping';

  @override
  String get pLabel_GAIN_BASIC_P_PI => 'Corrección de Pitch';

  @override
  String get pLabel_GAIN_BASIC_P_D => 'Pitch damping';

  @override
  String get pLabel_GAIN_BASIC_YAW => 'Yaw.';

  @override
  String get pLabel_GAIN_BASIC_THR => 'Potencia (vertical)';

  @override
  String get pLabel_GAIN_CONTROL_RP => 'Roll / pitch';

  @override
  String get pLabel_GAIN_CONTROL_YAW => 'Yaw.';

  @override
  String get pLabel_GAIN_CONTROL_THR => 'Vertical';

  @override
  String get pLabel_GAIN_CONTROL_WP => 'Ruta';

  @override
  String get pLabel_GAIN_CONTROL_MOV => 'Manoeuvre';

  @override
  String get pLabel_GAIN_CONTROL_BRA => 'Brake';

  @override
  String get pLabel_GAIN_CONTROL_SCA => 'Coordinación';

  @override
  String get pLabel_GAIN_CONTROL_TKO => 'Despegue';

  @override
  String get pLabel_GAIN_VEL_XY => 'Ganancia de velocidad horizontal';

  @override
  String get pLabel_GAIN_VEL_Z => 'Ganancia de velocidad vertical';

  @override
  String get pLabel_GAIN_SEN_ATT => 'Sensibilidad de actitud';

  @override
  String get pLabel_GAIN_PERFORMANCE => 'Tendencia de rendimiento';

  @override
  String get pLabel_FS_BATT_ENABLE => 'Medidas de protección de baja tensión';

  @override
  String get pLabel_FS_BATT_WARNING => 'Tensión de alarma de nivel 1';

  @override
  String get pLabel_FS_BATT_VOLTAGE => 'Tensión de alarma de nivel 2';

  @override
  String get pLabel_FS_PMU_ENABLE => 'PMU protección de la falla';

  @override
  String get pLabel_RTL_ALT => 'Altura de regreso a casa';

  @override
  String get pLabel_LAND_SPEED => 'Velocidad de aterrizaje';

  @override
  String get pLabel_SPRAY_PUMP_TYPE => 'Tipo de bomba';

  @override
  String get pLabel_LIQUID_TYPE => 'Tipo de sensor de nivel';

  @override
  String get pLabel_FS_LIQ_ENABLE => 'Protección anticuada';

  @override
  String get pLabel_ABPOINT_DIS => 'AB ancho de swath';

  @override
  String get pLabel_ABPOINT_SPEED => 'Velocidad AB';

  @override
  String get pLabel_WPNAV_ENABLE_U => 'Cambio lateral en forma de U';

  @override
  String get pLabel_FENCE_ENABLE => 'Fence enable';

  @override
  String get pLabel_FENCE_TYPE => 'Tipo Fence';

  @override
  String get pLabel_FENCE_ALT_MAX => 'Límite de altura';

  @override
  String get pLabel_FENCE_RADIUS => 'Límite de distancia (radius)';

  @override
  String get pLabel_FENCE_ACTION => 'Fence breach action';

  @override
  String get pLabel_RTK_ANTI_DEG => 'RTKZ antena de instalación ángulo';

  @override
  String get pLabel_CH6_OPT => 'Función del Canal 6';

  @override
  String get pLabel_CH7_OPT => 'Función del canal 7';

  @override
  String get pLabel_CH8_OPT => 'Función del Canal 8';

  @override
  String get pLabel_CH9_OPT => 'Función del canal 9';

  @override
  String get pLabel_CH10_OPT => 'Canal 10 función';

  @override
  String get pLabel_CH11_OPT => 'Función del Canal 11';

  @override
  String get pLabel_CH12_OPT => 'Función del Canal 12';

  @override
  String get pLabel_BATT_VOLT_MULT => 'Multiplicador de tensión de batería';

  @override
  String get pLabel_FWVERSION => 'Versión de firmware';

  @override
  String get pLabel_SYSID_SW_MREV => 'Revisión del software';

  @override
  String get pLabel_INS_CAL_TYPE => 'IMU estado de calibración';

  @override
  String get pLabel_COMPASS_CAL_TYPE => 'Compass calibration state';

  @override
  String get pLabel_REG_ENABLE => 'Desbloqueo autorizado';

  @override
  String get helpBasicGain =>
      'Rango 0–200 %. Adapta el controlador al marco de aire.';

  @override
  String get helpControlGain =>
      'Rango 0–300 %. Mayor = respuesta más rápida; limitada por el poder de la estructura aérea.';

  @override
  String get helpMode =>
      'Las opciones K++Z incluyen trabajo manual, ZZG8ZZZ ejecutar, Trabajo de ruta, velocidad ZZG2ZZZZ, Cambio lateral y Terrain seguir. La asignación de valor aún no está confirmada.';

  @override
  String get helpChannel =>
      'Función asignada a este canal ZZG4ZZZ. Cada función debe usarse una vez; revise el monitor del canal antes de cambiar.';

  @override
  String get help_0 =>
      'Conteo y diseño de motor escrito como ZZG21ZZZZ en el autobús ZZG1ZZZ.';

  @override
  String get help_1 =>
      'Inaugurado desde el centro de gravedad. Zona azul = zona amarilla negativa = positiva.';

  @override
  String get help_2 =>
      'Protocolo de receptor. La asignación de valor aún no está confirmada.';

  @override
  String get help_3 =>
      'K++Z opciones: Volver a casa, Hover, Land, Hover luego aterrizar. El mapeo de valor aún no confirmado — prueba con el ZZZG4ZZ apagado después de cambiar.';

  @override
  String get help_4 =>
      'En AB / trabajo de ruta el drone sigue trabajando en lugar de ejecutar el seguro de fallo. Recomendado sólo con radar.';

  @override
  String get help_5 => 'Centidegrees: 3000 = 30°.';

  @override
  String get help_6 =>
      'K++ opciones: Discapacitados, Muy lento, Lenta, Mediana, Muy rápido. La asignación de valor aún no está confirmada.';

  @override
  String get help_7 =>
      'Aceleración en vuelo autónomo. Más alto = cambios rápidos de velocidad.';

  @override
  String get help_8 => 'Aceleración bajo control piloto.';

  @override
  String get help_9 => 'Más alto = más corto, más duro freno automático.';

  @override
  String get help_10 =>
      'Coincide la respuesta de control a las maniobras; los sistemas de energía más rápidos necesitan valores más altos.';

  @override
  String get help_11 => 'Más alto = despegue más rápido y crujiente.';

  @override
  String get help_12 => 'Normalmente no ajustado.';

  @override
  String get help_13 => 'Cuán rápido el FC sigue la entrada de palo.';

  @override
  String get help_14 =>
      'K++ opciones: Equilibrado, Deporte, Anti-vibración. Sólo avanzar hacia la supresión de vibraciones si el marco aéreo se sacude visiblemente. La asignación de valor aún no está confirmada.';

  @override
  String get help_15 =>
      'K++ opciones: Off, Return home, Land (ambos niveles también flash las luces). La asignación de valor aún no está confirmada.';

  @override
  String get help_16 => 'Debe ser inferior al nivel 1 tensión.';

  @override
  String get help_17 =>
      'Individual: bomba ESC en P1. Doble: ESCs en P1 y P2; P1 corre volando hacia adelante, P2 volando hacia atrás.';

  @override
  String get help_18 =>
      'Opciones K++: No utilizado, Sensor de conmutación (puerto K2), nivel en tiempo real. El medidor de flujo va en el puerto K1. La asignación de valor aún no está confirmada.';

  @override
  String get help_19 =>
      'Acción cuando el tanque corre seco. La asignación de valor aún no está confirmada.';

  @override
  String get help_20 =>
      'Factor de escala utilizado para calibración de tensión (metro lectura ÷ lectura del FC).';

  @override
  String get simulatorNoHardware => 'Simulador (sin hardware)';

  @override
  String get hideTransmitter => 'Ocultar transmisor';

  @override
  String get showTransmitter => 'Transmisor BT/WiFi';

  @override
  String get btAbbrev => 'BT';

  @override
  String get noBtSerialRefresh =>
      'Sin puerto serie BT — empareje el TX y actualice';

  @override
  String get txWifiIp => 'IP WiFi del TX';

  @override
  String get tcp => 'TCP';

  @override
  String get linkDisconnected => 'Desconectado';

  @override
  String get linkConnecting => 'Conectando…';

  @override
  String linkReadingParameters(int received, int total) {
    return 'Leyendo parámetros $received/$total';
  }

  @override
  String linkConnected(String link) {
    return 'Conectado · $link';
  }

  @override
  String linkLostStatus(String link) {
    return 'Enlace perdido · $link';
  }

  @override
  String get sensorGyroscope => 'Giróscopo';

  @override
  String get sensorAccelerometer => 'Acelerómetro';

  @override
  String get sensorCompass => 'Brújula';

  @override
  String get sensorBarometer => 'Barómetro';

  @override
  String get sensorGps => 'GPS';
}
