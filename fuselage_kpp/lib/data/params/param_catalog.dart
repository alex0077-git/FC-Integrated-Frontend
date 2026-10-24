import 'package:fuselage_kpp/data/params/param_spec.dart';

/// Every parameter id the K++ assistant (JIYI221014.exe) reads or writes.
///
/// Ids and screen grouping come from the assistant's binary. Units follow the
/// ArduPilot convention for ArduPilot-named parameters; JIYI-specific ones use
/// the units shown in the assistant. Ranges are only set where the assistant
/// states them (gain screens).
abstract final class ParamCatalog {
  static const _direction = {0: 'Forward', 1: 'Right', 2: 'Backward', 3: 'Left'};
  static const _offOn = {0: 'Off', 1: 'On'};
  static const _pumpType = {0: 'Single pump', 1: 'Double pump'};

  static const _basicGainHelp = 'Range 0–200 %. Adapts the controller to the airframe.';
  static const _controlGainHelp = 'Range 0–300 %. Higher = faster response; limited by the airframe\'s power.';
  static const _modeHelp =
      'K++ options include Manual job, AB execute, Route job, GPS speed, '
      'Side shift and Terrain follow. Value mapping not yet confirmed.';
  static const _channelHelp =
      'Function assigned to this RC channel. Each function should be used once; '
      'check the channel monitor before changing.';

  static const List<ParamSpec> all = [
    // Installation (机架安装).
    ParamSpec(
      id: 'FRAME',
      label: 'Frame type',
      section: ParamSection.installation,
      options: {1: 'Quad X', 2: 'Quad +', 3: 'Hexa X', 4: 'Hexa +', 5: 'Octo X', 6: 'Octo +'},
      simulatedDefault: 1,
      help: 'Motor count and layout written as FRAME on the K++ bus.',
    ),
    ParamSpec(
      id: 'SHAPE',
      label: 'Frame shape',
      section: ParamSection.installation,
      options: {0: 'Standard', 1: 'Coaxial', 2: 'Y6'},
      simulatedDefault: 1,
    ),
    ParamSpec(
      id: 'NAV_IMU_ORIENT',
      label: 'IMU direction',
      section: ParamSection.installation,
      options: _direction,
      simulatedDefault: 0,
    ),
    ParamSpec(
      id: 'NAV_COMP_ORIENT',
      label: 'GPS direction',
      section: ParamSection.installation,
      options: _direction,
      simulatedDefault: 0,
    ),
    ParamSpec(
      id: 'NAV_IMU_POS_X',
      label: 'IMU position X',
      section: ParamSection.installation,
      unit: 'cm',
      simulatedDefault: 0,
      help: 'Offset from the centre of gravity. Blue zone = negative, yellow zone = positive.',
    ),
    ParamSpec(
      id: 'NAV_IMU_POS_Y',
      label: 'IMU position Y',
      section: ParamSection.installation,
      unit: 'cm',
      simulatedDefault: 0,
    ),
    ParamSpec(
      id: 'NAV_IMU_POS_Z',
      label: 'IMU position Z',
      section: ParamSection.installation,
      unit: 'cm',
      simulatedDefault: 0,
    ),
    ParamSpec(
      id: 'NAV_GPS3_POS_X',
      label: 'GPS position X',
      section: ParamSection.installation,
      unit: 'cm',
      simulatedDefault: -10,
    ),
    ParamSpec(
      id: 'NAV_GPS3_POS_Y',
      label: 'GPS position Y',
      section: ParamSection.installation,
      unit: 'cm',
      simulatedDefault: 0,
    ),
    ParamSpec(
      id: 'NAV_GPS3_POS_Z',
      label: 'GPS position Z',
      section: ParamSection.installation,
      unit: 'cm',
      simulatedDefault: -25,
    ),
    ParamSpec(id: 'NAV_IMU_SOURCE', label: 'IMU source', section: ParamSection.installation, simulatedDefault: 0),

    // Remote control (遥控器).
    ParamSpec(
      id: 'RC_TYPE',
      label: 'RC type',
      section: ParamSection.remoteControl,
      simulatedDefault: 0,
      help: 'Receiver protocol. Value mapping not yet confirmed.',
    ),
    ParamSpec(
      id: 'FS_THR_ENABLE',
      label: 'RC-loss failsafe action',
      section: ParamSection.remoteControl,
      simulatedDefault: 1,
      help:
          'K++ options: Return home, Hover, Land, Hover then land. Value mapping not yet confirmed — test with the RC switched off after changing.',
    ),
    ParamSpec(
      id: 'RC_FS_CONTINUE',
      label: 'Continue job when RC is lost',
      section: ParamSection.remoteControl,
      options: _offOn,
      simulatedDefault: 0,
      help: 'In AB / route jobs the drone keeps working instead of running the failsafe. Recommended only with radar.',
    ),
    ParamSpec(
      id: 'THR_DZ',
      label: 'Throttle mid dead zone',
      section: ParamSection.remoteControl,
      unit: 'PWM',
      simulatedDefault: 100,
    ),
    ParamSpec(
      id: 'FLTMODE1',
      label: 'Flight mode 1',
      section: ParamSection.remoteControl,
      simulatedDefault: 0,
      help: _modeHelp,
    ),
    ParamSpec(
      id: 'FLTMODE2',
      label: 'Flight mode 2',
      section: ParamSection.remoteControl,
      simulatedDefault: 0,
      help: _modeHelp,
    ),
    ParamSpec(
      id: 'FLTMODE3',
      label: 'Flight mode 3',
      section: ParamSection.remoteControl,
      simulatedDefault: 1,
      help: _modeHelp,
    ),
    ParamSpec(
      id: 'FLTMODE4',
      label: 'Flight mode 4',
      section: ParamSection.remoteControl,
      simulatedDefault: 1,
      help: _modeHelp,
    ),
    ParamSpec(
      id: 'FLTMODE5',
      label: 'Flight mode 5',
      section: ParamSection.remoteControl,
      simulatedDefault: 2,
      help: _modeHelp,
    ),
    ParamSpec(
      id: 'FLTMODE6',
      label: 'Flight mode 6',
      section: ParamSection.remoteControl,
      simulatedDefault: 2,
      help: _modeHelp,
    ),

    // Stick calibration results (written by the calibration wizard).
    ParamSpec(id: 'RC1_MIN', label: 'CH1 min', section: ParamSection.rcCalibration, unit: 'µs', simulatedDefault: 1100),
    ParamSpec(id: 'RC1_MAX', label: 'CH1 max', section: ParamSection.rcCalibration, unit: 'µs', simulatedDefault: 1900),
    ParamSpec(
      id: 'RC1_TRIM',
      label: 'CH1 trim',
      section: ParamSection.rcCalibration,
      unit: 'µs',
      simulatedDefault: 1500,
    ),
    ParamSpec(id: 'RC2_MIN', label: 'CH2 min', section: ParamSection.rcCalibration, unit: 'µs', simulatedDefault: 1100),
    ParamSpec(id: 'RC2_MAX', label: 'CH2 max', section: ParamSection.rcCalibration, unit: 'µs', simulatedDefault: 1900),
    ParamSpec(
      id: 'RC2_TRIM',
      label: 'CH2 trim',
      section: ParamSection.rcCalibration,
      unit: 'µs',
      simulatedDefault: 1500,
    ),
    ParamSpec(id: 'RC3_MIN', label: 'CH3 min', section: ParamSection.rcCalibration, unit: 'µs', simulatedDefault: 1100),
    ParamSpec(id: 'RC3_MAX', label: 'CH3 max', section: ParamSection.rcCalibration, unit: 'µs', simulatedDefault: 1900),
    ParamSpec(
      id: 'RC3_TRIM',
      label: 'CH3 trim',
      section: ParamSection.rcCalibration,
      unit: 'µs',
      simulatedDefault: 1500,
    ),
    ParamSpec(id: 'RC4_MIN', label: 'CH4 min', section: ParamSection.rcCalibration, unit: 'µs', simulatedDefault: 1100),
    ParamSpec(id: 'RC4_MAX', label: 'CH4 max', section: ParamSection.rcCalibration, unit: 'µs', simulatedDefault: 1900),
    ParamSpec(
      id: 'RC4_TRIM',
      label: 'CH4 trim',
      section: ParamSection.rcCalibration,
      unit: 'µs',
      simulatedDefault: 1500,
    ),

    // Global flight parameters (全局参数).
    ParamSpec(
      id: 'ANGLE_MAX',
      label: 'Max tilt angle',
      section: ParamSection.flight,
      unit: 'cdeg',
      simulatedDefault: 3000,
      help: 'Centidegrees: 3000 = 30°.',
    ),
    ParamSpec(
      id: 'WPNAV_LOIT_SPEED',
      label: 'Max horizontal speed',
      section: ParamSection.flight,
      unit: 'cm/s',
      simulatedDefault: 1000,
    ),
    ParamSpec(
      id: 'PILOT_VELZ_UP',
      label: 'Max climb speed',
      section: ParamSection.flight,
      unit: 'cm/s',
      simulatedDefault: 300,
    ),
    ParamSpec(
      id: 'PILOT_VELZ_DOWN',
      label: 'Max descent speed',
      section: ParamSection.flight,
      unit: 'cm/s',
      simulatedDefault: 200,
    ),
    ParamSpec(
      id: 'MOT_SPIN_ARMED',
      label: 'Motor idle speed',
      section: ParamSection.flight,
      simulatedDefault: 2,
      help: 'K++ options: Disabled, Very slow, Slow, Medium, Very fast. Value mapping not yet confirmed.',
    ),

    // Basic gains (基础感度).
    ParamSpec(
      id: 'GAIN_BASIC_R_PI',
      label: 'Roll correction',
      section: ParamSection.basicGains,
      unit: '%',
      min: 0,
      max: 200,
      simulatedDefault: 100,
      help: _basicGainHelp,
    ),
    ParamSpec(
      id: 'GAIN_BASIC_R_D',
      label: 'Roll damping',
      section: ParamSection.basicGains,
      unit: '%',
      min: 0,
      max: 200,
      simulatedDefault: 100,
      help: _basicGainHelp,
    ),
    ParamSpec(
      id: 'GAIN_BASIC_P_PI',
      label: 'Pitch correction',
      section: ParamSection.basicGains,
      unit: '%',
      min: 0,
      max: 200,
      simulatedDefault: 100,
      help: _basicGainHelp,
    ),
    ParamSpec(
      id: 'GAIN_BASIC_P_D',
      label: 'Pitch damping',
      section: ParamSection.basicGains,
      unit: '%',
      min: 0,
      max: 200,
      simulatedDefault: 100,
      help: _basicGainHelp,
    ),
    ParamSpec(
      id: 'GAIN_BASIC_YAW',
      label: 'Yaw',
      section: ParamSection.basicGains,
      unit: '%',
      min: 0,
      max: 200,
      simulatedDefault: 100,
      help: _basicGainHelp,
    ),
    ParamSpec(
      id: 'GAIN_BASIC_THR',
      label: 'Power (vertical)',
      section: ParamSection.basicGains,
      unit: '%',
      min: 0,
      max: 200,
      simulatedDefault: 100,
      help: _basicGainHelp,
    ),

    // Control gains (控制感度).
    ParamSpec(
      id: 'GAIN_CONTROL_RP',
      label: 'Roll / pitch',
      section: ParamSection.controlGains,
      unit: '%',
      min: 0,
      max: 300,
      simulatedDefault: 100,
      help: _controlGainHelp,
    ),
    ParamSpec(
      id: 'GAIN_CONTROL_YAW',
      label: 'Yaw',
      section: ParamSection.controlGains,
      unit: '%',
      min: 0,
      max: 300,
      simulatedDefault: 100,
      help: _controlGainHelp,
    ),
    ParamSpec(
      id: 'GAIN_CONTROL_THR',
      label: 'Vertical',
      section: ParamSection.controlGains,
      unit: '%',
      min: 0,
      max: 300,
      simulatedDefault: 100,
      help: _controlGainHelp,
    ),
    ParamSpec(
      id: 'GAIN_CONTROL_WP',
      label: 'Route',
      section: ParamSection.controlGains,
      unit: '%',
      min: 0,
      max: 300,
      simulatedDefault: 100,
      help: 'Acceleration in autonomous flight. Higher = faster speed changes.',
    ),
    ParamSpec(
      id: 'GAIN_CONTROL_MOV',
      label: 'Manoeuvre',
      section: ParamSection.controlGains,
      unit: '%',
      min: 0,
      max: 300,
      simulatedDefault: 100,
      help: 'Acceleration under pilot control.',
    ),
    ParamSpec(
      id: 'GAIN_CONTROL_BRA',
      label: 'Brake',
      section: ParamSection.controlGains,
      unit: '%',
      min: 0,
      max: 300,
      simulatedDefault: 100,
      help: 'Higher = shorter, harder automatic braking.',
    ),
    ParamSpec(
      id: 'GAIN_CONTROL_SCA',
      label: 'Coordination',
      section: ParamSection.controlGains,
      unit: '%',
      min: 0,
      max: 300,
      simulatedDefault: 100,
      help: 'Matches control response to manoeuvres; faster power systems need higher values.',
    ),
    ParamSpec(
      id: 'GAIN_CONTROL_TKO',
      label: 'Take-off',
      section: ParamSection.controlGains,
      unit: '%',
      min: 0,
      max: 300,
      simulatedDefault: 100,
      help: 'Higher = quicker, crisper take-off.',
    ),

    // Speed and sensitivity gains (速度感度 / 灵敏感度 / 性能取向).
    ParamSpec(
      id: 'GAIN_VEL_XY',
      label: 'Horizontal speed gain',
      section: ParamSection.speedGains,
      unit: '%',
      simulatedDefault: 100,
      help: 'Normally not adjusted.',
    ),
    ParamSpec(
      id: 'GAIN_VEL_Z',
      label: 'Vertical speed gain',
      section: ParamSection.speedGains,
      unit: '%',
      simulatedDefault: 100,
      help: 'Normally not adjusted.',
    ),
    ParamSpec(
      id: 'GAIN_SEN_ATT',
      label: 'Attitude sensitivity',
      section: ParamSection.speedGains,
      unit: '%',
      simulatedDefault: 5,
      help: 'How quickly the FC follows stick input.',
    ),
    ParamSpec(
      id: 'GAIN_PERFORMANCE',
      label: 'Performance tendency',
      section: ParamSection.speedGains,
      simulatedDefault: 0,
      help:
          'K++ options: Balanced, Sport, Anti-vibration. Only move towards vibration suppression if the airframe visibly shakes. Value mapping not yet confirmed.',
    ),

    // Protection (保护功能).
    ParamSpec(
      id: 'FS_BATT_ENABLE',
      label: 'Low-voltage protection action',
      section: ParamSection.protection,
      simulatedDefault: 1,
      help: 'K++ options: Off, Return home, Land (both levels also flash the lights). Value mapping not yet confirmed.',
    ),
    ParamSpec(
      id: 'FS_BATT_WARNING',
      label: 'Level 1 alarm voltage',
      section: ParamSection.protection,
      unit: 'V',
      decimals: 1,
      simulatedDefault: 44.4,
    ),
    ParamSpec(
      id: 'FS_BATT_VOLTAGE',
      label: 'Level 2 alarm voltage',
      section: ParamSection.protection,
      unit: 'V',
      decimals: 1,
      simulatedDefault: 43.2,
      help: 'Must be lower than the level 1 voltage.',
    ),
    ParamSpec(
      id: 'FS_PMU_ENABLE',
      label: 'PMU fault protection',
      section: ParamSection.protection,
      simulatedDefault: 1,
    ),
    ParamSpec(
      id: 'RTL_ALT',
      label: 'Return-home height',
      section: ParamSection.protection,
      unit: 'cm',
      simulatedDefault: 1500,
    ),
    ParamSpec(
      id: 'LAND_SPEED',
      label: 'Landing speed',
      section: ParamSection.protection,
      unit: 'cm/s',
      simulatedDefault: 50,
    ),

    // Pump (水泵设置).
    ParamSpec(
      id: 'SPRAY_PUMP_TYPE',
      label: 'Pump type',
      section: ParamSection.pump,
      options: _pumpType,
      simulatedDefault: 0,
      help: 'Single: pump ESC on P1. Double: ESCs on P1 and P2; P1 runs flying forward, P2 flying backward.',
    ),

    // Liquid level (液位计).
    ParamSpec(
      id: 'LIQUID_TYPE',
      label: 'Level sensor type',
      section: ParamSection.liquid,
      simulatedDefault: 1,
      help:
          'K++ options: Not used, Switch sensor (FC port K2), Real-time level. Flow meter on port K1 — live L/min shown on Start / Liquid when the FC reports it.',
    ),
    ParamSpec(
      id: 'FS_LIQ_ENABLE',
      label: 'Out-of-liquid protection',
      section: ParamSection.liquid,
      simulatedDefault: 1,
      help: 'Action when the tank runs dry. Value mapping not yet confirmed.',
    ),

    // AB spraying (植保功能).
    ParamSpec(
      id: 'ABPOINT_DIS',
      label: 'AB swath width',
      section: ParamSection.spraying,
      unit: 'm',
      decimals: 1,
      simulatedDefault: 5,
    ),
    ParamSpec(
      id: 'ABPOINT_SPEED',
      label: 'AB speed',
      section: ParamSection.spraying,
      unit: 'm/s',
      decimals: 1,
      simulatedDefault: 5,
    ),
    ParamSpec(
      id: 'WPNAV_ENABLE_U',
      label: 'U-shaped side shift',
      section: ParamSection.spraying,
      options: _offOn,
      simulatedDefault: 1,
    ),

    // Fence (围栏功能).
    ParamSpec(
      id: 'FENCE_ENABLE',
      label: 'Fence enable',
      section: ParamSection.fence,
      options: _offOn,
      simulatedDefault: 0,
    ),
    ParamSpec(
      id: 'FENCE_TYPE',
      label: 'Fence type',
      section: ParamSection.fence,
      options: {0: 'Off', 1: 'Altitude', 2: 'Circle', 3: 'Altitude + circle'},
      simulatedDefault: 0,
    ),
    ParamSpec(id: 'FENCE_ALT_MAX', label: 'Height limit', section: ParamSection.fence, unit: 'm', simulatedDefault: 30),
    ParamSpec(
      id: 'FENCE_RADIUS',
      label: 'Distance limit (radius)',
      section: ParamSection.fence,
      unit: 'm',
      simulatedDefault: 500,
    ),
    ParamSpec(id: 'FENCE_ACTION', label: 'Fence breach action', section: ParamSection.fence, simulatedDefault: 0),

    // Extension modules (扩展模块).
    ParamSpec(
      id: 'RTK_ANTI_DEG',
      label: 'RTK antenna install angle',
      section: ParamSection.extensions,
      unit: '°',
      decimals: 1,
      simulatedDefault: 0,
    ),

    // Channel mapping (映射功能).
    ParamSpec(
      id: 'CH6_OPT',
      label: 'Channel 6 function',
      section: ParamSection.channels,
      simulatedDefault: 0,
      help: _channelHelp,
    ),
    ParamSpec(
      id: 'CH7_OPT',
      label: 'Channel 7 function',
      section: ParamSection.channels,
      simulatedDefault: 0,
      help: _channelHelp,
    ),
    ParamSpec(
      id: 'CH8_OPT',
      label: 'Channel 8 function',
      section: ParamSection.channels,
      simulatedDefault: 0,
      help: _channelHelp,
    ),
    ParamSpec(
      id: 'CH9_OPT',
      label: 'Channel 9 function',
      section: ParamSection.channels,
      simulatedDefault: 0,
      help: _channelHelp,
    ),
    ParamSpec(
      id: 'CH10_OPT',
      label: 'Channel 10 function',
      section: ParamSection.channels,
      simulatedDefault: 0,
      help: _channelHelp,
    ),
    ParamSpec(
      id: 'CH11_OPT',
      label: 'Channel 11 function',
      section: ParamSection.channels,
      simulatedDefault: 0,
      help: _channelHelp,
    ),
    ParamSpec(
      id: 'CH12_OPT',
      label: 'Channel 12 function',
      section: ParamSection.channels,
      simulatedDefault: 0,
      help: _channelHelp,
    ),

    // System / version (read-only in the K++ assistant).
    ParamSpec(
      id: 'BATT_VOLT_MULT',
      label: 'Battery voltage multiplier',
      section: ParamSection.protection,
      decimals: 4,
      simulatedDefault: 1,
      help: 'Scale factor used for voltage calibration (meter reading ÷ FC reading).',
    ),
    ParamSpec(
      id: 'FWVERSION',
      label: 'Firmware version',
      section: ParamSection.system,
      simulatedDefault: 221014,
      readOnly: true,
    ),
    ParamSpec(
      id: 'SYSID_SW_MREV',
      label: 'Software revision',
      section: ParamSection.system,
      simulatedDefault: 120,
      readOnly: true,
    ),
    ParamSpec(
      id: 'INS_CAL_TYPE',
      label: 'IMU calibration state',
      section: ParamSection.system,
      simulatedDefault: 1,
      readOnly: true,
    ),
    ParamSpec(
      id: 'COMPASS_CAL_TYPE',
      label: 'Compass calibration state',
      section: ParamSection.system,
      simulatedDefault: 1,
      readOnly: true,
    ),
    ParamSpec(
      id: 'REG_ENABLE',
      label: 'App unlock authorised',
      section: ParamSection.system,
      options: _offOn,
      simulatedDefault: 0,
    ),
  ];

  static final Map<String, ParamSpec> _byId = {for (final spec in all) spec.id: spec};

  static ParamSpec? byId(String id) => _byId[id];

  static List<ParamSpec> inSection(ParamSection section) => [
    for (final spec in all)
      if (spec.section == section) spec,
  ];
}
