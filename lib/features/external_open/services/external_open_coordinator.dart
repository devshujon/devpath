import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../models/external_open_payload.dart';
import 'android_open_file_bridge.dart';

/// Polls Android for pending open intents and navigates to the open screen.
class ExternalOpenCoordinator extends ChangeNotifier {
  ExternalOpenCoordinator._();
  static final ExternalOpenCoordinator instance = ExternalOpenCoordinator._();

  GlobalKey<NavigatorState>? _navigatorKey;
  String? _lastDedupeKey;
  bool _handling = false;

  ExternalOpenPayload? pendingPayload;

  void attachNavigator(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> checkForPendingOpen({bool force = false}) async {
    if (!AndroidOpenFileBridge.isAndroid) return;
    if (_handling) return;

    final intent = await AndroidOpenFileBridge.consumePendingIntent();
    if (intent == null) return;

    _handling = true;
    try {
      final payload = await AndroidOpenFileBridge.loadFromIntent(intent);
      if (payload == null) return;
      if (!force && payload.dedupeKey == _lastDedupeKey) return;

      _lastDedupeKey = payload.dedupeKey;
      pendingPayload = payload;
      notifyListeners();
      _pushOpenScreen(payload);
    } on ExternalOpenTooLargeException {
      _showError('File is too large to open (max 1 MB).');
    } on ExternalOpenReadException catch (e) {
      _showError(_messageForReadError(e.code));
    } catch (e) {
      if (kDebugMode) debugPrint('ExternalOpenCoordinator: $e');
      _showError('Could not read the file.');
    } finally {
      _handling = false;
    }
  }

  void _pushOpenScreen(ExternalOpenPayload payload) {
    final nav = _navigatorKey?.currentState;
    if (nav == null) return;
    nav.pushNamed(
      AppRoutes.externalFileOpen,
      arguments: payload,
    );
  }

  void _showError(String message) {
    final ctx = _navigatorKey?.currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
  }

  String _messageForReadError(String code) => switch (code) {
        'permission_denied' => 'Permission to read this file was denied or expired.',
        'not_found' => 'The file is missing or unavailable.',
        'too_large' => 'File is too large to open (max 1 MB).',
        'empty' => 'The file is empty.',
        _ => 'Could not read the file.',
      };
}
