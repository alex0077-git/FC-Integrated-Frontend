import 'dart:convert';
import 'dart:io' show Platform;

import 'package:fc_frontend/core/widgets/digital_sky_host_windows.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Native Digital Sky portal (Android / iOS / macOS / Windows).
///
/// Windows uses Edge WebView2 ([DigitalSkyWindowsHost]); other platforms use
/// [webview_flutter]. The system back button is not handled here, so it leaves
/// the screen instead of stepping back through the portal's own history.
class DigitalSkyHost extends StatelessWidget {
  const DigitalSkyHost({
    super.key,
    required this.portalUrl,
    required this.hidePortalChrome,
    required this.reloadNonce,
    required this.onLoading,
    required this.onLoaded,
    required this.onFailed,
  });

  final String portalUrl;
  final String hidePortalChrome;
  final int reloadNonce;
  final VoidCallback onLoading;
  final VoidCallback onLoaded;
  final VoidCallback onFailed;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isWindows) {
      return DigitalSkyWindowsHost(
        portalUrl: portalUrl,
        hidePortalChrome: hidePortalChrome,
        reloadNonce: reloadNonce,
        onLoading: onLoading,
        onLoaded: onLoaded,
        onFailed: onFailed,
      );
    }
    return _DigitalSkyMobileHost(
      portalUrl: portalUrl,
      hidePortalChrome: hidePortalChrome,
      reloadNonce: reloadNonce,
      onLoading: onLoading,
      onLoaded: onLoaded,
      onFailed: onFailed,
    );
  }
}

class _DigitalSkyMobileHost extends StatefulWidget {
  const _DigitalSkyMobileHost({
    required this.portalUrl,
    required this.hidePortalChrome,
    required this.reloadNonce,
    required this.onLoading,
    required this.onLoaded,
    required this.onFailed,
  });

  final String portalUrl;
  final String hidePortalChrome;
  final int reloadNonce;
  final VoidCallback onLoading;
  final VoidCallback onLoaded;
  final VoidCallback onFailed;

  @override
  State<_DigitalSkyMobileHost> createState() => _DigitalSkyMobileHostState();
}

class _DigitalSkyMobileHostState extends State<_DigitalSkyMobileHost> {
  WebViewController? _controller;
  var _initFailed = false;

  @override
  void initState() {
    super.initState();
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => widget.onLoading(),
            onPageFinished: (_) {
              widget.onLoaded();
              _hideChrome();
            },
            onWebResourceError: (error) {
              if (error.isForMainFrame == false) {
                return;
              }
              widget.onFailed();
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.portalUrl));
    } catch (_) {
      _initFailed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onFailed();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_DigitalSkyMobileHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadNonce != oldWidget.reloadNonce) {
      _controller?.loadRequest(Uri.parse(widget.portalUrl));
    }
  }

  Future<void> _hideChrome() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final css = jsonEncode(
      '${widget.hidePortalChrome} { display: none !important; }',
    );
    final script =
        '''
(function () {
  try {
    var style = document.createElement('style');
    style.setAttribute('data-fc-hide-chrome', '1');
    style.textContent = $css;
    (document.head || document.documentElement).appendChild(style);
  } catch (e) {}
})();
''';
    try {
      await controller.runJavaScript(script);
    } catch (_) {
      // Hiding the portal header is optional. The map still works.
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_initFailed || controller == null) {
      return const SizedBox.expand();
    }
    return WebViewWidget(
      controller: controller,
      gestureRecognizers: {
        Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }
}
