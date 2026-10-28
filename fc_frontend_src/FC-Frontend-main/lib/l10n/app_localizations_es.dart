// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fuselage';

  @override
  String get connectTagline => 'Conéctese a su dron para comenzar';

  @override
  String get start => 'Iniciar';

  @override
  String get groundPlan => 'Plan de tierra';

  @override
  String get kppTuning => 'Ajuste K++';

  @override
  String get language => 'Idioma';

  @override
  String currentLanguage(String name) {
    return 'Idioma actual: $name';
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
  String get home => 'Inicio';

  @override
  String get takeoff => 'Despegue';

  @override
  String get arm => 'Armar';

  @override
  String get disarm => 'Desarmar';

  @override
  String get rtl => 'RTL';

  @override
  String get land => 'Aterrizar';

  @override
  String get landConfirmTitle => 'Aterrizar';

  @override
  String get landConfirmMessage => '¿Aterrizar el dron ahora?';

  @override
  String takeoffConfirmMessage(String meters) {
    return '¿Armar (si hace falta) y despegar a $meters m en la aeronave en vivo?';
  }

  @override
  String get armConfirmMessage => '¿Armar el dron en vivo?';

  @override
  String get disarmConfirmMessage => '¿Desarmar el dron en vivo?';

  @override
  String get rtlConfirmMessage => '¿Regresar al punto de despegue ahora?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get boundaries => 'Límites';

  @override
  String get split => 'Dividir';

  @override
  String get obstacles => 'Obstáculos';

  @override
  String get waypoints => 'Puntos de ruta';

  @override
  String get history => 'Historial';

  @override
  String get username => 'Usuario';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get units => 'Unidades';

  @override
  String get unitsMetric => 'Métrico';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get mapStyle => 'Estilo de mapa';

  @override
  String get mapStreet => 'Calle';

  @override
  String get mapSatellite => 'Satélite';

  @override
  String get mapDigitalSky => 'Cielo digital';

  @override
  String get kppTuningTitle => 'Ajuste K++';

  @override
  String get kppTuningSubtitle => 'Asistente completo del controlador de vuelo';

  @override
  String get about => 'Acerca de';

  @override
  String get appTagline =>
      'Vuele, planifique misiones y ajuste K++ — una sola app.';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get battery => 'Batería';

  @override
  String get flightParameters => 'Parámetros de vuelo';

  @override
  String get firstWarningThreshold => 'Primer umbral de aviso (%)';

  @override
  String get secondWarningThreshold => 'Segundo umbral de aviso (%)';

  @override
  String get criticalBatteryLevel => 'Nivel crítico de batería (%)';

  @override
  String get maxVoltage => 'Voltaje máx.';

  @override
  String get minVoltage => 'Voltaje mín.';

  @override
  String get lowVoltageThreshold => 'Umbral de bajo voltaje';

  @override
  String get criticalVoltageThreshold => 'Umbral de voltaje crítico';

  @override
  String get cellCount => 'Número de celdas';

  @override
  String get calibrateBatteryOnKpp => 'Calibrar batería en K++';

  @override
  String get maxYawRate => 'Velocidad máx. de guiñada';

  @override
  String get maxRollAngle => 'Ángulo máx. de alabeo';

  @override
  String get maxPitchAngle => 'Ángulo máx. de cabeceo';

  @override
  String get maxSpeed => 'Velocidad máx.';

  @override
  String get cruiseSpeed => 'Velocidad de crucero';

  @override
  String get saveMission => 'Guardar misión';

  @override
  String get loadMission => 'Cargar misión';

  @override
  String get uploadMission => 'Subir misión';

  @override
  String get callForJob => 'Solicitar trabajo';

  @override
  String get uploadAndFly => 'Subir y volar';

  @override
  String get uploadAndStart => 'Subir e iniciar';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Rehacer';

  @override
  String get reset => 'Restablecer';

  @override
  String get save => 'Guardar';

  @override
  String get heroImageLabel => 'Imagen principal de Fuselage';

  @override
  String get logoImageLabel => 'Logo de Fuselage';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Ajustes';

  @override
  String get connect => 'Conectar';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String gpsStatus(String fix, String sats) {
    return 'GPS $fix · $sats sats';
  }

  @override
  String get gpsUnknown => 'GPS --';

  @override
  String get modeUnknown => 'Modo --';

  @override
  String get calibration => 'Calibración';

  @override
  String get kppTuningFull => 'Ajuste K++ (asistente completo)';

  @override
  String get kppTuningFullSubtitle =>
      'Estado, sensores, ganancias, registros, firmware…';

  @override
  String get batteryCritical => 'Batería crítica';

  @override
  String get batteryLow => 'Batería baja';

  @override
  String get batteryFirstWarning => 'Battery first warning';

  @override
  String get batterySecondWarningRtl =>
      'Battery second warning — returning home (RTL)';

  @override
  String get altitude => 'Altitud';

  @override
  String get distanceToDrone => 'Distancia al dron';

  @override
  String get distanceToLanding => 'Distancia al punto de aterrizaje';

  @override
  String get speed => 'Velocidad';

  @override
  String get drawBoundaryBeforeSplit =>
      'Dibuje al menos tres puntos de límite antes de dividir.';

  @override
  String get firstPoint => 'Primer punto';

  @override
  String get endPoint => 'Punto final';

  @override
  String get undoSplit => 'Deshacer división';

  @override
  String get selectSplitA => 'Seleccionar división A';

  @override
  String get selectSplitB => 'Seleccionar división B';

  @override
  String get setA => 'Fijar A';

  @override
  String get setB => 'Fijar B';

  @override
  String get missionSpray => 'Pulverizar';

  @override
  String get missionSurvey => 'Topografía';

  @override
  String get missionManual => 'Manual';

  @override
  String waypointsCount(int count) {
    return 'Puntos de ruta ($count)';
  }

  @override
  String get noWaypointsYet => 'Aún no hay puntos de ruta';

  @override
  String get waypointDetail => 'Detalle del punto';

  @override
  String get selectWaypoint => 'Seleccione un punto';

  @override
  String get waypoint => 'Punto de ruta';

  @override
  String get loiter => 'Espera';

  @override
  String get cropRice => 'Arroz';

  @override
  String get cropWheat => 'Trigo';

  @override
  String get cropOther => 'Otro';

  @override
  String get connectLiveKpp => 'Conectar K++ en vivo';

  @override
  String get usbGround => 'USB (tierra)';

  @override
  String get comPort => 'Puerto COM';

  @override
  String get noComPort => 'Sin puerto COM';

  @override
  String get refreshComPorts => 'Actualizar puertos COM';

  @override
  String get baud => 'Baudios';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get connectUsbToKpp => 'Conectar USB a K++';

  @override
  String get transmitterBtWifi => 'Transmisor (Bluetooth / WiFi)';

  @override
  String get airbornePath => 'Ruta aérea — App → transmisor → aeronave';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'WiFi';

  @override
  String get bluetoothTransmitter => 'Transmisor Bluetooth';

  @override
  String get noBluetoothPort => 'Sin puerto Bluetooth';

  @override
  String get refreshBluetoothPorts => 'Actualizar puertos Bluetooth';

  @override
  String get showAllComPorts => 'Mostrar todos los puertos COM';

  @override
  String get showAllComPortsHint =>
      'Úselo si el TX está emparejado pero no aparece como Bluetooth';

  @override
  String get connectTransmitterBt => 'Conectar transmisor (Bluetooth)';

  @override
  String get disconnectTransmitter => 'Desconectar transmisor';

  @override
  String get g20Preset => 'Ajuste G20';

  @override
  String get useGatewayIp => 'Usar IP de puerta de enlace';

  @override
  String get refreshNetwork => 'Actualizar red';

  @override
  String get wifiMode => 'Modo WiFi';

  @override
  String get wifiModeTcp => 'TCP al AP del transmisor';

  @override
  String get wifiModeUdp => 'UDP al transmisor';

  @override
  String get wifiModeUdpListen => 'Escucha UDP (puerto GCS)';

  @override
  String get hostIp => 'Host / IP';

  @override
  String get remotePort => 'Puerto remoto';

  @override
  String get localPort => 'Puerto local';

  @override
  String get connectTransmitterWifi => 'Conectar transmisor (WiFi)';

  @override
  String get autoTryWifi => 'Probar WiFi automáticamente';

  @override
  String get phoneLandscapeTitle => 'Gire a horizontal';

  @override
  String get phoneLandscapeBody =>
      'Esta aplicación está diseñada para orientación horizontal.';

  @override
  String get returnToLaunch => 'Regresar al despegue';

  @override
  String get lineSpacing => 'Espaciado de líneas';

  @override
  String get coverageAdjust => 'Ajuste de cobertura';

  @override
  String get obstacleCircle => 'Círculo';

  @override
  String get obstaclePolygon => 'Polígono';

  @override
  String get addObstacle => 'Añadir obstáculo';

  @override
  String get deleteObstacle => 'Eliminar obstáculo';

  @override
  String get planHistory => 'Historial del plan';

  @override
  String get imuCalibration => 'Calibración IMU';

  @override
  String get compassCalibration => 'Calibración de brújula';

  @override
  String get accelCalibration => 'Calibración de acelerómetro';

  @override
  String get levelHorizon => 'Nivelar horizonte';

  @override
  String get startCalibration => 'Iniciar';

  @override
  String get stopCalibration => 'Detener';

  @override
  String get close => 'Cerrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Reintentar';

  @override
  String get mapAttributionEsri =>
      'Tiles © Esri (imagen + etiquetas de lugares)';

  @override
  String get mapAttributionOsm => '© Colaboradores de OpenStreetMap';

  @override
  String get digitalSkyEmbedBlocked =>
      'Digital Sky no se abrirá dentro de esta app. Su sitio bloquea que otras webs muestren el mapa.';

  @override
  String get digitalSkyDidNotLoad => 'Digital Sky no se cargó';

  @override
  String get openDigitalSky => 'Abrir Digital Sky';

  @override
  String get openDigitalSkyInBrowser => 'Abrir Digital Sky en el navegador';

  @override
  String get calibrationRadio => 'Radio';

  @override
  String get calibrationImu => 'IMU';

  @override
  String get calibrationCompass => 'Brújula';

  @override
  String get calibrationStatusCalibrating => 'Calibrando…';

  @override
  String get calibrationStatusCalibrated => 'Calibrado';

  @override
  String get calibrationStatusNotCalibrated => 'No calibrado';

  @override
  String get startCalibrationFull => 'Iniciar calibración';

  @override
  String connectLiveLink(String link) {
    return 'Enlace en vivo: $link';
  }

  @override
  String get connectUsbIntro =>
      'USB para configuración en tierra. Para volar, conecte la app al transmisor por Bluetooth o WiFi — los comandos van App → TX → aeronave.';

  @override
  String get connectWebUnsupported =>
      'Esta versión web no puede abrir sockets USB, Bluetooth ni WiFi. Use la app de Windows o Android.';

  @override
  String get transmitterPickHint =>
      'Elija Bluetooth o WiFi según su transmisor. El USB de arriba no cambia para configuración en tierra.';

  @override
  String get btAbbrev => 'BT';

  @override
  String get transmitterIpHost => 'IP / host del transmisor';

  @override
  String get tcpPort => 'Puerto TCP';

  @override
  String get remoteUdpPort => 'Puerto UDP remoto';

  @override
  String get localUdpPort => 'Puerto UDP local';

  @override
  String get tryingWifiPorts => 'Probando puertos…';

  @override
  String get autoTryWifiPorts => 'Probar puertos WiFi automáticamente';

  @override
  String loadingParameters(int received, int total) {
    return 'Cargando parámetros $received/$total';
  }

  @override
  String get linkLostTransmitter =>
      'Enlace perdido — compruebe alimentación del transmisor, Bluetooth/WiFi y alcance.';

  @override
  String get linkLostUsb =>
      'Enlace perdido — compruebe el cable USB y la alimentación del FC.';

  @override
  String get connectLiveHint =>
      'USB: conéctelo al FC en tierra. En vuelo: conecte esta app al transmisor (Bluetooth o WiFi); comandos y telemetría pasan por el TX a la aeronave. Mantenga los sticks del RC para anulación manual.';

  @override
  String get connectErrorUsbNeedsNative =>
      'K++ USB en vivo requiere la versión Windows o Android — la web no puede abrir puertos serie.';

  @override
  String get connectErrorNoComPort =>
      'No se encontró puerto COM. Conecte el cable USB de datos del K++ y actualice.';

  @override
  String connectErrorInvalidPort(String label) {
    return 'Introduzca un $label válido (1–65535).';
  }

  @override
  String get connectErrorBluetoothNeedsNative =>
      'Bluetooth requiere la versión de escritorio/móvil Windows o Android.';

  @override
  String get connectErrorNoBluetoothSerial =>
      'No se encontró puerto serie Bluetooth. Empareje el transmisor en ajustes Bluetooth del sistema y pulse Actualizar. Si sigue faltando, active «Mostrar todos los puertos COM».';

  @override
  String get connectErrorWifiNeedsNative =>
      'WiFi del transmisor requiere la versión Windows o Android.';

  @override
  String get connectErrorEnterTxHost =>
      'Introduzca la IP / nombre de host WiFi del transmisor.';

  @override
  String get connectErrorNoWifiGateway =>
      'No se encontró puerta de enlace WiFi. Únase primero al WiFi del transmisor.';

  @override
  String connectUsingGateway(String gateway) {
    return 'Usando puerta de enlace $gateway — pulse Conectar transmisor (WiFi).';
  }

  @override
  String get connectWifiJoinFirst =>
      'Únase primero al WiFi del transmisor e inténtelo de nuevo.';

  @override
  String connectWifiTcpSuccess(String host, String port) {
    return 'Conectado por WiFi TX TCP $host:$port';
  }

  @override
  String get connectWifiG20Success =>
      'Conectado a Skydroid G20 TCP 192.168.43.1:5760';

  @override
  String get connectWifiUdpListenSuccess =>
      'Escuchando UDP 14550 — encienda TX/aeronave para enviar telemetría.';

  @override
  String connectWifiAutoTryFailed(String detail) {
    return 'Falló el intento automático WiFi.\n$detail\n\nPara Skydroid G20: modo WiFi = TCP, IP 192.168.43.1, puerto 5760. En el G20 active hotspot WLAN y compartir datos; aeronave + GR01 deben estar enlazados (baudios en puerto telem del FC).';
  }

  @override
  String get rtlCommandConfirm =>
      '¿Ordenar al dron en vivo volver al punto de lanzamiento?';

  @override
  String get connectUsbToKppFirst => 'Conecte primero USB al K++';

  @override
  String get noFlyZone => 'Zona de no vuelo';

  @override
  String get orientation => 'Orientación';

  @override
  String get autoAlign => 'Autoalinear';

  @override
  String get edgeMargin => 'Margen del borde';

  @override
  String get operationMode => 'Modo de operación';

  @override
  String get sprayOn => 'Pulverización activada';

  @override
  String get sprayOff => 'Pulverización desactivada';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String get action => 'Acción';

  @override
  String get selectCrop => 'Seleccionar cultivo';

  @override
  String get sprayRate => 'Tasa de pulverización';

  @override
  String get flowRate => 'Flow rate';

  @override
  String get liquidLevel => 'Liquid';

  @override
  String get setTakeoffAltitude => 'Set takeoff altitude';

  @override
  String get takeoffAltitudeMeters => 'Altitude (m)';

  @override
  String get notes => 'Notas';

  @override
  String get name => 'Nombre';

  @override
  String get defaultMissionName => 'Misión';

  @override
  String uploadFlyConfirmMessage(int count, String meters) {
    return '¿Subir $count waypoints al K++ en vivo, armar si hace falta e iniciar Auto (despegue $meters m)?';
  }

  @override
  String uploadFlyConfirmBody(int count) {
    return 'Upload $count waypoints to the live K++ and start Auto?';
  }

  @override
  String get missionUploadedSuccess =>
      'Misión subida — guardada localmente y Auto iniciado en K++ en vivo';

  @override
  String get missionSavedToDatabase => 'Misión guardada en la base de datos';

  @override
  String get noSavedMissions => 'No hay misiones guardadas';

  @override
  String get connectKppUsbFirst => 'Conecte primero un K++ en vivo por USB';

  @override
  String get enterMeterVoltageInMaxVoltage =>
      'Introduzca un voltaje de medidor en Voltaje máximo';

  @override
  String get battVoltMultWritten => 'BATT_VOLT_MULT escrito en K++ en vivo';

  @override
  String savedLocallyFcSyncFailed(String error) {
    return 'Guardado localmente; falló sync FC: $error';
  }

  @override
  String get mapHintTapPlacePointA => 'Toque el mapa para colocar el punto A';

  @override
  String get mapHintTapPlacePointB => 'Toque el mapa para colocar el punto B';

  @override
  String get mapHintTapBoundaryForSplit =>
      'Toque el límite para el punto seleccionado';

  @override
  String get mapHintTapAddBoundaryPoint =>
      'Toque el mapa para añadir un punto de límite';

  @override
  String get splitChoosePointsHint =>
      'Elija primer o último punto, luego toque un punto del límite o en cualquier parte del límite.';

  @override
  String get chooseCircleOrPolygon => 'Elija círculo o polígono';

  @override
  String get tapInsideFieldPlaceCircle =>
      'Toque dentro del campo para colocar el círculo.';

  @override
  String get tapMapPlaceCornersInOrder =>
      'Toque el mapa para colocar cada esquina, en orden.';
}
