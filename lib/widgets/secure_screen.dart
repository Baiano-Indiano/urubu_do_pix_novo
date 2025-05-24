import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class SecureScreen extends StatefulWidget {
  final Widget child;
  final bool enableSecure;
  final bool preventScreenshots;
  final bool preventBackgroundPreview;
  final Duration inactivityTimeout;
  final VoidCallback? onInactivityTimeout;

  const SecureScreen({
    super.key,
    required this.child,
    this.enableSecure = true,
    this.preventScreenshots = true,
    this.preventBackgroundPreview = true,
    this.inactivityTimeout = const Duration(minutes: 5),
    this.onInactivityTimeout,
  });

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen>
    with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  DateTime? _lastActivityTime;
  final _channel = const MethodChannel('flutter_secure');
  bool _isInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupSecurity();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    if (widget.enableSecure) {
      _disableSecureScreen();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(SecureScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableSecure != oldWidget.enableSecure ||
        widget.preventScreenshots != oldWidget.preventScreenshots ||
        widget.preventBackgroundPreview != oldWidget.preventBackgroundPreview) {
      _setupSecurity();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _isInBackground = true;
        if (widget.preventBackgroundPreview) {
          _hideContent();
        }
        break;
      case AppLifecycleState.resumed:
        _isInBackground = false;
        if (widget.preventBackgroundPreview) {
          _showContent();
        }
        _checkInactivityTimeout();
        break;
      default:
        break;
    }
  }

  void _setupSecurity() {
    if (widget.enableSecure) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      if (widget.preventScreenshots) {
        _channel.invokeMethod('enableSecure');
      }

      if (widget.preventBackgroundPreview) {
        _channel.invokeMethod('preventBackgroundPreview');
      }
    }
  }

  void _hideContent() {
    _channel.invokeMethod('hideContent');
  }

  void _showContent() {
    _channel.invokeMethod('showContent');
  }

  void _disableSecureScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _channel.invokeMethod('disableSecure');
  }

  void _startInactivityTimer() {
    _lastActivityTime = DateTime.now();
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkInactivityTimeout();
    });
  }

  void _checkInactivityTimeout() {
    if (_lastActivityTime == null) return;

    final now = DateTime.now();
    final difference = now.difference(_lastActivityTime!);

    if (difference >= widget.inactivityTimeout && !_isInBackground) {
      widget.onInactivityTimeout?.call();
    }
  }

  void _updateLastActivityTime() {
    _lastActivityTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _updateLastActivityTime(),
      onPanDown: (_) => _updateLastActivityTime(),
      child: widget.child,
    );
  }
}
