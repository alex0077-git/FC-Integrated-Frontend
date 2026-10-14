import 'package:flutter/widgets.dart';
import 'package:fuselage_kpp/core/router/app_destinations.dart';
import 'package:fuselage_kpp/l10n/app_localizations.dart';

extension KppDestinationL10n on AppDestination {
  String localizedLabel(KppLocalizations l10n) {
    switch (path) {
      case '/overview':
        return l10n.destOverview;
      case '/installation':
        return l10n.destInstallation;
      case '/remote-control':
        return l10n.destRemoteControl;
      case '/sensors':
        return l10n.destSensors;
      case '/flight':
        return l10n.destFlight;
      case '/gains':
        return l10n.destGains;
      case '/protection':
        return l10n.destProtection;
      case '/pump':
        return l10n.destPump;
      case '/liquid':
        return l10n.destLiquid;
      case '/spraying':
        return l10n.destSpraying;
      case '/fence':
        return l10n.destFence;
      case '/extensions':
        return l10n.destExtensions;
      case '/channels':
        return l10n.destChannels;
      case '/mission':
        return l10n.destMission;
      case '/logs':
        return l10n.destLogs;
      case '/parameters':
        return l10n.destParameters;
      case '/firmware':
        return l10n.destFirmware;
      default:
        return label;
    }
  }
}

extension KppGroupL10n on DestinationGroup {
  String localizedLabel(KppLocalizations l10n) {
    switch (this) {
      case DestinationGroup.basic:
        return l10n.groupBasic;
      case DestinationGroup.advanced:
        return l10n.groupAdvanced;
      case DestinationGroup.tools:
        return l10n.groupTools;
    }
  }
}

extension KppL10nContext on BuildContext {
  KppLocalizations get kppL10n => KppLocalizations.of(this);
}
