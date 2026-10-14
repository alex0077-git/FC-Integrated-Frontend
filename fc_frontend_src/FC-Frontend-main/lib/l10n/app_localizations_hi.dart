// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Fuselage';

  @override
  String get connectTagline => 'शुरू करने के लिए अपने ड्रोन से कनेक्ट करें';

  @override
  String get start => 'शुरू करें';

  @override
  String get groundPlan => 'ग्राउंड प्लान';

  @override
  String get kppTuning => 'K++ ट्यूनिंग';

  @override
  String get language => 'भाषा';

  @override
  String currentLanguage(String name) {
    return 'वर्तमान भाषा: $name';
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
  String get home => 'होम';

  @override
  String get takeoff => 'टेकऑफ़';

  @override
  String get arm => 'आर्म';

  @override
  String get disarm => 'डिसआर्म';

  @override
  String get rtl => 'RTL';

  @override
  String get land => 'लैंड';

  @override
  String get landConfirmTitle => 'लैंड';

  @override
  String get landConfirmMessage => 'क्या अभी ड्रोन लैंड करें?';

  @override
  String takeoffConfirmMessage(String meters) {
    return 'आर्म करें (यदि आवश्यक) और लाइव विमान पर $meters मी तक टेकऑफ़ करें?';
  }

  @override
  String get armConfirmMessage => 'लाइव ड्रोन आर्म करें?';

  @override
  String get disarmConfirmMessage => 'लाइव ड्रोन डिसआर्म करें?';

  @override
  String get rtlConfirmMessage => 'अभी लॉन्च बिंदु पर वापस जाएँ?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get boundaries => 'सीमाएँ';

  @override
  String get split => 'विभाजन';

  @override
  String get obstacles => 'बाधाएँ';

  @override
  String get waypoints => 'वेपॉइंट';

  @override
  String get history => 'इतिहास';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get theme => 'थीम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get units => 'इकाइयाँ';

  @override
  String get unitsMetric => 'मीट्रिक';

  @override
  String get unitsImperial => 'इम्पीरियल';

  @override
  String get mapStyle => 'मानचित्र शैली';

  @override
  String get mapStreet => 'सड़क';

  @override
  String get mapSatellite => 'उपग्रह';

  @override
  String get mapDigitalSky => 'डिजिटल स्काई';

  @override
  String get kppTuningTitle => 'K++ ट्यूनिंग';

  @override
  String get kppTuningSubtitle => 'पूर्ण फ्लाइट-कंट्रोलर सहायक';

  @override
  String get about => 'परिचय';

  @override
  String get appTagline => 'उड़ान, मिशन योजना और K++ ट्यूनिंग — एक ऐप।';

  @override
  String versionLabel(String version) {
    return 'संस्करण $version';
  }

  @override
  String get battery => 'बैटरी';

  @override
  String get flightParameters => 'फ्लाइट पैरामीटर';

  @override
  String get firstWarningThreshold => 'पहली चेतावनी सीमा (%)';

  @override
  String get secondWarningThreshold => 'दूसरी चेतावनी सीमा (%)';

  @override
  String get criticalBatteryLevel => 'गंभीर बैटरी स्तर (%)';

  @override
  String get maxVoltage => 'अधिकतम वोल्टेज';

  @override
  String get minVoltage => 'न्यूनतम वोल्टेज';

  @override
  String get lowVoltageThreshold => 'कम वोल्टेज सीमा';

  @override
  String get criticalVoltageThreshold => 'गंभीर वोल्टेज सीमा';

  @override
  String get cellCount => 'सेल संख्या';

  @override
  String get calibrateBatteryOnKpp => 'K++ पर बैटरी कैलिब्रेट करें';

  @override
  String get maxYawRate => 'अधिकतम यॉ दर';

  @override
  String get maxRollAngle => 'अधिकतम रोल कोण';

  @override
  String get maxPitchAngle => 'अधिकतम पिच कोण';

  @override
  String get maxSpeed => 'अधिकतम गति';

  @override
  String get cruiseSpeed => 'क्रूज़ गति';

  @override
  String get saveMission => 'मिशन सहेजें';

  @override
  String get loadMission => 'मिशन लोड करें';

  @override
  String get uploadMission => 'मिशन अपलोड करें';

  @override
  String get callForJob => 'जॉब कॉल करें';

  @override
  String get uploadAndFly => 'अपलोड और उड़ान';

  @override
  String get uploadAndStart => 'अपलोड और शुरू';

  @override
  String get undo => 'पूर्ववत';

  @override
  String get redo => 'फिर से करें';

  @override
  String get reset => 'रीसेट';

  @override
  String get save => 'सहेजें';

  @override
  String get heroImageLabel => 'Fuselage हीरो छवि';

  @override
  String get logoImageLabel => 'Fuselage लोगो';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get connect => 'कनेक्ट';

  @override
  String get connected => 'कनेक्टेड';

  @override
  String get disconnected => 'डिस्कनेक्टेड';

  @override
  String gpsStatus(String fix, String sats) {
    return 'GPS $fix · $sats सैट';
  }

  @override
  String get gpsUnknown => 'GPS --';

  @override
  String get modeUnknown => 'मोड --';

  @override
  String get calibration => 'कैलिब्रेशन';

  @override
  String get kppTuningFull => 'K++ ट्यूनिंग (पूर्ण सहायक)';

  @override
  String get kppTuningFullSubtitle => 'स्थिति, सेंसर, गेन्स, लॉग, फर्मवेयर…';

  @override
  String get batteryCritical => 'बैटरी गंभीर';

  @override
  String get batteryLow => 'बैटरी कम';

  @override
  String get altitude => 'ऊंचाई';

  @override
  String get distanceToDrone => 'ड्रोन तक दूरी';

  @override
  String get distanceToLanding => 'लैंडिंग बिंदु तक दूरी';

  @override
  String get speed => 'गति';

  @override
  String get drawBoundaryBeforeSplit =>
      'विभाजन से पहले कम से कम तीन सीमा बिंदु बनाएँ।';

  @override
  String get firstPoint => 'पहला बिंदु';

  @override
  String get endPoint => 'अंतिम बिंदु';

  @override
  String get undoSplit => 'विभाजन पूर्ववत';

  @override
  String get selectSplitA => 'स्प्लिट A चुनें';

  @override
  String get selectSplitB => 'स्प्लिट B चुनें';

  @override
  String get setA => 'A सेट करें';

  @override
  String get setB => 'B सेट करें';

  @override
  String get missionSpray => 'स्प्रे';

  @override
  String get missionSurvey => 'सर्वे';

  @override
  String get missionManual => 'मैनुअल';

  @override
  String waypointsCount(int count) {
    return 'वेपॉइंट ($count)';
  }

  @override
  String get noWaypointsYet => 'अभी कोई वेपॉइंट नहीं';

  @override
  String get waypointDetail => 'वेपॉइंट विवरण';

  @override
  String get selectWaypoint => 'वेपॉइंट चुनें';

  @override
  String get waypoint => 'वेपॉइंट';

  @override
  String get loiter => 'लोइटर';

  @override
  String get cropRice => 'चावल';

  @override
  String get cropWheat => 'गेहूँ';

  @override
  String get cropOther => 'अन्य';

  @override
  String get connectLiveKpp => 'लाइव K++ कनेक्ट करें';

  @override
  String get usbGround => 'USB (ग्राउंड)';

  @override
  String get comPort => 'COM पोर्ट';

  @override
  String get noComPort => 'कोई COM पोर्ट नहीं';

  @override
  String get refreshComPorts => 'COM पोर्ट रीफ़्रेश';

  @override
  String get baud => 'बॉड';

  @override
  String get disconnect => 'डिस्कनेक्ट';

  @override
  String get connectUsbToKpp => 'K++ से USB कनेक्ट';

  @override
  String get transmitterBtWifi => 'ट्रांसमीटर (ब्लूटूथ / WiFi)';

  @override
  String get airbornePath => 'एयरबॉर्न पथ — ऐप → ट्रांसमीटर → विमान';

  @override
  String get bluetooth => 'ब्लूटूथ';

  @override
  String get wifi => 'WiFi';

  @override
  String get bluetoothTransmitter => 'ब्लूटूथ ट्रांसमीटर';

  @override
  String get noBluetoothPort => 'कोई ब्लूटूथ पोर्ट नहीं';

  @override
  String get refreshBluetoothPorts => 'ब्लूटूथ पोर्ट रीफ़्रेश';

  @override
  String get showAllComPorts => 'सभी COM पोर्ट दिखाएँ';

  @override
  String get showAllComPortsHint =>
      'यदि TX पेयर है लेकिन ब्लूटूथ सूची में नहीं है';

  @override
  String get connectTransmitterBt => 'ट्रांसमीटर कनेक्ट (ब्लूटूथ)';

  @override
  String get disconnectTransmitter => 'ट्रांसमीटर डिस्कनेक्ट';

  @override
  String get g20Preset => 'G20 प्रीसेट';

  @override
  String get useGatewayIp => 'गेटवे IP उपयोग करें';

  @override
  String get refreshNetwork => 'नेटवर्क रीफ़्रेश';

  @override
  String get wifiMode => 'WiFi मोड';

  @override
  String get wifiModeTcp => 'ट्रांसमीटर AP पर TCP';

  @override
  String get wifiModeUdp => 'ट्रांसमीटर पर UDP';

  @override
  String get wifiModeUdpListen => 'UDP सुनें (GCS पोर्ट)';

  @override
  String get hostIp => 'होस्ट / IP';

  @override
  String get remotePort => 'रिमोट पोर्ट';

  @override
  String get localPort => 'लोकल पोर्ट';

  @override
  String get connectTransmitterWifi => 'ट्रांसमीटर कनेक्ट (WiFi)';

  @override
  String get autoTryWifi => 'WiFi ऑटो-ट्राई';

  @override
  String get phoneLandscapeTitle => 'लैंडस्केप में घुमाएँ';

  @override
  String get phoneLandscapeBody => 'यह ऐप लैंडस्केप ओरिएंटेशन के लिए है।';

  @override
  String get returnToLaunch => 'लॉन्च पर लौटें';

  @override
  String get lineSpacing => 'लाइन स्पेसिंग';

  @override
  String get coverageAdjust => 'कवरेज समायोजन';

  @override
  String get obstacleCircle => 'वृत्त';

  @override
  String get obstaclePolygon => 'बहुभुज';

  @override
  String get addObstacle => 'बाधा जोड़ें';

  @override
  String get deleteObstacle => 'बाधा हटाएँ';

  @override
  String get planHistory => 'प्लान इतिहास';

  @override
  String get imuCalibration => 'IMU कैलिब्रेशन';

  @override
  String get compassCalibration => 'कम्पास कैलिब्रेशन';

  @override
  String get accelCalibration => 'एक्सेलेरोमीटर कैलिब्रेशन';

  @override
  String get levelHorizon => 'क्षितिज समतल';

  @override
  String get startCalibration => 'शुरू';

  @override
  String get stopCalibration => 'रोकें';

  @override
  String get close => 'बंद करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get ok => 'ठीक';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get mapAttributionEsri => 'टाइल © Esri (छवि + स्थान लेबल)';

  @override
  String get mapAttributionOsm => '© OpenStreetMap योगदानकर्ता';

  @override
  String get digitalSkyEmbedBlocked =>
      'Digital Sky इस ऐप के अंदर नहीं खुलेगा। उनकी साइट अन्य वेबसाइटों को मानचित्र दिखाने से रोकती है।';

  @override
  String get digitalSkyDidNotLoad => 'Digital Sky लोड नहीं हुआ';

  @override
  String get openDigitalSky => 'Digital Sky खोलें';

  @override
  String get openDigitalSkyInBrowser => 'ब्राउज़र में Digital Sky खोलें';

  @override
  String get calibrationRadio => 'रेडियो';

  @override
  String get calibrationImu => 'IMU';

  @override
  String get calibrationCompass => 'कम्पास';

  @override
  String get calibrationStatusCalibrating => 'कैलिब्रेशन जारी…';

  @override
  String get calibrationStatusCalibrated => 'कैलिब्रेट';

  @override
  String get calibrationStatusNotCalibrated => 'कैलिब्रेट नहीं';

  @override
  String get startCalibrationFull => 'कैलिब्रेशन शुरू करें';

  @override
  String connectLiveLink(String link) {
    return 'लाइव लिंक: $link';
  }

  @override
  String get connectUsbIntro =>
      'जमीन पर सेटअप के लिए USB। उड़ान के लिए ऐप को ट्रांसमीटर से Bluetooth या WiFi से जोड़ें — कमांड: ऐप → TX → विमान।';

  @override
  String get connectWebUnsupported =>
      'यह वेब बिल्ड USB, Bluetooth या WiFi सॉकेट नहीं खोल सकता। Windows या Android ऐप चलाएँ।';

  @override
  String get transmitterPickHint =>
      'अपने ट्रांसमीटर के अनुसार Bluetooth या WiFi चुनें। ऊपर USB जमीन सेटअप के लिए वैसा ही रहता है।';

  @override
  String get btAbbrev => 'BT';

  @override
  String get transmitterIpHost => 'ट्रांसमीटर IP / होस्ट';

  @override
  String get tcpPort => 'TCP पोर्ट';

  @override
  String get remoteUdpPort => 'रिमोट UDP पोर्ट';

  @override
  String get localUdpPort => 'लोकल UDP पोर्ट';

  @override
  String get tryingWifiPorts => 'पोर्ट आज़माए जा रहे हैं…';

  @override
  String get autoTryWifiPorts => 'WiFi पोर्ट स्वतः आज़माएँ';

  @override
  String loadingParameters(int received, int total) {
    return 'पैरामीटर लोड $received/$total';
  }

  @override
  String get linkLostTransmitter =>
      'लिंक टूटा — ट्रांसमीटर पावर, Bluetooth/WiFi और रेंज जाँचें।';

  @override
  String get linkLostUsb => 'लिंक टूटा — USB केबल और FC पावर जाँचें।';

  @override
  String get connectLiveHint =>
      'USB: जमीन पर FC से जोड़ें। उड़ान: ऐप को ट्रांसमीटर (Bluetooth या WiFi) से जोड़ें; कमांड और टेलीमेट्री TX से विमान तक। मैनुअल ओवरराइड के लिए RC स्टिक रखें।';

  @override
  String get connectErrorUsbNeedsNative =>
      'लाइव K++ USB के लिए Windows या Android बिल्ड चाहिए — वेब सीरियल पोर्ट नहीं खोल सकती।';

  @override
  String get connectErrorNoComPort =>
      'कोई COM पोर्ट नहीं मिला। K++ USB डेटा केबल लगाएँ और रिफ्रेश करें।';

  @override
  String connectErrorInvalidPort(String label) {
    return 'मान्य $label दर्ज करें (1–65535)।';
  }

  @override
  String get connectErrorBluetoothNeedsNative =>
      'Bluetooth के लिए Windows या Android डेस्कटॉप/मोबाइल बिल्ड चाहिए।';

  @override
  String get connectErrorNoBluetoothSerial =>
      'कोई Bluetooth सीरियल पोर्ट नहीं। सिस्टम Bluetooth में ट्रांसमीटर पेयर करें, फिर रिफ्रेश। अगर फिर भी नहीं, «सभी COM पोर्ट दिखाएँ» चालू करें।';

  @override
  String get connectErrorWifiNeedsNative =>
      'ट्रांसमीटर WiFi के लिए Windows या Android बिल्ड चाहिए।';

  @override
  String get connectErrorEnterTxHost =>
      'ट्रांसमीटर WiFi IP / होस्टनाम दर्ज करें।';

  @override
  String get connectErrorNoWifiGateway =>
      'WiFi गेटवे नहीं मिला। पहले ट्रांसमीटर WiFi से जुड़ें।';

  @override
  String connectUsingGateway(String gateway) {
    return 'गेटवे $gateway उपयोग — «ट्रांसमीटर कनेक्ट (WiFi)» दबाएँ।';
  }

  @override
  String get connectWifiJoinFirst =>
      'पहले ट्रांसमीटर WiFi से जुड़ें, फिर पुनः प्रयास करें।';

  @override
  String connectWifiTcpSuccess(String host, String port) {
    return 'TX WiFi TCP $host:$port पर कनेक्ट';
  }

  @override
  String get connectWifiG20Success =>
      'Skydroid G20 TCP 192.168.43.1:5760 से कनेक्ट';

  @override
  String get connectWifiUdpListenSuccess =>
      'UDP 14550 सुन रहा है — TX/विमान चालू करें ताकि टेलीमेट्री भेजे।';

  @override
  String connectWifiAutoTryFailed(String detail) {
    return 'WiFi स्वतः प्रयास विफल।\n$detail\n\nSkydroid G20: WiFi मोड = TCP, IP 192.168.43.1, पोर्ट 5760। G20 पर WLAN hotspot और डेटा शेयरिंग चालू; विमान + GR01 लिंक (FC telem पोर्ट पर baud मिलान)।';
  }

  @override
  String get rtlCommandConfirm => 'लाइव ड्रोन को लॉन्च पर लौटने का आदेश दें?';

  @override
  String get connectUsbToKppFirst => 'पहले USB से K++ जोड़ें';

  @override
  String get noFlyZone => 'नो-फ्लाई ज़ोन';

  @override
  String get orientation => 'अभिविन्यास';

  @override
  String get autoAlign => 'स्वतः संरेखण';

  @override
  String get edgeMargin => 'किनारे की दूरी';

  @override
  String get operationMode => 'संचालन मोड';

  @override
  String get sprayOn => 'स्प्रे चालू';

  @override
  String get sprayOff => 'स्प्रे बंद';

  @override
  String get latitude => 'अक्षांश';

  @override
  String get longitude => 'देशांतर';

  @override
  String get action => 'क्रिया';

  @override
  String get selectCrop => 'फसल चुनें';

  @override
  String get sprayRate => 'स्प्रे दर';

  @override
  String get notes => 'नोट';

  @override
  String get name => 'नाम';

  @override
  String get defaultMissionName => 'मिशन';

  @override
  String uploadFlyConfirmMessage(int count, String meters) {
    return 'लाइव K++ पर $count वेपॉइंट अपलोड, जरूरत हो तो आर्म और Auto शुरू (टेकऑफ $meters m)?';
  }

  @override
  String get missionUploadedSuccess =>
      'मिशन अपलोड — स्थानीय सहेजा और लाइव K++ पर Auto शुरू';

  @override
  String get missionSavedToDatabase => 'मिशन डेटाबेस में सहेजा';

  @override
  String get noSavedMissions => 'कोई सहेजा मिशन नहीं';

  @override
  String get connectKppUsbFirst => 'पहले USB से लाइव K++ जोड़ें';

  @override
  String get enterMeterVoltageInMaxVoltage =>
      'अधिकतम वोल्टेज में मीटर वोल्टेज दर्ज करें';

  @override
  String get battVoltMultWritten => 'BATT_VOLT_MULT लाइव K++ पर लिखा';

  @override
  String savedLocallyFcSyncFailed(String error) {
    return 'स्थानीय सहेजा; FC सिंक विफल: $error';
  }

  @override
  String get mapHintTapPlacePointA =>
      'बिंदु A रखने के लिए मानचित्र पर टैप करें';

  @override
  String get mapHintTapPlacePointB =>
      'बिंदु B रखने के लिए मानचित्र पर टैप करें';

  @override
  String get mapHintTapBoundaryForSplit => 'चुने बिंदु के लिए सीमा पर टैप करें';

  @override
  String get mapHintTapAddBoundaryPoint =>
      'सीमा बिंदु जोड़ने के लिए मानचित्र पर टैप करें';

  @override
  String get splitChoosePointsHint =>
      'पहला या अंतिम बिंदु चुनें, फिर सीमा बिंदु या सीमा पर कहीं टैप करें।';

  @override
  String get chooseCircleOrPolygon => 'वृत्त या बहुभुज चुनें';

  @override
  String get tapInsideFieldPlaceCircle =>
      'वृत्त रखने के लिए खेत के अंदर टैप करें।';

  @override
  String get tapMapPlaceCornersInOrder =>
      'क्रम से प्रत्येक कोना रखने के लिए मानचित्र पर टैप करें।';
}
