// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class KppLocalizationsHi extends KppLocalizations {
  KppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Fuselage-K++';

  @override
  String get groupBasic => 'बेसिक';

  @override
  String get groupAdvanced => 'उन्नत';

  @override
  String get groupTools => 'टूल्स';

  @override
  String get groupFly => 'उड़ान';

  @override
  String get destOverview => 'स्थिति';

  @override
  String get destInstallation => 'इंस्टॉलेशन';

  @override
  String get destRemoteControl => 'रिमोट कंट्रोल';

  @override
  String get destSensors => 'सेंसर';

  @override
  String get destFlight => 'मोटर और उड़ान';

  @override
  String get destGains => 'गेन्स';

  @override
  String get destProtection => 'सुरक्षा';

  @override
  String get destPump => 'पंप';

  @override
  String get destLiquid => 'तरल स्तर';

  @override
  String get destSpraying => 'AB स्प्रेइंग';

  @override
  String get destFence => 'फेंस';

  @override
  String get destExtensions => 'एक्सटेंशन';

  @override
  String get destChannels => 'चैनल मैपिंग';

  @override
  String get destMission => 'मिशन';

  @override
  String get destLogs => 'फ्लाइट लॉग';

  @override
  String get destParameters => 'सभी पैरामीटर';

  @override
  String get destFirmware => 'फर्मवेयर और परिचय';

  @override
  String get mapFly => 'मानचित्र / उड़ान';

  @override
  String get groundPlan => 'ग्राउंड प्लान';

  @override
  String get home => 'होम';

  @override
  String get language => 'भाषा';

  @override
  String get overviewDescription =>
      'फ्लाइट कंट्रोलर और उसके मॉड्यूल की लाइव स्थिति (K++ असिस्टेंट लेआउट)।';

  @override
  String get sensors => 'सेंसर';

  @override
  String get imu => 'IMU';

  @override
  String get gps => 'GPS';

  @override
  String get gps1 => 'GPS1';

  @override
  String get gps1Sats => 'GPS1 उपग्रह';

  @override
  String get gps2 => 'GPS2';

  @override
  String get gps2Sats => 'GPS2 उपग्रह';

  @override
  String get position => 'स्थिति';

  @override
  String get altitude => 'ऊँचाई';

  @override
  String get hdop => 'HDOP';

  @override
  String get powerAndLink => 'पावर और लिंक';

  @override
  String get batteryVoltage => 'बैटरी वोल्टेज';

  @override
  String get rcSignal => 'RC सिग्नल';

  @override
  String get link => 'लिंक';

  @override
  String get firmwareVersion => 'फर्मवेयर संस्करण';

  @override
  String get softwareRevision => 'सॉफ़्टवेयर रिवीज़न';

  @override
  String get parameters => 'पैरामीटर';

  @override
  String get fcMessage => 'फ्लाइट कंट्रोलर संदेश';

  @override
  String get statusNormal => 'सामान्य';

  @override
  String get statusFault => 'फॉल्ट';

  @override
  String get statusNotConnected => 'कनेक्ट नहीं';

  @override
  String get port => 'पोर्ट';

  @override
  String get baud => 'बॉड';

  @override
  String get connect => 'कनेक्ट';

  @override
  String get disconnect => 'डिस्कनेक्ट';

  @override
  String get bluetooth => 'ब्लूटूथ';

  @override
  String get wifi => 'WiFi';

  @override
  String get refreshComPorts => 'COM पोर्ट रीफ़्रेश करें';

  @override
  String get refreshBluetoothPorts => 'ब्लूटूथ पोर्ट रीफ़्रेश करें';

  @override
  String get setMode => 'मोड सेट करें';

  @override
  String get flightModeAuto => 'ऑटो';

  @override
  String get flightModeGuided => 'Guided';

  @override
  String get flightModeLoiter => 'Loiter';

  @override
  String get flightModeRtl => 'RTL';

  @override
  String get flightModeLand => 'लैंड';

  @override
  String get defaultAlt => 'डिफ़ॉल्ट ऊँचाई';

  @override
  String get abSpray => 'AB स्प्रे';

  @override
  String get download => 'डाउनलोड';

  @override
  String get upload => 'अपलोड';

  @override
  String get clear => 'साफ़';

  @override
  String get import => 'आयात';

  @override
  String get export => 'निर्यात';

  @override
  String get cancel => 'रद्द';

  @override
  String get ok => 'ठीक';

  @override
  String get altitudeM => 'ऊँचाई (m)';

  @override
  String missionItemsHint(int count) {
    return '$count आइटम — वेपॉइंट जोड़ने के लिए मानचित्र टैप करें';
  }

  @override
  String get setA => 'A सेट';

  @override
  String get setB => 'B सेट';

  @override
  String get tapMapForFence => 'बाड़ के लिए मानचित्र टैप…';

  @override
  String get enableCircleFence => 'वृत्त बाड़ सक्षम';

  @override
  String get editAltitude => 'ऊँचाई संपादित';

  @override
  String get missionDownloaded => 'मिशन डाउनलोड';

  @override
  String get missionUploaded => 'मिशन अपलोड';

  @override
  String get missionCleared => 'मिशन साफ़';

  @override
  String get rtlAccepted => 'RTL स्वीकृत';

  @override
  String get landAccepted => 'लैंड स्वीकृत';

  @override
  String modeSet(String mode) {
    return 'मोड $mode सेट';
  }

  @override
  String get setPointsAbFirst => 'पहले मानचित्र पर बिंदु A और B सेट करें';

  @override
  String abSprayGenerated(int count) {
    return 'AB स्प्रे पैटर्न ($count आइटम)';
  }

  @override
  String fenceCircleEnabled(String radius) {
    return 'वृत्त बाड़ सक्षम, त्रिज्या $radius m (उड़ान में विमान पर केंद्रित)';
  }

  @override
  String exportedTo(String path) {
    return 'निर्यात $path';
  }

  @override
  String importedItems(int count) {
    return '$count आइटम आयात';
  }

  @override
  String get rtl => 'RTL';

  @override
  String get land => 'लैंड';

  @override
  String get armed => 'ARMED';

  @override
  String get disarmed => 'Disarmed';

  @override
  String get notConnected => 'संबद्ध नहीं';

  @override
  String get notConnectedHint =>
      'ऊपर और प्रेस कनेक्ट में एक COM पोर्ट (या सिम्युलेटर) चुनें।';

  @override
  String get cardFrameType => 'फ्रेम प्रकार';

  @override
  String get frameTypeSubtitle =>
      'K++ सहायक के समान: पीला हाथ = नाक, M1-M8 = FC पोर्ट, लाल CW / नीला CCW = प्रोपेलर स्पिन। FRAME और SHAPE लिखते हैं।';

  @override
  String get cardImuGpsMounting => 'IMU & GPS माउंटिंग';

  @override
  String get installationDescription =>
      'मॉड्यूल को कैसे माउंट किया जाता है, उससे मिलान करने के लिए निर्देश चुनें और सेंटीमीटर (नीले जोन नेगेटिव, येलो जोन पॉजिटिव) में ग्रेविटी के एयरफ्रेम सेंटर से अपनी ऑफसेट में प्रवेश करें।';

  @override
  String get remoteControlDescription =>
      'यह सुनिश्चित करने के लिए कि असफल सुरक्षित सही ढंग से सेट किया गया है, इसे बदलने के बाद RC को बंद करें और चेक करें कि चैनल 1-4 केंद्र में कूदते हैं (लगभग 1500) और चैनल 5 अपनी असफल सुरक्षित स्थिति में कूदते हैं।';

  @override
  String get cardRcSettingsFailsafe => 'RC सेटिंग्स';

  @override
  String get stickCalibration => 'स्टिक कैलिब्रेशन';

  @override
  String get stickCalibrationIdle =>
      'वर्तमान समापन बिंदु नीचे दिखाया गया है। चैनल 1-4 को पुनः प्राप्त करना शुरू करें।';

  @override
  String get stickCalibrationExtremes =>
      'प्रत्येक छड़ी को अपने अधिकतम और न्यूनतम कई बार पुश करें, फिर अगला दबाएं।';

  @override
  String get stickCalibrationCentre =>
      'प्रत्येक छड़ी को केंद्र में छोड़ दें, फिर कैप्चर सेंटर दबाएं।';

  @override
  String get stickCalibrationReview =>
      'परिणाम की जाँच करें, फिर उन्हें उड़ान नियंत्रक को बचाएं।';

  @override
  String get startCalibration => 'अंशांकन';

  @override
  String get captureCentre => 'कैप्चर सेंटर';

  @override
  String get saveCalibration => 'अंशांकन';

  @override
  String get next => 'अगला';

  @override
  String get channel => 'चैनल';

  @override
  String get min => 'मिन';

  @override
  String get centre => 'केंद्र';

  @override
  String get max => 'मैक्स';

  @override
  String get channelMonitor => 'चैनल मॉनिटर';

  @override
  String get sensorsImuCompassSubtitle =>
      'प्रत्येक IMU उदाहरण से रॉ सेंसर मान।';

  @override
  String get cardImuCompass => 'IMU & compass';

  @override
  String get cardBarometer => 'बैरोमीटर';

  @override
  String get noBarometerData => 'कोई बैरोमीटर डेटा नहीं';

  @override
  String get imuLevelCalibration => 'IMU स्तर अंशांकन';

  @override
  String get imuLevelCalibrationSubtitle =>
      'उड़ान नियंत्रक को ऊपर और स्तर पर रखें, फिर कैलिब्रेट करें।';

  @override
  String get compassCalibration => 'कम्पास अंशांकन';

  @override
  String get compassCalibrationSubtitle =>
      'विमान स्तर और दक्षिणावर्त घुमाएं, फिर नाक-डाउन और दक्षिणावर्त।';

  @override
  String get cardGlobalFlightLimits => 'वैश्विक उड़ान सीमा और मोटर निष्क्रिय';

  @override
  String get motorTest => 'मोटर परीक्षण';

  @override
  String get motorTestSubtitle =>
      'प्रत्येक मोटर को व्यक्तिगत रूप से ऑर्डर और दिशा की जांच करने के लिए स्पिन करता है।';

  @override
  String get removePropellers => 'प्रोपेलर निकालें';

  @override
  String get startTest => 'प्रारंभ परीक्षण';

  @override
  String motorTestConfirmMessage(int motor, String throttle, String seconds) {
    return 'मोटर परीक्षण $seconds s के लिए $throttle% पर M$motor स्पिन करेगा।\nप्रोपेलर की पुष्टि की जाती है और विमान सुरक्षित है।';
  }

  @override
  String get testingMotors => 'परीक्षण...';

  @override
  String get testMotors => 'टेस्ट मोटर्स';

  @override
  String get calibrateImu => 'Calibrate IMU';

  @override
  String get calibratingImu => 'कैलिब्रेटिंग ...';

  @override
  String get calibrateCompass => 'कैलिब्रेट कम्पास';

  @override
  String get calibratingCompass => 'कैलिब्रेटिंग ...';

  @override
  String get gainsDescription =>
      'नियंत्रण लाभ पायलट के अनुभव को निर्धारित करते हैं: उच्च मान तेजी से जवाब देते हैं लेकिन अधिक शक्ति की आवश्यकता होती है। केवल कंपन दमन की ओर प्रदर्शन प्रवृत्ति को स्थानांतरित करें यदि एयरफ्रेम वाइसिबली शेक्स या मोटर्स ध्वनि शोर।';

  @override
  String protectionDescription(String voltage) {
    return 'वर्तमान वोल्टेज: $voltage स्तर 2 को स्तर 1 से कम होना चाहिए; दोनों स्तरों में रोशनी भी दिखाई देती है।';
  }

  @override
  String barometerReading(String pressure, String temperature) {
    return 'दबाव $pressure . एचपीए · तापमान $temperature °C';
  }

  @override
  String get cardBasicGains => 'बुनियादी लाभ';

  @override
  String get cardControlGains => 'नियंत्रण लाभ';

  @override
  String get cardSpeedSensitivity => 'गति और संवेदनशीलता';

  @override
  String get cardVoltageRtlLanding => 'वोल्टेज, घर वापसी और लैंडिंग';

  @override
  String get voltageCalibration => 'वोल्टेज अंशांकन';

  @override
  String get voltageCalibrationSubtitle =>
      'एक मीटर के साथ मापा वोल्टेज दर्ज करें इसलिए एफसी रीडिंग इसे मैच करती है।';

  @override
  String get meterVoltageV => 'मीटर वोल्टेज (V)';

  @override
  String get calibrateVoltage => 'कैलिब्रेट वोल्टेज';

  @override
  String get cardPump => 'पम्प';

  @override
  String get cardLevelSensorProtection => 'लेवल सेंसर & प्रोटेक्शन';

  @override
  String get cardAbJobSettings => 'AB नौकरी सेटिंग';

  @override
  String get cardAbJobProcedure => 'AB नौकरी प्रक्रिया';

  @override
  String get fenceDescription =>
      'सर्कल और ऊंचाई सीमा। मिशन मानचित्र से सर्कल को ड्रॉ / समायोजित करें, या यहां मूल्यों को निर्धारित करें।';

  @override
  String get cardQuickFence => 'त्वरित बाड़';

  @override
  String get fenceEnabled => 'बाड़ सक्षम है';

  @override
  String get fenceOff => 'बाड़ बंद है';

  @override
  String get enableAltitudeAndCircle => 'ऊंचाई + सर्कल सक्षम करें';

  @override
  String get disableFence => 'बाड़ लगाना';

  @override
  String get cardHeightDistanceLimits => 'ऊंचाई और दूरी सीमा';

  @override
  String get cardRtkAntenna => 'RTK एंटीना';

  @override
  String rtkCurrentPositioning(String fix) {
    return 'वर्तमान स्थिति: $fix';
  }

  @override
  String get cardRadarVision4g => 'रडार, दृष्टि और 4 जी मॉड्यूल स्थिति';

  @override
  String get extensionsRadarStatusDescription =>
      'Terrain-following radar ऊंचाई, बाधा रडार दूरी, दृष्टि मॉड्यूल राज्य और आईओटी सिम स्थिति यहां K++ सहायक में दिखाया गया है।';

  @override
  String get channelsDescription =>
      'यह देखने के लिए चैनल मॉनिटर की जाँच करें कि आपके RC कार्यों को सौंपने से पहले किस चैनल का उपयोग करता है।';

  @override
  String get cardChannelFunctions => 'चैनल फ़ंक्शन';

  @override
  String get flightLogsDescription =>
      'डाउनलोड किए गए लॉग दस्तावेज़ \\Fuselage-K++\\logs के लिए सहेजे जाते हैं।';

  @override
  String get refreshList => 'ताज़ा सूची';

  @override
  String logsOnFlightController(int count) {
    return '$count उड़ान नियंत्रक पर लॉग इन करता है';
  }

  @override
  String parametersDescription(int count) {
    return '$count पैरामीटर उड़ान नियंत्रक से पढ़ा गया।';
  }

  @override
  String get parameterFiles => 'पैरामीटर फाइलें';

  @override
  String get reloadFromFc => 'FC से Reload';

  @override
  String get searchByIdOrName => 'आईडी या नाम से खोजें';

  @override
  String parametersShown(int count) {
    return '$count दिखाया गया';
  }

  @override
  String get paramColumnId => 'आईडी';

  @override
  String get paramColumnName => 'नाम';

  @override
  String get paramColumnValue => 'मूल्य';

  @override
  String get paramFormHint =>
      'एक मान टाइप करें और प्रेस इसे फ्लाइट कंट्रोलर में लिखने के लिए एंटर करें।';

  @override
  String get paramNotReported => 'इस उड़ान नियंत्रक द्वारा रिपोर्ट नहीं की गई';

  @override
  String paramUnknownOption(String value) {
    return 'अज्ञात ($value)';
  }

  @override
  String get enterNumber => 'नंबर दर्ज करें';

  @override
  String get writeToFlightControllerTitle => 'उड़ान नियंत्रक को लिखें?';

  @override
  String get write => 'लिखना';

  @override
  String get cardVersions => 'संस्करण';

  @override
  String get cardVersionsAuthorisation => 'संस्करण और प्राधिकरण';

  @override
  String get firmwareUpgrade => 'फर्मवेयर अपग्रेड';

  @override
  String get firmwareUpgradeDescription =>
      'उड़ान नियंत्रक बूटलोडर के माध्यम से K++ V2 / KX / P3 फर्मवेयर अपलोड करें। अपग्रेड करते समय डिवाइस को कभी भी हटा दें।';

  @override
  String get upgradeFirmware => 'फर्मवेयर अपग्रेड';

  @override
  String get factoryReset => 'फैक्टरी रीसेट';

  @override
  String get factoryResetDescription =>
      'प्रत्येक पैरामीटर को फैक्ट्री डिफ़ॉल्ट में पुनर्स्थापित करें।';

  @override
  String get restoreFactorySettings => 'फैक्टरी सेटिंग बहाल करें';

  @override
  String get droneRegistration => 'ड्रोन पंजीकरण';

  @override
  String get droneRegistrationDescription =>
      'निर्माता का नाम, विमान मॉडल और विमान संख्या (网络备案)।';

  @override
  String get shape => 'आकार';

  @override
  String validateMinimum(String value) {
    return 'न्यूनतम $value';
  }

  @override
  String validateMaximum(String value) {
    return 'अधिकतम $value';
  }

  @override
  String get validateChooseOption => 'सूचीबद्ध विकल्पों में से एक चुनें';

  @override
  String get instance => 'इंस्टेंस';

  @override
  String get accelAxes => 'एक्स / वाई / जेड';

  @override
  String get gyroAxes => 'Gyro X / Y / Z';

  @override
  String get compassAxes => 'Compass X / Y / Z';

  @override
  String get comingSoon => 'जल्द ही';

  @override
  String get channelMonitorNoData => 'अभी तक कोई RC डेटा प्राप्त नहीं हुआ।';

  @override
  String get channelMonitorHint =>
      'प्रत्येक चैनल को देखने के लिए छड़ी और स्विच ले जाएँ।';

  @override
  String duplicateChannelFunctions(String details) {
    return 'डुप्लिकेट चैनल कार्य: $details';
  }

  @override
  String get logColumnNo => 'नहीं';

  @override
  String get logColumnTimeUtc => 'समय (UTC)';

  @override
  String get logColumnSizeBytes => 'आकार (bytes)';

  @override
  String get logReview => 'समीक्षा';

  @override
  String logSavedTo(int id, String path) {
    return '$id ने $path को बचाया';
  }

  @override
  String motorThrottlePercent(String percent) {
    return 'थ्रॉटल $percent%';
  }

  @override
  String motorDurationSeconds(String seconds) {
    return 'अवधि ${seconds}S';
  }

  @override
  String motorTestAccepted(int motor) {
    return 'M$motor परीक्षण स्वीकृत';
  }

  @override
  String motorTestFailed(String error) {
    return 'मोटर परीक्षण विफल रहा: $error';
  }

  @override
  String get imuCalibrationAccepted => 'IMU अंशांकन स्वीकृत';

  @override
  String imuCalibrationFailed(String error) {
    return 'IMU अंशांकन विफल: $error';
  }

  @override
  String get compassCalibrationStarted => 'कम्पास अंशांकन शुरू';

  @override
  String compassCalibrationFailed(String error) {
    return 'Compass calibration विफल: $error';
  }

  @override
  String paramSaved(String id, String value) {
    return '$id बचाया: $value';
  }

  @override
  String paramNotSaved(String id, String error) {
    return '$id नहीं बचाया: $error';
  }

  @override
  String paramsSavedCount(int count) {
    return '$count मापदंडों को बचाया';
  }

  @override
  String paramsSavedPartial(int saved, int failed, String ids) {
    return '$saved बचाया, $failed विफल: $ids';
  }

  @override
  String stickCalibrationInvalid(String channels) {
    return 'चैनल मिनट/अधिकतम सीमा से बाहर: $channels. अंशांकन विफल रहा - फिर से प्रयास करें।';
  }

  @override
  String fcReadingAndMultiplier(String reading, String mult) {
    return 'FC रीडिंग: $reading · बहुसंख्यक: $mult';
  }

  @override
  String get enterValidMeterVoltage => 'एक मान्य मीटर वोल्टेज दर्ज करें';

  @override
  String get noBatteryVoltageYet =>
      'उड़ान नियंत्रक से अभी तक कोई बैटरी वोल्टेज नहीं';

  @override
  String logParseFailed(String error) {
    return '$error';
  }

  @override
  String get logParseFailedHint =>
      'संपूर्ण विश्लेषण के लिए बाहरी रूप से .bin खोलें।';

  @override
  String get logNoTrackSamples =>
      'No GPS/ATT नमूने इस लॉग में मान्यता प्राप्त है।';

  @override
  String get plotNoSamples => 'कोई नमूने नहीं';

  @override
  String plotMinMax(String min, String max) {
    return '$min';
  }

  @override
  String exportParametersTo(int count, String path) {
    return '$path के लिए $count मापदंडों का निर्यात किया गया';
  }

  @override
  String importFileFormatError(String message) {
    return 'फ़ाइल प्रारूप त्रुटि: $message';
  }

  @override
  String get importNothingMatches =>
      'आयात करने के लिए कुछ नहीं: प्रत्येक मूल्य पहले से ही उड़ान नियंत्रक से मेल खाता है।';

  @override
  String fcFirmwareInfo(String version) {
    return 'फ्लाइट कंट्रोलर फर्मवेयर: $version';
  }

  @override
  String get appAboutLine =>
      'Fuselage-K++ 1.0.0 - JIYI K++ सहायक (JIYI221014) को बदलने के लिए बनाया गया।';

  @override
  String get sprayProcedure1Title => 'रिकॉर्ड बिंदु A';

  @override
  String get sprayProcedure1Detail =>
      'AB रिकॉर्ड स्विच को मध्य स्थिति में फ्लिप करें।';

  @override
  String get sprayProcedure2Title => 'रिकॉर्ड प्वाइंट बी';

  @override
  String get sprayProcedure2Detail =>
      'AB रिकॉर्ड स्विच को उच्च स्थिति में फ्लिप करें।';

  @override
  String get sprayProcedure3Title => 'AB नौकरी शुरू करें';

  @override
  String get sprayProcedure3Detail =>
      'AB स्विच को चालू करें (या AB एक उड़ान मोड के रूप में निष्पादित)।';

  @override
  String get sprayProcedure4Title => 'दिशा';

  @override
  String get sprayProcedure4Detail =>
      'रोल को काम करने के लिए पक्ष की ओर धकेलें।';

  @override
  String get sprayProcedure5Title => 'A और B';

  @override
  String get sprayProcedure5Detail =>
      'AB रिकॉर्ड को जल्दी और जल्दी से वापस घुमाएं।';

  @override
  String get sprayProcedure6Title => 'फिर से भरना';

  @override
  String get sprayProcedure6Detail =>
      'A/B समाशोधन के बिना, AB को चालू करें: काम अंतिम खाली टैंक बिंदु और दिशा से फिर से शुरू होता है।';

  @override
  String get waitingForProtocolConfirmation =>
      'प्रोटोकॉल की पुष्टि के लिए प्रतीक्षा करना';

  @override
  String get pendingFeatureBody =>
      'K++ सहायक इसके लिए JIYI-विशिष्ट कमांड का उपयोग करता है, मानक MAVLink नहीं। यह निष्क्रिय रहता है जब तक कि मूल ऐप की रिकॉर्डिंग सटीक संदेश की पुष्टि नहीं करती है, इसलिए असीमित उड़ान नियंत्रक को कभी नहीं भेजा जाता है।';

  @override
  String get optForward => 'आगे';

  @override
  String get optRight => 'अधिकार';

  @override
  String get optBackward => 'पिछड़ा';

  @override
  String get optLeft => 'बाएं';

  @override
  String get optOff => 'बंद';

  @override
  String get optOn => 'पर';

  @override
  String get optSinglePump => 'एकल पंप';

  @override
  String get optDoublePump => 'डबल पंप';

  @override
  String get optQuadX => 'क्वाड X';

  @override
  String get optQuadPlus => 'क्वाड +';

  @override
  String get optHexaX => 'हेक्सा X';

  @override
  String get optHexaPlus => 'हेक्सा +';

  @override
  String get optOctoX => 'अक्टूबर';

  @override
  String get optOctoPlus => 'ऑक्टा +';

  @override
  String get optStandard => 'मानक';

  @override
  String get optCoaxial => 'समाक्षीय';

  @override
  String get optY6 => 'Y6';

  @override
  String get optAltitude => 'ऊंचाई';

  @override
  String get optAltitudeCircle => 'ऊंचाई + सर्कल';

  @override
  String get optCircle => 'सर्कल';

  @override
  String get pLabel_FRAME => 'फ्रेम प्रकार';

  @override
  String get pLabel_SHAPE => 'फ्रेम आकार';

  @override
  String get pLabel_NAV_IMU_ORIENT => 'IMU दिशा';

  @override
  String get pLabel_NAV_COMP_ORIENT => 'GPS दिशा';

  @override
  String get pLabel_NAV_IMU_POS_X => 'IMU स्थिति X';

  @override
  String get pLabel_NAV_IMU_POS_Y => 'IMU स्थिति Y';

  @override
  String get pLabel_NAV_IMU_POS_Z => 'IMU स्थिति Z';

  @override
  String get pLabel_NAV_GPS3_POS_X => 'GPS स्थिति X';

  @override
  String get pLabel_NAV_GPS3_POS_Y => 'GPS स्थिति Y';

  @override
  String get pLabel_NAV_GPS3_POS_Z => 'GPS स्थिति Z';

  @override
  String get pLabel_NAV_IMU_SOURCE => 'IMU स्रोत';

  @override
  String get pLabel_RC_TYPE => 'RC प्रकार';

  @override
  String get pLabel_FS_THR_ENABLE => 'RC-हानि असफल सुरक्षित कार्रवाई';

  @override
  String get pLabel_RC_FS_CONTINUE => 'पढ़ना जारी रखें जब RC खो गया है';

  @override
  String get pLabel_THR_DZ => 'थ्रोटल मिड डेड जोन';

  @override
  String get pLabel_FLTMODE1 => 'उड़ान मोड 1';

  @override
  String get pLabel_FLTMODE2 => 'उड़ान मोड 2';

  @override
  String get pLabel_FLTMODE3 => 'उड़ान मोड 3';

  @override
  String get pLabel_FLTMODE4 => 'उड़ान मोड 4';

  @override
  String get pLabel_FLTMODE5 => 'उड़ान मोड 5';

  @override
  String get pLabel_FLTMODE6 => 'उड़ान मोड 6';

  @override
  String get pLabel_RC1_MIN => 'CH1 min';

  @override
  String get pLabel_RC1_MAX => 'CH1 अधिकतम';

  @override
  String get pLabel_RC1_TRIM => 'CH1 ट्रिम';

  @override
  String get pLabel_RC2_MIN => 'CH2 min';

  @override
  String get pLabel_RC2_MAX => 'CH2 अधिकतम';

  @override
  String get pLabel_RC2_TRIM => 'CH2 ट्रिम';

  @override
  String get pLabel_RC3_MIN => 'CH3 min';

  @override
  String get pLabel_RC3_MAX => 'CH3 अधिकतम';

  @override
  String get pLabel_RC3_TRIM => 'CH3 ट्रिम';

  @override
  String get pLabel_RC4_MIN => 'CH4 min';

  @override
  String get pLabel_RC4_MAX => 'CH4 अधिकतम';

  @override
  String get pLabel_RC4_TRIM => 'CH4 ट्रिम';

  @override
  String get pLabel_ANGLE_MAX => 'अधिकतम झुकाव कोण';

  @override
  String get pLabel_WPNAV_LOIT_SPEED => 'अधिकतम क्षैतिज गति';

  @override
  String get pLabel_PILOT_VELZ_UP => 'अधिकतम चढ़ाई गति';

  @override
  String get pLabel_PILOT_VELZ_DOWN => 'मैक्स।';

  @override
  String get pLabel_MOT_SPIN_ARMED => 'मोटर निष्क्रिय गति';

  @override
  String get pLabel_GAIN_BASIC_R_PI => 'रोल सुधार';

  @override
  String get pLabel_GAIN_BASIC_R_D => 'रोल भिगोना';

  @override
  String get pLabel_GAIN_BASIC_P_PI => 'पिच सुधार';

  @override
  String get pLabel_GAIN_BASIC_P_D => 'पिच भिगोना';

  @override
  String get pLabel_GAIN_BASIC_YAW => 'या';

  @override
  String get pLabel_GAIN_BASIC_THR => 'शक्ति (vertical)';

  @override
  String get pLabel_GAIN_CONTROL_RP => 'रोल / पिच';

  @override
  String get pLabel_GAIN_CONTROL_YAW => 'या';

  @override
  String get pLabel_GAIN_CONTROL_THR => 'कार्यक्षेत्र';

  @override
  String get pLabel_GAIN_CONTROL_WP => 'मार्ग';

  @override
  String get pLabel_GAIN_CONTROL_MOV => 'Manoeuvre';

  @override
  String get pLabel_GAIN_CONTROL_BRA => 'ब्रेक';

  @override
  String get pLabel_GAIN_CONTROL_SCA => 'समन्वय';

  @override
  String get pLabel_GAIN_CONTROL_TKO => 'टेक-ऑफ';

  @override
  String get pLabel_GAIN_VEL_XY => 'क्षैतिज गति लाभ';

  @override
  String get pLabel_GAIN_VEL_Z => 'ऊर्ध्वाधर गति लाभ';

  @override
  String get pLabel_GAIN_SEN_ATT => 'दृष्टिकोण संवेदनशीलता';

  @override
  String get pLabel_GAIN_PERFORMANCE => 'प्रदर्शन प्रवृत्ति';

  @override
  String get pLabel_FS_BATT_ENABLE => 'कम वोल्टेज संरक्षण कार्रवाई';

  @override
  String get pLabel_FS_BATT_WARNING => 'स्तर 1 अलार्म वोल्टेज';

  @override
  String get pLabel_FS_BATT_VOLTAGE => 'स्तर 2 अलार्म वोल्टेज';

  @override
  String get pLabel_FS_PMU_ENABLE => 'PMU गलती संरक्षण';

  @override
  String get pLabel_RTL_ALT => 'रिटर्न-होम ऊंचाई';

  @override
  String get pLabel_LAND_SPEED => 'लैंडिंग गति';

  @override
  String get pLabel_SPRAY_PUMP_TYPE => 'पम्प प्रकार';

  @override
  String get pLabel_LIQUID_TYPE => 'स्तर सेंसर प्रकार';

  @override
  String get pLabel_FS_LIQ_ENABLE => 'बाहरी सुरक्षा';

  @override
  String get pLabel_ABPOINT_DIS => 'AB चौड़ाई';

  @override
  String get pLabel_ABPOINT_SPEED => 'AB गति';

  @override
  String get pLabel_WPNAV_ENABLE_U => 'यू के आकार का साइड शिफ्ट';

  @override
  String get pLabel_FENCE_ENABLE => 'बाड़ सक्षम';

  @override
  String get pLabel_FENCE_TYPE => 'बाड़ प्रकार';

  @override
  String get pLabel_FENCE_ALT_MAX => 'ऊंचाई सीमा';

  @override
  String get pLabel_FENCE_RADIUS => 'दूरी सीमा ( त्रिज्या)';

  @override
  String get pLabel_FENCE_ACTION => 'बाड़ उल्लंघन कार्रवाई';

  @override
  String get pLabel_RTK_ANTI_DEG => 'RTK एंटीना स्थापित कोण';

  @override
  String get pLabel_CH6_OPT => 'चैनल 6 फ़ंक्शन';

  @override
  String get pLabel_CH7_OPT => 'चैनल 7 समारोह';

  @override
  String get pLabel_CH8_OPT => 'चैनल 8 फ़ंक्शन';

  @override
  String get pLabel_CH9_OPT => 'चैनल 9 फ़ंक्शन';

  @override
  String get pLabel_CH10_OPT => 'चैनल 10 समारोह';

  @override
  String get pLabel_CH11_OPT => 'चैनल 11 समारोह';

  @override
  String get pLabel_CH12_OPT => 'चैनल 12 समारोह';

  @override
  String get pLabel_BATT_VOLT_MULT => 'बैटरी वोल्टेज गुणक';

  @override
  String get pLabel_FWVERSION => 'फर्मवेयर संस्करण';

  @override
  String get pLabel_SYSID_SW_MREV => 'सॉफ्टवेयर संशोधन';

  @override
  String get pLabel_INS_CAL_TYPE => 'IMU अंशांकन राज्य';

  @override
  String get pLabel_COMPASS_CAL_TYPE => 'कम्पास अंशांकन राज्य';

  @override
  String get pLabel_REG_ENABLE => 'ऐप अनलॉक अधिकृत';

  @override
  String get helpBasicGain =>
      'रेंज 0-200 %। नियंत्रक को एयरफ्रेम में अनुकूलित करता है।';

  @override
  String get helpControlGain =>
      'रेंज 0-300 %। उच्च = तेज प्रतिक्रिया; एयरफ्रेम की शक्ति से सीमित।';

  @override
  String get helpMode =>
      'K++ विकल्पों में मैनुअल जॉब, AB निष्पादित, रूट जॉब, GPS गति, साइड शिफ्ट और टेरेन फॉलो शामिल हैं। मूल्य मानचित्रण अभी तक पुष्टि नहीं हुई है।';

  @override
  String get helpChannel =>
      'समारोह इस RC चैनल को सौंपा गया। प्रत्येक फ़ंक्शन का उपयोग एक बार किया जाना चाहिए; बदलने से पहले चैनल मॉनिटर की जांच करें।';

  @override
  String get help_0 =>
      'K++ बस पर FRAME के रूप में मोटर गिनती और लेआउट लिखा गया।';

  @override
  String get help_1 =>
      'गुरुत्वाकर्षण के केंद्र से ऑफसेट। ब्लू जोन = नकारात्मक, पीला जोन = सकारात्मक।';

  @override
  String get help_2 =>
      'रिसीवर प्रोटोकॉल। मूल्य मानचित्रण अभी तक पुष्टि नहीं हुई है।';

  @override
  String get help_3 =>
      'K++ विकल्प: घर लौटें, होवर, लैंड, होवर फिर जमीन। मूल्य मानचित्रण अभी तक पुष्टि नहीं हुई - RC के साथ परीक्षण बदलने के बाद बंद हो गया।';

  @override
  String get help_4 =>
      'AB / मार्ग नौकरियों में ड्रोन असफलता चलाने के बजाय काम करता रहता है। केवल रडार के साथ अनुशंसित।';

  @override
  String get help_5 => 'सेंटीडिग्री: 3000 = 30 डिग्री।';

  @override
  String get help_6 =>
      'K++ विकल्प: विकलांग, बहुत धीमी, धीमी, मध्यम, बहुत तेज। मूल्य मानचित्रण अभी तक पुष्टि नहीं हुई है।';

  @override
  String get help_7 => 'स्वायत्त उड़ान में त्वरण। उच्च = तेज गति परिवर्तन।';

  @override
  String get help_8 => 'पायलट नियंत्रण के तहत त्वरण।';

  @override
  String get help_9 => 'उच्च = कम, कठिन स्वचालित ब्रेकिंग।';

  @override
  String get help_10 =>
      'Manoeuvres के लिए नियंत्रण प्रतिक्रिया मैच; तेजी से शक्ति प्रणालियों को उच्च मूल्यों की आवश्यकता होती है।';

  @override
  String get help_11 => 'उच्च = तेज, कुरकुरा टेक-ऑफ।';

  @override
  String get help_12 => 'आम तौर पर समायोजित नहीं होता है।';

  @override
  String get help_13 => 'कितनी जल्दी एफसी स्टिक इनपुट का अनुसरण करता है।';

  @override
  String get help_14 =>
      'K++ विकल्प: संतुलित, खेल, विरोधी कंपन। यदि एयरफ्रेम वाइसिबली हिलाता है तो केवल कंपन दमन की ओर जाता है। मूल्य मानचित्रण अभी तक पुष्टि नहीं हुई है।';

  @override
  String get help_15 =>
      'K++ विकल्प: ऑफ, रिटर्न होम, लैंड (दोनों स्तरों में भी रोशनी चमकती है)। मूल्य मानचित्रण अभी तक पुष्टि नहीं हुई है।';

  @override
  String get help_16 => 'स्तर 1 वोल्टेज से कम होना चाहिए।';

  @override
  String get help_17 =>
      'एकल: P1 पर ESC पंप। डबल: P1 और P2 पर ESC; P1 आगे उड़ान चलाता है, P2 उड़ान पिछड़े।';

  @override
  String get help_18 =>
      'K++ विकल्प: उपयोग नहीं किया गया, स्विच सेंसर (एफसी पोर्ट K2), रीयल-टाइम स्तर। फ्लो मीटर पोर्ट K1 पर चला जाता है। मूल्य मानचित्रण अभी तक पुष्टि नहीं हुई है।';

  @override
  String get help_19 =>
      'जब टैंक सूख जाता है तो कार्रवाई। मूल्य मानचित्रण अभी तक पुष्टि नहीं हुई है।';

  @override
  String get help_20 =>
      'स्केल फैक्टर वोल्टेज अंशांकन (मीटर रीडिंग ÷ एफसी रीडिंग) के लिए उपयोग किया जाता है।';

  @override
  String get simulatorNoHardware => 'सिम्युलेटर (कोई हार्डवेयर नहीं)';

  @override
  String get hideTransmitter => 'ट्रांसमीटर छुपाएँ';

  @override
  String get showTransmitter => 'ट्रांसमीटर BT/WiFi';

  @override
  String get btAbbrev => 'BT';

  @override
  String get noBtSerialRefresh =>
      'कोई BT सीरियल पोर्ट नहीं — TX पेयर करें फिर रीफ़्रेश';

  @override
  String get txWifiIp => 'TX WiFi IP';

  @override
  String get tcp => 'TCP';

  @override
  String get linkDisconnected => 'डिस्कनेक्टेड';

  @override
  String get linkConnecting => 'कनेक्ट हो रहा है…';

  @override
  String linkReadingParameters(int received, int total) {
    return 'पैरामीटर पढ़े जा रहे हैं $received/$total';
  }

  @override
  String linkConnected(String link) {
    return 'कनेक्टेड · $link';
  }

  @override
  String linkLostStatus(String link) {
    return 'लिंक खो गया · $link';
  }

  @override
  String get sensorGyroscope => 'जाइरोस्कोप';

  @override
  String get sensorAccelerometer => 'एक्सेलेरोमीटर';

  @override
  String get sensorCompass => 'कम्पास';

  @override
  String get sensorBarometer => 'बैरोमीटर';

  @override
  String get sensorGps => 'GPS';
}
