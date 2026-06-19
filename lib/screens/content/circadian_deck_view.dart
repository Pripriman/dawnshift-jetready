import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/dawn_palette.dart';

class CircadianDeckView extends StatefulWidget {
  final String endpoint;
  const CircadianDeckView({super.key, required this.endpoint});

  @override
  State<CircadianDeckView> createState() => _CircadianDeckViewState();
}

class _CircadianDeckViewState extends State<CircadianDeckView> {
  static const _lastUrlKey = 'circ.lastUrl';

  InAppWebViewController? _surface;
  bool _loading = true;
  String? _openingUrl;

  @override
  void initState() {
    super.initState();
    _resolveOpening();
  }

  Future<void> _resolveOpening() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_lastUrlKey);
    setState(() {
      _openingUrl = (saved != null && saved.startsWith('http'))
          ? saved
          : widget.endpoint;
    });
  }

  Future<void> _remember(WebUri? uri) async {
    if (uri == null) return;
    final s = uri.toString();
    if (!s.startsWith('http')) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUrlKey, s);
  }

  Future<void> _stepBack() async {
    final surface = _surface;
    if (surface != null && await surface.canGoBack()) {
      surface.goBack();
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_openingUrl == null) {
      return const Scaffold(
        backgroundColor: DawnPalette.canvas,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _stepBack();
      },
      child: Scaffold(
        backgroundColor: DawnPalette.canvas,
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_openingUrl!)),
                initialSettings: InAppWebViewSettings(
                  transparentBackground: true,
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptEnabled: true,
                  useHybridComposition: true,
                  allowsInlineMediaPlayback: true,
                  supportZoom: false,
                ),
                onWebViewCreated: (c) => _surface = c,
                onLoadStart: (c, uri) {
                  if (mounted) setState(() => _loading = true);
                },
                onLoadStop: (c, uri) async {
                  await _remember(uri);
                  if (mounted) setState(() => _loading = false);
                },
                onReceivedError: (c, req, err) {
                  if (mounted) setState(() => _loading = false);
                },
                onUpdateVisitedHistory: (c, uri, isReload) {
                  _remember(uri);
                },
              ),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(
                    color: DawnPalette.dusk,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
