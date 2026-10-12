class CodeEditorSettings {
  final double fontSize;
  final bool wordWrap;
  final bool showLineNumbers;
  final bool autoSave;
  final bool darkEditorTheme;

  const CodeEditorSettings({
    this.fontSize = 13,
    this.wordWrap = false,
    this.showLineNumbers = true,
    this.autoSave = true,
    this.darkEditorTheme = true,
  });

  CodeEditorSettings copyWith({
    double? fontSize,
    bool? wordWrap,
    bool? showLineNumbers,
    bool? autoSave,
    bool? darkEditorTheme,
  }) {
    return CodeEditorSettings(
      fontSize: fontSize ?? this.fontSize,
      wordWrap: wordWrap ?? this.wordWrap,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      autoSave: autoSave ?? this.autoSave,
      darkEditorTheme: darkEditorTheme ?? this.darkEditorTheme,
    );
  }

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'wordWrap': wordWrap,
        'showLineNumbers': showLineNumbers,
        'autoSave': autoSave,
        'darkEditorTheme': darkEditorTheme,
      };

  factory CodeEditorSettings.fromJson(Map<String, dynamic> j) {
    return CodeEditorSettings(
      fontSize: (j['fontSize'] is num) ? (j['fontSize'] as num).toDouble() : 13,
      wordWrap: j['wordWrap'] == true,
      showLineNumbers: j['showLineNumbers'] != false,
      autoSave: j['autoSave'] != false,
      darkEditorTheme: j['darkEditorTheme'] != false,
    );
  }
}
