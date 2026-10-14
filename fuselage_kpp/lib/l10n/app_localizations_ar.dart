// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class KppLocalizationsAr extends KppLocalizations {
  KppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Fuselage-K++';

  @override
  String get groupBasic => 'أساسي';

  @override
  String get groupAdvanced => 'متقدم';

  @override
  String get groupTools => 'أدوات';

  @override
  String get groupFly => 'طيران';

  @override
  String get destOverview => 'الحالة';

  @override
  String get destInstallation => 'التثبيت';

  @override
  String get destRemoteControl => 'التحكم عن بعد';

  @override
  String get destSensors => 'المستشعرات';

  @override
  String get destFlight => 'المحركات والطيران';

  @override
  String get destGains => 'المكاسب';

  @override
  String get destProtection => 'الحماية';

  @override
  String get destPump => 'المضخة';

  @override
  String get destLiquid => 'مستوى السائل';

  @override
  String get destSpraying => 'رش AB';

  @override
  String get destFence => 'السياج';

  @override
  String get destExtensions => 'الإضافات';

  @override
  String get destChannels => 'تعيين القنوات';

  @override
  String get destMission => 'المهمة';

  @override
  String get destLogs => 'سجلات الطيران';

  @override
  String get destParameters => 'كل المعلمات';

  @override
  String get destFirmware => 'البرنامج الثابت وحول';

  @override
  String get mapFly => 'خريطة / طيران';

  @override
  String get groundPlan => 'خطة الأرض';

  @override
  String get home => 'الرئيسية';

  @override
  String get language => 'اللغة';

  @override
  String get overviewDescription =>
      'الصحة المباشرة لوحدة الطيران ووحداتها (تخطيط مساعد K++).';

  @override
  String get sensors => 'المستشعرات';

  @override
  String get imu => 'ZZG3ZZZZ';

  @override
  String get gps => 'ZZG2ZZZZ';

  @override
  String get gps1 => 'ZZG2ZZZ1';

  @override
  String get gps1Sats => 'أقمار GPS1';

  @override
  String get gps2 => 'ZZG2ZZZ2';

  @override
  String get gps2Sats => 'أقمار GPS2';

  @override
  String get position => 'الموقع';

  @override
  String get altitude => 'الارتفاع';

  @override
  String get hdop => 'ZZG18ZZZZZ';

  @override
  String get powerAndLink => 'الطاقة والرابط';

  @override
  String get batteryVoltage => 'جهد البطارية';

  @override
  String get rcSignal => 'إشارة RC';

  @override
  String get link => 'الرابط';

  @override
  String get firmwareVersion => 'إصدار البرنامج الثابت';

  @override
  String get softwareRevision => 'مراجعة البرنامج';

  @override
  String get parameters => 'المعلمات';

  @override
  String get fcMessage => 'رسالة وحدة الطيران';

  @override
  String get statusNormal => 'طبيعي';

  @override
  String get statusFault => 'عطل';

  @override
  String get statusNotConnected => 'غير متصل';

  @override
  String get port => 'المنفذ';

  @override
  String get baud => 'الباود';

  @override
  String get connect => 'اتصال';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get bluetooth => 'بلوتوث';

  @override
  String get wifi => 'ZZG12ZZZZ';

  @override
  String get refreshComPorts => 'تحديث منافذ COM';

  @override
  String get refreshBluetoothPorts => 'تحديث منافذ Bluetooth';

  @override
  String get setMode => 'تعيين الوضع';

  @override
  String get flightModeAuto => 'Auto';

  @override
  String get flightModeGuided => 'ZZG15ZZZZ';

  @override
  String get flightModeLoiter => 'ZZG16ZZZZ';

  @override
  String get flightModeRtl => 'ZZG14ZZZZ';

  @override
  String get flightModeLand => 'هبوط';

  @override
  String get defaultAlt => 'الارتفاع الافتراضي';

  @override
  String get abSpray => 'رش AB';

  @override
  String get download => 'تنزيل';

  @override
  String get upload => 'رفع';

  @override
  String get clear => 'مسح';

  @override
  String get import => 'استيراد';

  @override
  String get export => 'تصدير';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'موافق';

  @override
  String get altitudeM => 'الارتفاع (م)';

  @override
  String missionItemsHint(int count) {
    return '$count عناصر — اضغط الخريطة لإضافة waypoints';
  }

  @override
  String get setA => 'تعيين A';

  @override
  String get setB => 'تعيين B';

  @override
  String get tapMapForFence => 'اضغط الخريطة للسياج…';

  @override
  String get enableCircleFence => 'تفعيل سياج دائري';

  @override
  String get editAltitude => 'تعديل الارتفاع';

  @override
  String get missionDownloaded => 'تم تنزيل المهمة';

  @override
  String get missionUploaded => 'تم رفع المهمة';

  @override
  String get missionCleared => 'تم مسح المهمة';

  @override
  String get rtlAccepted => 'تم قبول RTL';

  @override
  String get landAccepted => 'تم قبول الهبوط';

  @override
  String modeSet(String mode) {
    return 'تم تعيين الوضع $mode';
  }

  @override
  String get setPointsAbFirst => 'عيّن النقطتين A و B على الخريطة أولاً';

  @override
  String abSprayGenerated(int count) {
    return 'تم إنشاء نمط رش AB ($count عناصر)';
  }

  @override
  String fenceCircleEnabled(String radius) {
    return 'سياج دائري مفعّل، نصف القطر $radius م (متمركز على الطائرة أثناء الطيران)';
  }

  @override
  String exportedTo(String path) {
    return 'تم التصدير إلى $path';
  }

  @override
  String importedItems(int count) {
    return 'تم استيراد $count عناصر';
  }

  @override
  String get rtl => 'ZZG14ZZZZ';

  @override
  String get land => 'هبوط';

  @override
  String get armed => 'مسلّح';

  @override
  String get disarmed => 'غير مسلّح';

  @override
  String get notConnected => 'غير متصل';

  @override
  String get notConnectedHint =>
      'اختر ميناء ZZG6ZZZZZZZ (أو المحاكاة) في البار أعلاه وصحافة Connect.';

  @override
  String get cardFrameType => 'نوع الغش';

  @override
  String get frameTypeSubtitle =>
      'نفس مساعدة ZZG1ZZZZZZZZ: الذراع الأصفر = الأنف، M1-M8 = موانئ FC، حمراء CW/ازرق CCW = العمود الفقري. أكتب ZZG21ZZZZ و ZZG22ZZZZZ.';

  @override
  String get cardImuGpsMounting => 'ZZG3ZZZZZZZZZGPS';

  @override
  String get installationDescription =>
      'اختر الإتجاهات لمطابقة الطريقة التي يتم بها تركيب الوحدات وتدخل مقابضها من مركز الجاذبية للإطار الجوي في سنتيمترات';

  @override
  String get remoteControlDescription =>
      'وللتأكيــد مــن أنــه قد حُــدد الأمانــة علــى نحــو صــحيح، فــإنقــل الــززدزــة الزائيــة الــذي يغيــرها، وتحقق من أن القنوات من ١ إلى ٤ تقفز إلى المركز )حوالي ١٥٠٠( وتوجــه ٥ قفزات إلى موقعها الآمن.';

  @override
  String get cardRcSettingsFailsafe => 'ZZG4ZZZZ settings &quot; failsafe';

  @override
  String get stickCalibration => 'معيار';

  @override
  String get stickCalibrationIdle =>
      'وترد أدناه النقاط النهائية الحالية. ابدأوا بتجديد القنوات من 1 إلى 4';

  @override
  String get stickCalibrationExtremes =>
      'ادفع كل عصا إلى الحد الأقصى والحد الأدنى عدة مرات ثم اضغط على التالي';

  @override
  String get stickCalibrationCentre =>
      'أطلقوا كل عصا إلى المركز ثم اضغطوا على مركز التقاط الصور';

  @override
  String get stickCalibrationReview =>
      'تحقق من النتائج، ثم حفظها إلى متحكم الطيران.';

  @override
  String get startCalibration => 'بدء المعايرة';

  @override
  String get captureCentre => 'مركز التقاط';

  @override
  String get saveCalibration => 'الحفاظ على المعايرة';

  @override
  String get next => 'التالي';

  @override
  String get channel => 'القناة';

  @override
  String get min => 'مين';

  @override
  String get centre => 'المركز';

  @override
  String get max => 'ماكس';

  @override
  String get channelMonitor => 'مراقب القناة';

  @override
  String get sensorsImuCompassSubtitle =>
      'قيم أجهزة الاستشعار الراو من كل زدزغ 3ZZZ.';

  @override
  String get cardImuCompass => 'IMUZZZZBass';

  @override
  String get cardBarometer => 'البارومتر';

  @override
  String get noBarometerData => 'No barometer data';

  @override
  String get imuLevelCalibration => 'مقياس IMUZZ';

  @override
  String get imuLevelCalibrationSubtitle =>
      'ضعوا جهاز التحكم في الطيران على مستوى و أعلى، ثم أعيرة.';

  @override
  String get compassCalibration => 'معايرة المركبات';

  @override
  String get compassCalibrationSubtitle =>
      'قم بحساب مستوى الطائرة ودقّة الساعة، ثمّ أنف أسفل وساعة.';

  @override
  String get cardGlobalFlightLimits => 'الحدود العالمية للرحلات';

  @override
  String get motorTest => 'اختبار الطوابق';

  @override
  String get motorTestSubtitle =>
      'يقطع كل محرك على حدة للتحقق من النظام والاتجاه.';

  @override
  String get removePropellers => 'أجهزة الدفع';

  @override
  String get startTest => 'اختبار البدء';

  @override
  String motorTestConfirmMessage(int motor, String throttle, String seconds) {
    return 'اختبار الطوابق سيدور (MZZPH0ZZZZZZ) في (${throttle}ZZ)% في (ZZPH2ZZZZZZZS)\nتُزال متعهدو المُؤنقين وتُؤمن الطائرة.';
  }

  @override
  String get testingMotors => 'اختبار...';

  @override
  String get testMotors => 'محركات الاختبار';

  @override
  String get calibrateImu => 'Calibrate ZZG3ZZZZ';

  @override
  String get calibratingImu => 'معايرة...';

  @override
  String get calibrateCompass => 'البوصلة المعايرة';

  @override
  String get calibratingCompass => 'معايرة...';

  @override
  String get gainsDescription =>
      'مكاسب التحكم جعلت الطيار يشعر أن القيم الأعلى تستجيب بسرعة ولكن تحتاج إلى المزيد من القوة فقط تحرك اتجاه الأداء نحو قمع الاهتزازات إذا كان الحاسوب يهتز بشكل واضح أو المحركات تبدو مزعجة';

  @override
  String protectionDescription(String voltage) {
    return 'التطاير الحالي: ZZPH0ZZZZ. ويجب أن يكون المستوى 2 أدنى من المستوى 1؛ كما أن كلا المستويين يضيء الأضواء.';
  }

  @override
  String barometerReading(String pressure, String temperature) {
    return 'الضغط ZZPH0ZZZZZHPa ; Temperature ZZPH1ZZZZZ';
  }

  @override
  String get cardBasicGains => 'المكاسب الأساسية';

  @override
  String get cardControlGains => 'مكاسب الرقابة';

  @override
  String get cardSpeedSensitivity => 'حساسية السرعة';

  @override
  String get cardVoltageRtlLanding => 'Voltage, return home &apos; landing';

  @override
  String get voltageCalibration => 'معايرة التبريد';

  @override
  String get voltageCalibrationSubtitle =>
      'أدخل الفولطية المقيسة بمتر حتى يطابقه الـ إف سي';

  @override
  String get meterVoltageV => 'مركب متري (خامسا)';

  @override
  String get calibrateVoltage => 'فولطية معايرة';

  @override
  String get cardPump => 'Pump';

  @override
  String get cardLevelSensorProtection =>
      'جهاز الاستشعار من المستوى &quot; الحماية &quot;';

  @override
  String get cardAbJobSettings => 'ZZG8ZZZZZZ';

  @override
  String get cardAbJobProcedure => 'ZZG8ZZZ';

  @override
  String get fenceDescription =>
      'حدود الدائرة والارتفاع رسم/إصلاح الدائرة من خريطة البعثة أو وضع القيم هنا';

  @override
  String get cardQuickFence => 'سياج سريع';

  @override
  String get fenceEnabled => '(فلينس)';

  @override
  String get fenceOff => '(فينس) متوقف';

  @override
  String get enableAltitudeAndCircle => 'الارتفاع الميسر + الدائرة';

  @override
  String get disableFence => 'السياج المهجور';

  @override
  String get cardHeightDistanceLimits => 'الحدود المرتفعة';

  @override
  String get cardRtkAntenna => 'ZZG9ZZZA antenna';

  @override
  String rtkCurrentPositioning(String fix) {
    return 'الموقع الحالي: ZZPH0ZZ';
  }

  @override
  String get cardRadarVision4g => 'Radar, vision &quot; 4G module status';

  @override
  String get extensionsRadarStatusDescription =>
      'ويظهر هنا في مساعد ZZG1ZZZ، ارتفاع الرادار الرافض، المسافة الرادارية العقبية، ونموذج الرؤية، ومركز IoT SIM.';

  @override
  String get channelsDescription =>
      'تحقق من جهاز مراقبة القناة لترى أي قنوات تستخدمها زي زي جي 4 زيز قبل تعيين المهام';

  @override
  String get cardChannelFunctions => 'مهام القناة';

  @override
  String get flightLogsDescription =>
      'يتم حفظ السجلات المحملة إلى الوثائق/ZZG0ZZZ/logs.';

  @override
  String get refreshList => 'قائمة التجديد';

  @override
  String logsOnFlightController(int count) {
    return '${count}ZZ على متحكم الطيران';
  }

  @override
  String parametersDescription(int count) {
    return '(زززفززز) قراءته من متحكم الطيران';
  }

  @override
  String get parameterFiles => 'ملفات البارامترات';

  @override
  String get reloadFromFc => 'Reload from FC';

  @override
  String get searchByIdOrName => 'البحث بالاسم';

  @override
  String parametersShown(int count) {
    return '$count';
  }

  @override
  String get paramColumnId => 'Id';

  @override
  String get paramColumnName => 'الاسم';

  @override
  String get paramColumnValue => 'القيمة';

  @override
  String get paramFormHint => 'اصنعي قيمة و اضغطي ليكتبها الى متحكم الطيران';

  @override
  String get paramNotReported => 'لم يبلغ عن ذلك من قبل متحكم الطيران';

  @override
  String paramUnknownOption(String value) {
    return 'غير معروف (ZZPH0ZZZZZ)';
  }

  @override
  String get enterNumber => 'أدخل رقم';

  @override
  String get writeToFlightControllerTitle => 'أكتب إلى متحكم الطيران؟';

  @override
  String get write => 'الكتابة';

  @override
  String get cardVersions => 'الركائز';

  @override
  String get cardVersionsAuthorisation => 'الإذن بالعروض';

  @override
  String get firmwareUpgrade => 'رفع مستوى البرمجيات';

  @override
  String get firmwareUpgradeDescription =>
      'Upload ZZG1ZZZV2 / KX / P3 firmware through the flight controller bootloader. لا تزيل الجهاز أبداً أثناء ترقيته';

  @override
  String get upgradeFirmware => 'شركة أعلى درجة';

  @override
  String get factoryReset => 'إعادة تحديد العوامل';

  @override
  String get factoryResetDescription => 'أعد كل بارامتر إلى قبو المصنع';

  @override
  String get restoreFactorySettings => 'منشآت مصنع ريسور';

  @override
  String get droneRegistration => 'تسجيل الطائرات العمودية';

  @override
  String get droneRegistrationDescription =>
      'Manufacturer name, aircraft model and aircraft number (ZZG25ZZZZZZ).';

  @override
  String get shape => 'Shape';

  @override
  String validateMinimum(String value) {
    return 'الحد الأدنى هو ZZPH0ZZZ';
  }

  @override
  String validateMaximum(String value) {
    return '(ماكسيموم) (زززفزززز)';
  }

  @override
  String get validateChooseOption => 'اختيار أحد الخيارات المدرجة';

  @override
  String get instance => 'Instance';

  @override
  String get accelAxes => 'Accel X / Y / Z';

  @override
  String get gyroAxes => 'Gyro X / Y / Z';

  @override
  String get compassAxes => 'Compass X / Y / Z';

  @override
  String get comingSoon => 'قريبا';

  @override
  String get channelMonitorNoData => 'No ZZG4ZZZz data received yet.';

  @override
  String get channelMonitorHint => 'حرك العصي والمفاتيح لترى كل قناة';

  @override
  String duplicateChannelFunctions(String details) {
    return 'وظائف القناة المزدوجة: ZZPH0ZZZ';
  }

  @override
  String get logColumnNo => 'لا';

  @override
  String get logColumnTimeUtc => 'الوقت (UTC)';

  @override
  String get logColumnSizeBytes => 'Size (bytes)';

  @override
  String get logReview => 'الاستعراض';

  @override
  String logSavedTo(int id, String path) {
    return 'Lg ${id}ZZZZ انقذت ZZPH1ZZZZZ';
  }

  @override
  String motorThrottlePercent(String percent) {
    return 'Throttle $percent %';
  }

  @override
  String motorDurationSeconds(String seconds) {
    return 'Duration ZZPH0ZZZZZ';
  }

  @override
  String motorTestAccepted(int motor) {
    return 'Motor M$motor';
  }

  @override
  String motorTestFailed(String error) {
    return 'فشل اختبار المحركات: ZZPH0ZZZZ';
  }

  @override
  String get imuCalibrationAccepted => 'IMUZZZ معايرة مقبولة';

  @override
  String imuCalibrationFailed(String error) {
    return 'IMUZZZZZ عيار فشل: ZZPH0ZZZZZ';
  }

  @override
  String get compassCalibrationStarted => 'بدء معايرة المركبات';

  @override
  String compassCalibrationFailed(String error) {
    return 'فشل معايرة البوصلة: ZZPH0ZZZ';
  }

  @override
  String paramSaved(String id, String value) {
    return '${id}ZZ';
  }

  @override
  String paramNotSaved(String id, String error) {
    return '${id}ZZZ لم تنقذ: ZZPH1ZZZZZZ';
  }

  @override
  String paramsSavedCount(int count) {
    return 'انقذت البارامترات ZZPH0ZZZZZZ';
  }

  @override
  String paramsSavedPartial(int saved, int failed, String ids) {
    return '${saved}ZAF, ZZPH1ZZ failed: Z${ids}ZZ';
  }

  @override
  String stickCalibrationInvalid(String channels) {
    return 'Channel min/max out of range: ZZPH0ZZZZ. وقد فشلت المعايرة - حاول مرة أخرى.';
  }

  @override
  String fcReadingAndMultiplier(String reading, String mult) {
    return 'FC reading: ZZPH0ZZZZZZZZ · multiplier: ${mult}ZZ';
  }

  @override
  String get enterValidMeterVoltage => 'أدخل مركباً صالحاً';

  @override
  String get noBatteryVoltageYet => 'لا تطاير بطارية من متحكم الطيران بعد';

  @override
  String logParseFailed(String error) {
    return 'لا يمكن أن يقطع لوج: ZZPH0ZZZ';
  }

  @override
  String get logParseFailedHint => 'افتح المركب الخارجي للتحليل الكامل';

  @override
  String get logNoTrackSamples =>
      'No ZZG2ZZZZZZZ/ATT samples recognised in this log.';

  @override
  String get plotNoSamples => 'لا عينات';

  @override
  String plotMinMax(String min, String max) {
    return 'min ZZPH0ZZZZZZZZZZZH1ZZ';
  }

  @override
  String exportParametersTo(int count, String path) {
    return 'Exported ZZPH0ZZZZ parameters to ZZPH1ZZZ';
  }

  @override
  String importFileFormatError(String message) {
    return 'خطأ في الشكل: ZZPH0ZZZ';
  }

  @override
  String get importNothingMatches =>
      'لا شيء للاستيراد: كل قيمة تضاهي بالفعل متحكم الطيران.';

  @override
  String fcFirmwareInfo(String version) {
    return 'شركة مراقبة الرحلات الجوية';
  }

  @override
  String get appAboutLine =>
      'ZZG0ZZZ 1.0.0 - built to replace the ZZG11ZZZK++ZZA Assistant (JIYIZ221014).';

  @override
  String get sprayProcedure1Title => 'نقطة التسجيل ألف';

  @override
  String get sprayProcedure1Detail => 'اضغط على زر ZZG8ZZ';

  @override
  String get sprayProcedure2Title => 'النقطة باء';

  @override
  String get sprayProcedure2Detail => 'اضغط على زر ZZG8ZZ';

  @override
  String get sprayProcedure3Title => 'ابدأ عمل زيز زدز';

  @override
  String get sprayProcedure3Detail => 'تشغيل زر ZZG8ZZZZ';

  @override
  String get sprayProcedure4Title => 'اتجاه الاختيار';

  @override
  String get sprayProcedure4Detail => 'ادفعي العجلة باتجاه الجانب للعمل';

  @override
  String get sprayProcedure5Title => 'نظيفان ألف وباء';

  @override
  String get sprayProcedure5Detail =>
      'اضغط على زر زي زدز الرقمي للخلف والخلف بسرعة';

  @override
  String get sprayProcedure6Title => 'الاستهلاك بعد إعادة ملء';

  @override
  String get sprayProcedure6Detail =>
      'بدون إزالة A/B، تشغيل ZZG8ZZZZعدم: تستأنف الوظيفة من آخر نقطة وتوجه فارغين.';

  @override
  String get waitingForProtocolConfirmation => 'تنتظر تأكيد البروتوكول';

  @override
  String get pendingFeatureBody =>
      'The ZZG1ZZ Assistant uses a ZZG11ZZZZZZZZ-specific command for this, not standard ZZG10ZZZZ. يبقى معاقاً حتى يُثبت تسجيل التطبيق الأصلي الرسالة بالضبط، لذا لم يُرسل أي شيء غير مؤكد إلى مُراقب الطيران.';

  @override
  String get optForward => 'إلى الأمام';

  @override
  String get optRight => 'الحق';

  @override
  String get optBackward => 'إلى الخلف';

  @override
  String get optLeft => 'يسار';

  @override
  String get optOff => 'قبالة';

  @override
  String get optOn => 'على';

  @override
  String get optSinglePump => 'مضخة واحدة';

  @override
  String get optDoublePump => 'مضخة مزدوجة';

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
  String get optStandard => 'المعيار';

  @override
  String get optCoaxial => 'Coaxial';

  @override
  String get optY6 => 'Y6';

  @override
  String get optAltitude => 'Altitude';

  @override
  String get optAltitudeCircle => 'Altitude +Circ';

  @override
  String get optCircle => 'الدائرة';

  @override
  String get pLabel_FRAME => 'نوع الغش';

  @override
  String get pLabel_SHAPE => 'شكل الصدمة';

  @override
  String get pLabel_NAV_IMU_ORIENT => 'ZZZG3ZZ';

  @override
  String get pLabel_NAV_COMP_ORIENT => 'ZZZG2ZZ';

  @override
  String get pLabel_NAV_IMU_POS_X => 'ZZG3ZZZZ';

  @override
  String get pLabel_NAV_IMU_POS_Y => 'ZZG3ZZZZ';

  @override
  String get pLabel_NAV_IMU_POS_Z => 'IMU';

  @override
  String get pLabel_NAV_GPS3_POS_X => 'ZZG2ZZZZ';

  @override
  String get pLabel_NAV_GPS3_POS_Y => 'ZZG2ZZZZZ';

  @override
  String get pLabel_NAV_GPS3_POS_Z => 'GPS';

  @override
  String get pLabel_NAV_IMU_SOURCE => 'ZZZG3ZZ';

  @override
  String get pLabel_RC_TYPE => 'ZZG4ZZZ';

  @override
  String get pLabel_FS_THR_ENABLE => 'ZZG4ZZZZZ-loss failsafe action';

  @override
  String get pLabel_RC_FS_CONTINUE => 'الاستمرار في العمل عندما ZZG4ZZZZ';

  @override
  String get pLabel_THR_DZ => 'منطقة \"ثوراتل\" الوسطى الميتة';

  @override
  String get pLabel_FLTMODE1 => 'أسلوب الرحلة 1';

  @override
  String get pLabel_FLTMODE2 => 'أسلوب الرحلة 2';

  @override
  String get pLabel_FLTMODE3 => 'أسلوب الرحلة 3';

  @override
  String get pLabel_FLTMODE4 => 'أسلوب الرحلة 4';

  @override
  String get pLabel_FLTMODE5 => 'أسلوب الرحلة 5';

  @override
  String get pLabel_FLTMODE6 => 'أسلوب الرحلة 6';

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
  String get pLabel_ANGLE_MAX => 'زاوية (ماكس تيت)';

  @override
  String get pLabel_WPNAV_LOIT_SPEED => 'السرعة الأفقية';

  @override
  String get pLabel_PILOT_VELZ_UP => 'السرعة القصوى';

  @override
  String get pLabel_PILOT_VELZ_DOWN => 'السرعة القصوى';

  @override
  String get pLabel_MOT_SPIN_ARMED => 'سرعة العمود';

  @override
  String get pLabel_GAIN_BASIC_R_PI => 'تصويب';

  @override
  String get pLabel_GAIN_BASIC_R_D => 'التدحرج';

  @override
  String get pLabel_GAIN_BASIC_P_PI => 'تصويب';

  @override
  String get pLabel_GAIN_BASIC_P_D => 'رطبة';

  @override
  String get pLabel_GAIN_BASIC_YAW => 'Yaw';

  @override
  String get pLabel_GAIN_BASIC_THR => 'السلطة (الحرفية)';

  @override
  String get pLabel_GAIN_CONTROL_RP => '/ ملعب';

  @override
  String get pLabel_GAIN_CONTROL_YAW => 'Yaw';

  @override
  String get pLabel_GAIN_CONTROL_THR => 'كتابي';

  @override
  String get pLabel_GAIN_CONTROL_WP => 'الطريق';

  @override
  String get pLabel_GAIN_CONTROL_MOV => 'Manoeuvre';

  @override
  String get pLabel_GAIN_CONTROL_BRA => 'Brake';

  @override
  String get pLabel_GAIN_CONTROL_SCA => 'التنسيق';

  @override
  String get pLabel_GAIN_CONTROL_TKO => 'المقذوفات';

  @override
  String get pLabel_GAIN_VEL_XY => 'كسب السرعة الأفقية';

  @override
  String get pLabel_GAIN_VEL_Z => 'زيادة السرعة الرأسية';

  @override
  String get pLabel_GAIN_SEN_ATT => 'حساسية الاستعداد';

  @override
  String get pLabel_GAIN_PERFORMANCE => 'اتجاه الأداء';

  @override
  String get pLabel_FS_BATT_ENABLE => 'إجراءات الحماية ذات التأثير المنخفض';

  @override
  String get pLabel_FS_BATT_WARNING => 'المستوى 1';

  @override
  String get pLabel_FS_BATT_VOLTAGE => 'المستوى 2';

  @override
  String get pLabel_FS_PMU_ENABLE => 'ZZG19ZZZZ';

  @override
  String get pLabel_RTL_ALT => 'ارتفاع العودة إلى البيت';

  @override
  String get pLabel_LAND_SPEED => 'سرعة الهبوط';

  @override
  String get pLabel_SPRAY_PUMP_TYPE => 'نوع المضخة';

  @override
  String get pLabel_LIQUID_TYPE => 'نوع الاستشعار من المستوى';

  @override
  String get pLabel_FS_LIQ_ENABLE => 'الحماية من السائل';

  @override
  String get pLabel_ABPOINT_DIS => 'ZZG8ZZZZSwath width';

  @override
  String get pLabel_ABPOINT_SPEED => 'ZZZG8Z';

  @override
  String get pLabel_WPNAV_ENABLE_U => 'نوبة جانبية على شكل واحد';

  @override
  String get pLabel_FENCE_ENABLE => 'Fence enable';

  @override
  String get pLabel_FENCE_TYPE => 'نوع الجنس';

  @override
  String get pLabel_FENCE_ALT_MAX => 'الحد الأقصى للطول';

  @override
  String get pLabel_FENCE_RADIUS => 'الحد الأقصى للبعد (الدرجة)';

  @override
  String get pLabel_FENCE_ACTION => 'عمل خرق';

  @override
  String get pLabel_RTK_ANTI_DEG => 'RTKZA antenna install angle';

  @override
  String get pLabel_CH6_OPT => 'وظيفة القناة 6';

  @override
  String get pLabel_CH7_OPT => 'وظيفة القناة 7';

  @override
  String get pLabel_CH8_OPT => 'وظيفة القناة 8';

  @override
  String get pLabel_CH9_OPT => 'وظيفة القناة 9';

  @override
  String get pLabel_CH10_OPT => 'وظيفة القناة 10';

  @override
  String get pLabel_CH11_OPT => 'وظيفة القناة 11';

  @override
  String get pLabel_CH12_OPT => 'وظيفة القناة 12';

  @override
  String get pLabel_BATT_VOLT_MULT => 'مضاعفات البطارية';

  @override
  String get pLabel_FWVERSION => 'نسخة برمجية';

  @override
  String get pLabel_SYSID_SW_MREV => 'تنقيح البرمجيات';

  @override
  String get pLabel_INS_CAL_TYPE => 'IMUZZZ معايرة الدولة';

  @override
  String get pLabel_COMPASS_CAL_TYPE => 'حالة معايرة المركبات';

  @override
  String get pLabel_REG_ENABLE => 'مرخص';

  @override
  String get helpBasicGain => '0-200٪. يَصْدقُ المراقبَ إلى الحاسوبِ الجويِ.';

  @override
  String get helpControlGain =>
      '0-300٪. أعلى = سرعة الاستجابة، محدودة من قبل قوة الحاسوب الجوي.';

  @override
  String get helpMode =>
      'وتشمل خيارات ZZG1ZZZZ، العمل الدليلي، وتنفيذ ZZG8ZZZZZZZZ، والعمل على الطريق، وسرعة ZZG2ZZZZ، والنوبات الجانبية، ومتابعة التضاريس. لم يتم تأكيد رسم خرائط القيمة بعد.';

  @override
  String get helpChannel =>
      'المهمة الموكلة إلى قناة ZZG4ZZZZZ. وينبغي استخدام كل وظيفة مرة واحدة؛ والتحقق من رصد القنوات قبل تغييرها.';

  @override
  String get help_0 =>
      'Motor count and layout written as ZZG21ZZZZZZZ على حافلة ZZG1ZZZZZ.';

  @override
  String get help_1 =>
      'خارج من مركز الجاذبية المنطقة الزرقاء = منطقة سالبة صفراء = إيجابية.';

  @override
  String get help_2 => 'إستلام بروتوكول. لم يتم تأكيد رسم خرائط القيمة بعد.';

  @override
  String get help_3 =>
      'خيارات ZZG1ZZZ: Return home, Hover, Land, Hover then land. ولم تتأكد بعد عملية مسح القيمة - تحول الاختبار مع ZZG4ZZZZZZ بعد تغييره.';

  @override
  String get help_4 =>
      'In ZZG8ZZZZZZZZZZ/ route jobs the drone keeps working instead of running the failuresafe. لا يوصى به إلا بالرادار';

  @override
  String get help_5 => 'Centidegrees: 3000 = 30°.';

  @override
  String get help_6 =>
      'خيارات ZZG1ZZZ: معوق، بطيئة جدا، بطيئة، متوسطة، سريعة جدا. لم يتم تأكيد رسم خرائط القيمة بعد.';

  @override
  String get help_7 => 'التعجيل في الطيران المستقل. أعلى = سرعة التغييرات.';

  @override
  String get help_8 => 'التسارع تحت السيطرة التجريبية';

  @override
  String get help_9 => 'أعلى = أقصر وأقوى أوتوماتيكية';

  @override
  String get help_10 =>
      ':: مراقبة المناورات؛ وتحتاج نظم الطاقة السريعة إلى قيم أعلى.';

  @override
  String get help_11 => 'أعلى \"أسرع\" ، \"كيسبر\"';

  @override
  String get help_12 => 'في العادة لم يعدل';

  @override
  String get help_13 => 'ما مدى سرعة إتباع مدخل العصي';

  @override
  String get help_14 =>
      'خيارات ZZG1ZZZ: متوازنة، رياضية، مضادة للبيئة. فقط التحرك نحو قمع الاهتزازات إذا كان الجهاز يهتز بشكل واضح. لم يتم تأكيد رسم خرائط القيمة بعد.';

  @override
  String get help_15 =>
      'خيارات ZZG1ZZZ: Off, Return home, Land (both levels also flash the lights). لم يتم تأكيد رسم خرائط القيمة بعد.';

  @override
  String get help_16 => 'يجب أن يكون أقل من المستوى الأول';

  @override
  String get help_17 =>
      'One: pump ZZG20ZZZZZZZ on P1. Double: ZZG20ZZZZs on P1 and P2; P1 runs forward, P2 fl backward.';

  @override
  String get help_18 =>
      'خيارات ZZG1ZZZ: غير مستخدمة، جهاز استشعار (FC port K2)، مستوى التفرغ الحقيقي. المتر المتدفق يذهب إلى الميناء K1. لم يتم تأكيد رسم خرائط القيمة بعد.';

  @override
  String get help_19 =>
      'ابدأ عندما يجف الدبابة لم يتم تأكيد رسم خرائط القيمة بعد.';

  @override
  String get help_20 =>
      'Scale factor used for voltage calibration (meter reading quot; FC reading).';

  @override
  String get simulatorNoHardware => 'محاكي (بدون عتاد)';

  @override
  String get hideTransmitter => 'إخفاء المرسل';

  @override
  String get showTransmitter => 'مرسل BT/WiFi';

  @override
  String get btAbbrev => 'BT';

  @override
  String get noBtSerialRefresh => 'لا منفذ تسلسلي BT — اقترن المرسل ثم حدّث';

  @override
  String get txWifiIp => 'IP واي فاي المرسل';

  @override
  String get tcp => 'TCP';

  @override
  String get linkDisconnected => 'غير متصل';

  @override
  String get linkConnecting => 'جارٍ الاتصال…';

  @override
  String linkReadingParameters(int received, int total) {
    return 'قراءة المعلمات $received/$total';
  }

  @override
  String linkConnected(String link) {
    return 'متصل · $link';
  }

  @override
  String linkLostStatus(String link) {
    return 'فُقد الرابط · $link';
  }

  @override
  String get sensorGyroscope => 'جيروسكوب';

  @override
  String get sensorAccelerometer => 'مقياس تسارع';

  @override
  String get sensorCompass => 'بوصلة';

  @override
  String get sensorBarometer => 'بارومتر';

  @override
  String get sensorGps => 'GPS';
}
