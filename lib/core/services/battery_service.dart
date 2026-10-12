import 'dart:io';

import 'package:flutter/services.dart';

import '../constants/hive_boxes.dart';
import 'storage_service.dart';

/// Wraps the native MethodChannel for battery optimization handling.
/// See: android/app/src/main/kotlin/com/devpath/app/MainActivity.kt
class BatteryService {
  BatteryService._();
  static final BatteryService instance = BatteryService._();

  static const _channel = MethodChannel('com.devpath.app/battery');

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _channel
              .invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> requestIgnoreOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _channel
              .invokeMethod<bool>('requestIgnoreBatteryOptimizations') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openOemAutostartSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('openOemAutostartSettings') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> maybePromptOnce() async {
    if (!Platform.isAndroid) return;
    final prompted = StorageService.instance
            .getSetting<bool>(SettingsKeys.batteryPrompted, defaultValue: false) ??
        false;
    if (prompted) return;

    final ignored = await isIgnoringBatteryOptimizations();
    await StorageService.instance.setSetting(SettingsKeys.batteryPrompted, true);
    if (ignored) return;

    await requestIgnoreOptimizations();
  }
}
