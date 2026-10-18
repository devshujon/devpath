import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/external_open_payload.dart';
import 'external_file_type_detector.dart';

/// Platform channel bridge for Android VIEW/SEND file intents.
class AndroidOpenFileBridge {
  AndroidOpenFileBridge._();

  static const MethodChannel _channel =
      MethodChannel('com.devpath.app/open_file');

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static void installPlatformHandler(Future<void> Function() onNewIntent) {
    if (!isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNewOpenIntent') {
        await onNewIntent();
      }
    });
  }

  static Future<ExternalOpenIntent?> consumePendingIntent() async {
    if (!isAndroid) return null;
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'consumePendingOpen',
      );
      if (raw == null) return null;
      final intent = ExternalOpenIntent.fromMap(raw);
      return intent.isValid ? intent : null;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('AndroidOpenFileBridge.consumePending: $e');
      }
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static Future<ExternalOpenPayload?> loadFromIntent(
    ExternalOpenIntent intent,
  ) async {
    if (!isAndroid) return null;

    String content;
    if (intent.inlineText != null && intent.inlineText!.trim().isNotEmpty) {
      content = intent.inlineText!;
      if (content.length > ExternalFileTypeDetector.maxOpenBytes) {
        throw ExternalOpenTooLargeException(content.length);
      }
    } else {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'readOpenUri',
        {
          'uri': intent.uri,
          'maxBytes': ExternalFileTypeDetector.maxOpenBytes,
        },
      );
      if (raw == null) return null;
      if (raw['error'] != null) {
        throw ExternalOpenReadException(raw['error'] as String? ?? 'read_failed');
      }
      final encoding = raw['encoding'] as String? ?? 'utf8';
      if (encoding == 'base64') {
        final b64 = raw['bytes'] as String? ?? '';
        final bytes = base64.decode(b64);
        content = _decodeBytes(bytes);
      } else {
        content = raw['text'] as String? ?? '';
      }
    }

    final displayName = ExternalFileTypeDetector.displayFileName(
      intent.displayName,
      intent.uri,
    );
    final kind = ExternalFileTypeDetector.detect(
      mimeType: intent.mimeType,
      displayName: displayName,
      uriString: intent.uri,
    );

    return ExternalOpenPayload(
      uri: intent.uri,
      action: intent.action,
      mimeType: intent.mimeType,
      displayName: displayName,
      sizeBytes: intent.sizeBytes ?? content.length,
      kind: kind,
      content: content,
    );
  }

  static String _decodeBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      throw const FormatException('empty file');
    }
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }
}

class ExternalOpenTooLargeException implements Exception {
  final int bytes;
  ExternalOpenTooLargeException(this.bytes);
}

class ExternalOpenReadException implements Exception {
  final String code;
  ExternalOpenReadException(this.code);
}
