import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/code_editor_settings.dart';

class CodeEditorSettingsStorage {
  CodeEditorSettingsStorage._();
  static final CodeEditorSettingsStorage instance = CodeEditorSettingsStorage._();

  static const _key = 'code_editor_settings_v1';

  Future<CodeEditorSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const CodeEditorSettings();
    try {
      return CodeEditorSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const CodeEditorSettings();
    }
  }

  Future<void> save(CodeEditorSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
