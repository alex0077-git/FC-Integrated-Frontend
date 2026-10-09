import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_windows/webview_flutter_windows.dart';

/// Windows Digital Sky portal via Edge WebView2.
class DigitalSkyWindowsHost extends StatefulWidget {
  const DigitalSkyWindowsHost({
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
  State<DigitalSkyWindowsHost> createState() => _DigitalSkyWindowsHostState();
}

class _DigitalSkyWindowsHostState extends State<DigitalSkyWindowsHost> {
  final WebviewController _controller = WebviewController();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  var _ready = false;
  var _missingRuntime = false;

  @override
  void initState() {
    super.initState();
    widget.onLoading();
    _start();
  }

  @override
  void didUpdateWidget(DigitalSkyWindowsHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadNonce != oldWidget.reloadNonce && _ready) {
      widget.onLoading();
      _controller.loadUrl(widget.portalUrl);
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final version = await WebviewController.getWebViewVersion();
      if (version == null) {
        if (!mounted) {
          return;
        }
        setState(() => _missingRuntime = true);
        // Clear the parent spinner; this host shows its own recovery UI.
        widget.onLoaded();
        return;
      }

      await _controller.initialize();
      _subscriptions.add(
        _controller.loadingState.listen((state) {
          switch (state) {
            case LoadingState.loading:
              widget.onLoading();
            case LoadingState.navigationCompleted:
              widget.onLoaded();
              _hideChrome();
            case LoadingState.none:
              break;
          }
        }),
      );
      _subscriptions.add(
        _controller.onLoadError.listen((_) {
          widget.onFailed();
        }),
      );
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl(widget.portalUrl);
      if (!mounted) {
        return;
      }
      setState(() => _ready = true);
    } on PlatformException catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _missingRuntime = true);
      widget.onLoaded();
    } catch (_) {
      widget.onFailed();
    }
  }

  Future<void> _hideChrome() async {
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
      await _controller.executeScript(script);
    } catch (_) {
      // Optional chrome trim.
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.portalUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_missingRuntime) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Digital Sky needs the Microsoft Edge WebView2 Runtime on this PC.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 6, color: Color(0xCC000000))],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _openInBrowser,
                child: const Text('Open Digital Sky in browser'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_ready) {
      return const SizedBox.expand();
    }

    return Webview(_controller);
  }
}
