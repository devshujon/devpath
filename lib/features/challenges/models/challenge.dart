import '../../learning/models/lesson.dart' show Difficulty, DifficultyMeta;

export '../../learning/models/lesson.dart' show Difficulty, DifficultyMeta;

/// A single rule the user's code must satisfy. The simple form (just
/// a string in JSON) is auto-typed by [ExpectedRules.fromJson] based
/// on common conventions. The explicit form lets the catalog override
/// detection when needed.
///
/// Examples:
///   - simple HTML: `"button"`                 → tag "button"
///   - simple CSS:  `"border-radius"`          → property "border-radius"
///   - simple JS:   `"showMessage"`            → function "showMessage"
///   - explicit:    `{"type":"text","value":"Hello"}`
class Rule {
  /// One of the type strings below. See enum constants on this class.
  final String type;
  final String value;

  /// For attribute rules: which tag the attribute should appear on
  /// (e.g. `onclick` on `button`). Null = anywhere.
  final String? onTag;

  const Rule({required this.type, required this.value, this.onTag});

  // HTML rule types
  static const String htmlTag = 'tag';
  static const String htmlAttribute = 'attribute';
  static const String htmlText = 'text';

  // CSS rule types
  static const String cssSelector = 'selector';
  static const String cssProperty = 'property';

  // JS rule types
  static const String jsFunction = 'function';
  static const String jsDom = 'dom';

  /// Human-readable label used in failure messages and the result sheet.
  String describe() {
    switch (type) {
      case htmlTag:
        return '<$value> tag';
      case htmlAttribute:
        return onTag != null
            ? '$value="…" attribute on <$onTag>'
            : '$value="…" attribute';
      case htmlText:
        return 'text "$value"';
      case cssSelector:
        return '$value selector';
      case cssProperty:
        return '$value property';
      case jsFunction:
        return '$value() function';
      case jsDom:
        return '.$value() DOM call';
      default:
        return value;
    }
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        if (onTag != null) 'on': onTag,
      };

  factory Rule.fromJson(Map<String, dynamic> j) => Rule(
        type: j['type'] as String,
        value: j['value'] as String,
        onTag: j['on'] as String?,
      );
}

/// Strongly-typed collection of rules. Each list is the rules to apply
/// to its respective language buffer.
class ExpectedRules {
  final List<Rule> html;
  final List<Rule> css;
  final List<Rule> js;

  const ExpectedRules({
    this.html = const [],
    this.css = const [],
    this.js = const [],
  });

  bool get isEmpty => html.isEmpty && css.isEmpty && js.isEmpty;

  Map<String, dynamic> toJson() => {
        'html': html.map((r) => r.toJson()).toList(),
        'css': css.map((r) => r.toJson()).toList(),
        'js': js.map((r) => r.toJson()).toList(),
      };

  factory ExpectedRules.fromJson(Map<String, dynamic> j) => ExpectedRules(
        html: _decodeList(j['html'], _autoDetectHtml),
        css: _decodeList(j['css'], _autoDetectCss),
        js: _decodeList(j['js'], _autoDetectJs),
      );

  static List<Rule> _decodeList(
    dynamic raw,
    Rule Function(String) autoDetect,
  ) {
    if (raw is! List) return const [];
    return raw.map<Rule>((item) {
      if (item is String) return autoDetect(item);
      if (item is Map<String, dynamic>) return Rule.fromJson(item);
      throw FormatException('Unsupported rule shape: $item');
    }).toList();
  }

  /// Smart defaults for the simple string form. Designed to be intuitive
  /// for the common cases shown in challenge specs.
  static Rule _autoDetectHtml(String s) {
    final v = s.trim();
    // "quoted text" → text content match
    if (v.length >= 2 && v.startsWith('"') && v.endsWith('"')) {
      return Rule(type: Rule.htmlText, value: v.substring(1, v.length - 1));
    }
    // attr=value or attr= → attribute presence
    if (v.contains('=')) {
      final name = v.split('=').first.trim();
      return Rule(type: Rule.htmlAttribute, value: name);
    }
    // default: tag
    return Rule(type: Rule.htmlTag, value: v);
  }

  static Rule _autoDetectCss(String s) {
    final v = s.trim();
    // Selector hints: .class, #id, :pseudo, [attr], *, contains space
    if (v.startsWith('.') ||
        v.startsWith('#') ||
        v.startsWith(':') ||
        v.startsWith('[') ||
        v.startsWith('*') ||
        v.contains(' ') ||
        v.contains('>')) {
      return Rule(type: Rule.cssSelector, value: v);
    }
    // Hyphenated → very likely a property (border-radius, font-family)
    if (v.contains('-')) {
      return Rule(type: Rule.cssProperty, value: v);
    }
    // Lone word → most often a property in challenge specs (color, padding)
    // Catalog authors needing a tag selector ('body') should use explicit form.
    return Rule(type: Rule.cssProperty, value: v);
  }

  static Rule _autoDetectJs(String s) {
    final v = s.trim();
    // Method form like "getElementById" or "document.getElementById"
    if (v.contains('.') || _isDomMethodName(v)) {
      final lastDot = v.lastIndexOf('.');
      return Rule(
        type: Rule.jsDom,
        value: lastDot >= 0 ? v.substring(lastDot + 1) : v,
      );
    }
    return Rule(type: Rule.jsFunction, value: v);
  }

  static bool _isDomMethodName(String s) {
    const dom = {
      'getElementById',
      'querySelector',
      'querySelectorAll',
      'getElementsByClassName',
      'getElementsByTagName',
      'addEventListener',
      'removeEventListener',
      'createElement',
      'appendChild',
      'removeChild',
      'setAttribute',
      'classList',
    };
    return dom.contains(s);
  }
}

/// A single coding challenge.
class Challenge {
  final String id;
  final String title;
  final String description;
  final Difficulty difficulty;
  final List<String> instructions;
  final String starterHtml;
  final String starterCss;
  final String starterJs;
  final ExpectedRules expectedRules;
  final int xpReward;
  final String hint;
  final Map<String, String> solution;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.instructions,
    required this.starterHtml,
    required this.starterCss,
    required this.starterJs,
    required this.expectedRules,
    required this.xpReward,
    required this.hint,
    required this.solution,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'difficulty': difficulty.key,
        'instructions': instructions,
        'starterHtml': starterHtml,
        'starterCss': starterCss,
        'starterJs': starterJs,
        'expectedRules': expectedRules.toJson(),
        'xpReward': xpReward,
        'hint': hint,
        'solution': solution,
      };

  factory Challenge.fromJson(Map<String, dynamic> j) => Challenge(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        difficulty: Difficulty.values.firstWhere(
          (d) => d.key == (j['difficulty'] as String),
          orElse: () => Difficulty.beginner,
        ),
        instructions: List<String>.from(j['instructions'] as List),
        starterHtml: j['starterHtml'] as String? ?? '',
        starterCss: j['starterCss'] as String? ?? '',
        starterJs: j['starterJs'] as String? ?? '',
        expectedRules: ExpectedRules.fromJson(
          j['expectedRules'] as Map<String, dynamic>? ?? const {},
        ),
        xpReward: j['xpReward'] as int? ?? 0,
        hint: j['hint'] as String? ?? '',
        solution: Map<String, String>.from(j['solution'] as Map),
      );
}
