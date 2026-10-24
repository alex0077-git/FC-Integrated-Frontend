// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Fuselage';

  @override
  String get connectTagline => 'اتصل بطائرتك للبدء';

  @override
  String get start => 'ابدأ';

  @override
  String get groundPlan => 'خطة الأرض';

  @override
  String get kppTuning => 'ضبط K++';

  @override
  String get language => 'اللغة';

  @override
  String currentLanguage(String name) {
    return 'اللغة الحالية: $name';
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
  String get home => 'الرئيسية';

  @override
  String get takeoff => 'إقلاع';

  @override
  String get arm => 'تسليح';

  @override
  String get disarm => 'نزع التسليح';

  @override
  String get rtl => 'عودة';

  @override
  String get land => 'هبوط';

  @override
  String get landConfirmTitle => 'هبوط';

  @override
  String get landConfirmMessage => 'هل تهبط الطائرة الآن؟';

  @override
  String takeoffConfirmMessage(String meters) {
    return 'تسليح (إن لزم) والإقلاع إلى $meters م على الطائرة المتصلة؟';
  }

  @override
  String get armConfirmMessage => 'تسليح الطائرة المتصلة؟';

  @override
  String get disarmConfirmMessage => 'نزع تسليح الطائرة المتصلة؟';

  @override
  String get rtlConfirmMessage => 'العودة إلى نقطة الإطلاق الآن؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get boundaries => 'الحدود';

  @override
  String get split => 'تقسيم';

  @override
  String get obstacles => 'عوائق';

  @override
  String get waypoints => 'نقاط المسار';

  @override
  String get history => 'السجل';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get theme => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get units => 'الوحدات';

  @override
  String get unitsMetric => 'متري';

  @override
  String get unitsImperial => 'إمبراطوري';

  @override
  String get mapStyle => 'نمط الخريطة';

  @override
  String get mapStreet => 'شارع';

  @override
  String get mapSatellite => 'قمر صناعي';

  @override
  String get mapDigitalSky => 'السماء الرقمية';

  @override
  String get kppTuningTitle => 'ضبط K++';

  @override
  String get kppTuningSubtitle => 'مساعد كامل لوحدة التحكم بالطيران';

  @override
  String get about => 'حول';

  @override
  String get appTagline => 'حلّق، خطط المهام، واضبط K++ — تطبيق واحد.';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get battery => 'البطارية';

  @override
  String get flightParameters => 'معلمات الطيران';

  @override
  String get firstWarningThreshold => 'عتبة التحذير الأولى (%)';

  @override
  String get secondWarningThreshold => 'عتبة التحذير الثانية (%)';

  @override
  String get criticalBatteryLevel => 'مستوى البطارية الحرج (%)';

  @override
  String get maxVoltage => 'أقصى جهد';

  @override
  String get minVoltage => 'أدنى جهد';

  @override
  String get lowVoltageThreshold => 'عتبة الجهد المنخفض';

  @override
  String get criticalVoltageThreshold => 'عتبة الجهد الحرج';

  @override
  String get cellCount => 'عدد الخلايا';

  @override
  String get calibrateBatteryOnKpp => 'معايرة البطارية على K++';

  @override
  String get maxYawRate => 'أقصى معدل انحراف';

  @override
  String get maxRollAngle => 'أقصى زاوية تدحرج';

  @override
  String get maxPitchAngle => 'أقصى زاوية ميل';

  @override
  String get maxSpeed => 'أقصى سرعة';

  @override
  String get cruiseSpeed => 'سرعة الإبحار';

  @override
  String get saveMission => 'حفظ المهمة';

  @override
  String get loadMission => 'تحميل المهمة';

  @override
  String get uploadMission => 'رفع المهمة';

  @override
  String get callForJob => 'طلب مهمة';

  @override
  String get uploadAndFly => 'رفع وطيران';

  @override
  String get uploadAndStart => 'رفع وبدء';

  @override
  String get undo => 'تراجع';

  @override
  String get redo => 'إعادة';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get save => 'حفظ';

  @override
  String get heroImageLabel => 'صورة Fuselage الرئيسية';

  @override
  String get logoImageLabel => 'شعار Fuselage';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get connect => 'اتصال';

  @override
  String get connected => 'متصل';

  @override
  String get disconnected => 'غير متصل';

  @override
  String gpsStatus(String fix, String sats) {
    return 'GPS $fix · $sats أقمار';
  }

  @override
  String get gpsUnknown => 'GPS --';

  @override
  String get modeUnknown => 'الوضع --';

  @override
  String get calibration => 'المعايرة';

  @override
  String get kppTuningFull => 'ضبط K++ (المساعد الكامل)';

  @override
  String get kppTuningFullSubtitle =>
      'الحالة، المستشعرات، المكاسب، السجلات، البرنامج الثابت…';

  @override
  String get batteryCritical => 'البطارية حرجة';

  @override
  String get batteryLow => 'البطارية منخفضة';

  @override
  String get batteryFirstWarning => 'تحذير البطارية الأول';

  @override
  String get batterySecondWarningRtl =>
      'تحذير البطارية الثاني — العودة للمنزل (RTL)';

  @override
  String get altitude => 'الارتفاع';

  @override
  String get distanceToDrone => 'المسافة إلى الطائرة';

  @override
  String get distanceToLanding => 'المسافة إلى نقطة الهبوط';

  @override
  String get speed => 'السرعة';

  @override
  String get drawBoundaryBeforeSplit =>
      'ارسم ثلاث نقاط حدود على الأقل قبل التقسيم.';

  @override
  String get firstPoint => 'النقطة الأولى';

  @override
  String get endPoint => 'نقطة النهاية';

  @override
  String get undoSplit => 'تراجع عن التقسيم';

  @override
  String get selectSplitA => 'اختر التقسيم A';

  @override
  String get selectSplitB => 'اختر التقسيم B';

  @override
  String get setA => 'تعيين A';

  @override
  String get setB => 'تعيين B';

  @override
  String get missionSpray => 'رش';

  @override
  String get missionSurvey => 'مسح';

  @override
  String get missionManual => 'يدوي';

  @override
  String waypointsCount(int count) {
    return 'نقاط المسار ($count)';
  }

  @override
  String get noWaypointsYet => 'لا توجد نقاط مسار بعد';

  @override
  String get waypointDetail => 'تفاصيل نقطة المسار';

  @override
  String get selectWaypoint => 'اختر نقطة مسار';

  @override
  String get waypoint => 'نقطة مسار';

  @override
  String get loiter => 'تحويم';

  @override
  String get cropRice => 'أرز';

  @override
  String get cropWheat => 'قمح';

  @override
  String get cropOther => 'أخرى';

  @override
  String get connectLiveKpp => 'اتصال K++ مباشر';

  @override
  String get usbGround => 'USB (أرضي)';

  @override
  String get comPort => 'منفذ COM';

  @override
  String get noComPort => 'لا يوجد منفذ COM';

  @override
  String get refreshComPorts => 'تحديث منافذ COM';

  @override
  String get baud => 'معدل الباود';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get connectUsbToKpp => 'اتصال USB بـ K++';

  @override
  String get transmitterBtWifi => 'المرسل (بلوتوث / WiFi)';

  @override
  String get airbornePath => 'مسار جوي — التطبيق → المرسل → الطائرة';

  @override
  String get bluetooth => 'بلوتوث';

  @override
  String get wifi => 'WiFi';

  @override
  String get bluetoothTransmitter => 'مرسل بلوتوث';

  @override
  String get noBluetoothPort => 'لا يوجد منفذ بلوتوث';

  @override
  String get refreshBluetoothPorts => 'تحديث منافذ البلوتوث';

  @override
  String get showAllComPorts => 'إظهار كل منافذ COM';

  @override
  String get showAllComPortsHint =>
      'استخدم إذا اقترن المرسل لكنه غير مدرج كبلوتوث';

  @override
  String get connectTransmitterBt => 'اتصال المرسل (بلوتوث)';

  @override
  String get disconnectTransmitter => 'قطع اتصال المرسل';

  @override
  String get g20Preset => 'إعداد G20';

  @override
  String get useGatewayIp => 'استخدم IP البوابة';

  @override
  String get refreshNetwork => 'تحديث الشبكة';

  @override
  String get wifiMode => 'وضع WiFi';

  @override
  String get wifiModeTcp => 'TCP إلى نقطة وصول المرسل';

  @override
  String get wifiModeUdp => 'UDP إلى المرسل';

  @override
  String get wifiModeUdpListen => 'استماع UDP (منفذ GCS)';

  @override
  String get hostIp => 'المضيف / IP';

  @override
  String get remotePort => 'المنفذ البعيد';

  @override
  String get localPort => 'المنفذ المحلي';

  @override
  String get connectTransmitterWifi => 'اتصال المرسل (WiFi)';

  @override
  String get autoTryWifi => 'تجربة WiFi تلقائياً';

  @override
  String get phoneLandscapeTitle => 'قم بالتدوير إلى الوضع الأفقي';

  @override
  String get phoneLandscapeBody => 'هذا التطبيق مصمم للوضع الأفقي.';

  @override
  String get returnToLaunch => 'العودة للإطلاق';

  @override
  String get lineSpacing => 'تباعد الخطوط';

  @override
  String get coverageAdjust => 'ضبط التغطية';

  @override
  String get obstacleCircle => 'دائرة';

  @override
  String get obstaclePolygon => 'مضلع';

  @override
  String get addObstacle => 'إضافة عائق';

  @override
  String get deleteObstacle => 'حذف عائق';

  @override
  String get planHistory => 'سجل الخطة';

  @override
  String get imuCalibration => 'معايرة IMU';

  @override
  String get compassCalibration => 'معايرة البوصلة';

  @override
  String get accelCalibration => 'معايرة مقياس التسارع';

  @override
  String get levelHorizon => 'تسوية الأفق';

  @override
  String get startCalibration => 'بدء';

  @override
  String get stopCalibration => 'إيقاف';

  @override
  String get close => 'إغلاق';

  @override
  String get delete => 'حذف';

  @override
  String get ok => 'موافق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get mapAttributionEsri => 'البلاط © Esri (صور + تسميات الأماكن)';

  @override
  String get mapAttributionOsm => '© مساهمو OpenStreetMap';

  @override
  String get digitalSkyEmbedBlocked =>
      'لن يفتح Digital Sky داخل هذا التطبيق. موقعهم يمنع المواقع الأخرى من عرض الخريطة.';

  @override
  String get digitalSkyDidNotLoad => 'تعذّر تحميل Digital Sky';

  @override
  String get openDigitalSky => 'فتح Digital Sky';

  @override
  String get openDigitalSkyInBrowser => 'فتح Digital Sky في المتصفح';

  @override
  String get calibrationRadio => 'الراديو';

  @override
  String get calibrationImu => 'IMU';

  @override
  String get calibrationCompass => 'البوصلة';

  @override
  String get calibrationStatusCalibrating => 'جاري المعايرة…';

  @override
  String get calibrationStatusCalibrated => 'تمت المعايرة';

  @override
  String get calibrationStatusNotCalibrated => 'غير معاير';

  @override
  String get startCalibrationFull => 'بدء المعايرة';

  @override
  String connectLiveLink(String link) {
    return 'رابط مباشر: $link';
  }

  @override
  String get connectUsbIntro =>
      'USB للإعداد على الأرض. للطيران، اربط التطبيق بالمرسل عبر Bluetooth أو WiFi — الأوامر: التطبيق → المرسل → الطائرة.';

  @override
  String get connectWebUnsupported =>
      'نسخة الويب لا تستطيع فتح USB أو Bluetooth أو WiFi. شغّل تطبيق Windows أو Android.';

  @override
  String get transmitterPickHint =>
      'اختر Bluetooth أو WiFi حسب مرسلك. USB أعلاه للإعداد على الأرض دون تغيير.';

  @override
  String get btAbbrev => 'BT';

  @override
  String get transmitterIpHost => 'IP / المضيف للمرسل';

  @override
  String get tcpPort => 'منفذ TCP';

  @override
  String get remoteUdpPort => 'منفذ UDP البعيد';

  @override
  String get localUdpPort => 'منفذ UDP المحلي';

  @override
  String get tryingWifiPorts => 'جاري تجربة المنافذ…';

  @override
  String get autoTryWifiPorts => 'تجربة منافذ WiFi تلقائياً';

  @override
  String loadingParameters(int received, int total) {
    return 'تحميل المعاملات $received/$total';
  }

  @override
  String get linkLostTransmitter =>
      'فُقد الاتصال — تحقق من طاقة المرسل وBluetooth/WiFi والمدى.';

  @override
  String get linkLostUsb => 'فُقد الاتصال — تحقق من كابل USB وطاقة FC.';

  @override
  String get connectLiveHint =>
      'USB: وصّل FC على الأرض. أثناء الطيران: اربط التطبيق بالمرسل (Bluetooth أو WiFi)؛ الأوامر والتليمetry عبر المرسل إلى الطائرة. احتفظ بعصا RC للتحكم اليدوي.';

  @override
  String get connectErrorUsbNeedsNative =>
      'USB K++ المباشر يحتاج Windows أو Android — الويب لا يفتح المنافذ التسلسلية.';

  @override
  String get connectErrorNoComPort =>
      'لم يُعثر على منفذ COM. وصّل كابل بيانات K++ USB ثم حدّث.';

  @override
  String connectErrorInvalidPort(String label) {
    return 'أدخل $label صالحاً (1–65535).';
  }

  @override
  String get connectErrorBluetoothNeedsNative =>
      'Bluetooth يحتاج إصدار Windows أو Android.';

  @override
  String get connectErrorNoBluetoothSerial =>
      'لم يُعثر على منفذ Bluetooth تسلسلي. اقرن المرسل في إعدادات Bluetooth ثم حدّث. إن لم يظهر، فعّل «إظهار كل منافذ COM».';

  @override
  String get connectErrorWifiNeedsNative =>
      'WiFi المرسل يحتاج Windows أو Android.';

  @override
  String get connectErrorEnterTxHost => 'أدخل IP / اسم مضيف WiFi للمرسل.';

  @override
  String get connectErrorNoWifiGateway =>
      'لم يُعثر على بوابة WiFi. انضم أولاً إلى WiFi المرسل.';

  @override
  String connectUsingGateway(String gateway) {
    return 'استخدام البوابة $gateway — اضغط اتصال المرسل (WiFi).';
  }

  @override
  String get connectWifiJoinFirst =>
      'انضم أولاً إلى WiFi المرسل ثم أعد المحاولة.';

  @override
  String connectWifiTcpSuccess(String host, String port) {
    return 'متصل عبر WiFi TX TCP $host:$port';
  }

  @override
  String get connectWifiG20Success =>
      'متصل بـ Skydroid G20 TCP 192.168.43.1:5760';

  @override
  String get connectWifiUdpListenSuccess =>
      'الاستماع UDP 14550 — شغّل المرسل/الطائرة لإرسال التليمetry.';

  @override
  String connectWifiAutoTryFailed(String detail) {
    return 'فشلت المحاولة التلقائية لـ WiFi.\n$detail\n\nلـ Skydroid G20: وضع WiFi = TCP، IP 192.168.43.1، منفذ 5760. على G20 فعّل hotspot WLAN ومشاركة البيانات؛ يجب ربط الطائرة + GR01 (تطابق البaud على منفذ telem في FC).';
  }

  @override
  String get rtlCommandConfirm => 'أمر الطائرة المباشرة بالعودة لنقطة الإقلاع؟';

  @override
  String get connectUsbToKppFirst => 'وصّل USB بـ K++ أولاً';

  @override
  String get noFlyZone => 'منطقة حظر طيران';

  @override
  String get orientation => 'الاتجاه';

  @override
  String get autoAlign => 'محاذاة تلقائية';

  @override
  String get edgeMargin => 'هامش الحافة';

  @override
  String get operationMode => 'وضع التشغيل';

  @override
  String get sprayOn => 'الرش مفعّل';

  @override
  String get sprayOff => 'الرش متوقف';

  @override
  String get latitude => 'خط العرض';

  @override
  String get longitude => 'خط الطول';

  @override
  String get action => 'إجراء';

  @override
  String get selectCrop => 'اختر المحصول';

  @override
  String get sprayRate => 'معدل الرش';

  @override
  String get flowRate => 'معدل التدفق';

  @override
  String get liquidLevel => 'السائل';

  @override
  String get setTakeoffAltitude => 'تعيين ارتفاع الإقلاع';

  @override
  String get takeoffAltitudeMeters => 'الارتفاع (م)';

  @override
  String get notes => 'ملاحظات';

  @override
  String get name => 'الاسم';

  @override
  String get defaultMissionName => 'مهمة';

  @override
  String uploadFlyConfirmMessage(int count, String meters) {
    return 'رفع $count نقطة إلى K++ المباشر، تسليح إن لزم، وبدء Auto (إقلاع $meters م)؟';
  }

  @override
  String get missionUploadedSuccess =>
      'تم رفع المهمة — حُفظت محلياً وبدأ Auto على K++ المباشر';

  @override
  String get missionSavedToDatabase => 'حُفظت المهمة في قاعدة البيانات';

  @override
  String get noSavedMissions => 'لا مهام محفوظة';

  @override
  String get connectKppUsbFirst => 'وصّل K++ مباشر عبر USB أولاً';

  @override
  String get enterMeterVoltageInMaxVoltage => 'أدخل جهد العداد في أقصى جهد';

  @override
  String get battVoltMultWritten => 'تم كتابة BATT_VOLT_MULT إلى K++ المباشر';

  @override
  String savedLocallyFcSyncFailed(String error) {
    return 'حُفظ محلياً؛ فشل مزامنة FC: $error';
  }

  @override
  String get mapHintTapPlacePointA => 'اضغط الخريطة لوضع النقطة A';

  @override
  String get mapHintTapPlacePointB => 'اضغط الخريطة لوضع النقطة B';

  @override
  String get mapHintTapBoundaryForSplit => 'اضغط الحد للنقطة المحددة';

  @override
  String get mapHintTapAddBoundaryPoint => 'اضغط الخريطة لإضافة نقطة حد';

  @override
  String get splitChoosePointsHint =>
      'اختر النقطة الأولى أو الأخيرة، ثم اضغط نقطة حد أو anywhere على الحد.';

  @override
  String get chooseCircleOrPolygon => 'اختر دائرة أو مضلع';

  @override
  String get tapInsideFieldPlaceCircle => 'اضغط داخل الحقل لوضع الدائرة.';

  @override
  String get tapMapPlaceCornersInOrder =>
      'اضغط الخريطة لوضع كل زاوية بالترتيب.';
}
