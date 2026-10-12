import 'challenge.dart';

/// Per-rule outcome from the validator.
class RuleCheck {
  /// 'HTML' | 'CSS' | 'JS' — which area this rule applied to.
  final String area;
  final Rule rule;
  final bool passed;

  /// Human-readable label, e.g. "<button> tag" or "border-radius property".
  String get description => rule.describe();

  const RuleCheck({
    required this.area,
    required this.rule,
    required this.passed,
  });
}

/// Compact failure representation used in the failure sheet.
class MissingRule {
  final String area;
  final String description;
  const MissingRule({required this.area, required this.description});
}

class ValidationResult {
  /// True only when every rule passed (and there was at least one rule).
  final bool passed;

  /// 0-100, percentage of rules that passed.
  final int score;
  final List<RuleCheck> checks;
  final List<MissingRule> missing;

  const ValidationResult({
    required this.passed,
    required this.score,
    required this.checks,
    required this.missing,
  });

  int get totalRules => checks.length;
  int get passedRules => checks.where((c) => c.passed).length;

  Map<String, dynamic> toJson() => {
        'passed': passed,
        'score': score,
        'missing': missing.map((m) => {'area': m.area, 'description': m.description}).toList(),
      };
}
