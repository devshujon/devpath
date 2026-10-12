import '../models/challenge.dart';
import '../models/validation_result.dart';

/// Regex-driven validator. Stateless — instantiate once and reuse.
///
/// Design notes:
///   - The validator is intentionally permissive about whitespace, attribute
///     ordering, and quote styles.
///   - HTML comments are stripped before checking so a commented-out
///     `<button>` doesn't pass a "must have button" rule.
///   - CSS strings are NOT stripped of `/* */` comments — the assumption is
///     a commented-out property still demonstrates knowledge. Adjust if
///     stricter checking is needed.
///   - JS strings are NOT stripped of `//` or `/* */` either, same reason.
class ChallengeValidator {
  const ChallengeValidator();

  ValidationResult validate({
    required String html,
    required String css,
    required String js,
    required ExpectedRules expected,
  }) {
    final stripped = _stripHtmlComments(html);
    final checks = <RuleCheck>[];

    for (final r in expected.html) {
      checks.add(RuleCheck(
        area: 'HTML',
        rule: r,
        passed: _checkHtml(stripped, r),
      ));
    }
    for (final r in expected.css) {
      checks.add(RuleCheck(
        area: 'CSS',
        rule: r,
        passed: _checkCss(css, r),
      ));
    }
    for (final r in expected.js) {
      checks.add(RuleCheck(
        area: 'JS',
        rule: r,
        passed: _checkJs(js, r),
      ));
    }

    final passedCount = checks.where((c) => c.passed).length;
    final total = checks.length;
    final score = total == 0 ? 100 : ((passedCount / total) * 100).round();
    final allPassed = total > 0 && passedCount == total;

    return ValidationResult(
      passed: allPassed,
      score: score,
      checks: checks,
      missing: checks
          .where((c) => !c.passed)
          .map((c) => MissingRule(area: c.area, description: c.description))
          .toList(),
    );
  }

  // ── HTML ──

  bool _checkHtml(String html, Rule r) {
    switch (r.type) {
      case Rule.htmlTag:
        return _matchTag(html, r.value);
      case Rule.htmlAttribute:
        return _matchAttribute(html, r.value, onTag: r.onTag);
      case Rule.htmlText:
        return _matchText(html, r.value);
    }
    return false;
  }

  bool _matchTag(String html, String tag) {
    final tagEscaped = _escapeRegex(tag);
    // <button>, <button />, <button class="…">, etc. Reject </button> (closing).
    final re = RegExp(r'<' + tagEscaped + r'(?:\s|/?>)', caseSensitive: false);
    return re.hasMatch(html);
  }

  bool _matchAttribute(String html, String attr, {String? onTag}) {
    final attrEscaped = _escapeRegex(attr);
    if (onTag == null) {
      // Any tag with this attribute, value form or boolean form.
      // Examples: onclick="x", required, type='button'
      final re = RegExp(
        r'<[a-zA-Z][^>]*?\b' + attrEscaped + r'(?:\s*=\s*[^>]+|[\s/>])',
        caseSensitive: false,
      );
      return re.hasMatch(html);
    }
    final tagEscaped = _escapeRegex(onTag);
    // Open tag of onTag that contains the attribute somewhere in its content.
    final re = RegExp(
      r'<' + tagEscaped + r'\s[^>]*\b' + attrEscaped + r'(?:\s*=\s*[^>]+|[\s/>])',
      caseSensitive: false,
    );
    return re.hasMatch(html);
  }

  bool _matchText(String html, String text) {
    return html.toLowerCase().contains(text.toLowerCase());
  }

  // ── CSS ──

  bool _checkCss(String css, Rule r) {
    switch (r.type) {
      case Rule.cssSelector:
        return _matchSelector(css, r.value);
      case Rule.cssProperty:
        return _matchProperty(css, r.value);
    }
    return false;
  }

  bool _matchSelector(String css, String selector) {
    final escaped = _escapeRegex(selector);
    // selector followed by `{` or `,` or whitespace then `{`/`,`/another selector char
    // Allows multi-selector rules: `body, h1 { ... }`.
    final re = RegExp(
      r'(?:^|[\s,}])' + escaped + r'\s*(?:\{|,|\s+\{|:[a-zA-Z\-]+\s*\{)',
      caseSensitive: false,
    );
    return re.hasMatch(css);
  }

  bool _matchProperty(String css, String property) {
    final escaped = _escapeRegex(property);
    // property name followed by `:` — must be at a word boundary so
    // "border-radius" doesn't match against "no-border-radius" (rare,
    // but worth guarding).
    final re = RegExp(
      r'(?:^|[\s;{])' + escaped + r'\s*:',
      caseSensitive: false,
    );
    return re.hasMatch(css);
  }

  // ── JS ──

  bool _checkJs(String js, Rule r) {
    switch (r.type) {
      case Rule.jsFunction:
        return _matchFunction(js, r.value);
      case Rule.jsDom:
        return _matchDomCall(js, r.value);
    }
    return false;
  }

  bool _matchFunction(String js, String name) {
    final escaped = _escapeRegex(name);

    // Form 1: function declaration — `function name(...)`
    final fnDecl = RegExp(r'\bfunction\s+' + escaped + r'\s*\(');
    if (fnDecl.hasMatch(js)) return true;

    // Form 2: function expression — `const name = function(...) {}`
    //                                  `let name = function(...) {}`
    //                                  `var name = function(...) {}`
    final fnExpr = RegExp(
      r'\b(?:const|let|var)\s+' + escaped + r'\s*=\s*function\b',
    );
    if (fnExpr.hasMatch(js)) return true;

    // Form 3: arrow function — `const name = (...) => ...`
    //                          `const name = a => ...`
    final arrow = RegExp(
      r'\b(?:const|let|var)\s+' + escaped + r"\s*=\s*(?:\([^)]*\)|[a-zA-Z_\$][\w\$]*)\s*=>",
    );
    if (arrow.hasMatch(js)) return true;

    // Form 4: object method shorthand — `{ name(...) { } }`
    // This is permissive: any `name(` after `{` or `,` with following `{`.
    final shorthand = RegExp(
      r'(?:^|[\s,{])' + escaped + r'\s*\([^)]*\)\s*\{',
    );
    if (shorthand.hasMatch(js)) return true;

    return false;
  }

  bool _matchDomCall(String js, String method) {
    final escaped = _escapeRegex(method);
    // `.getElementById(` — dot then method then optional space then `(`.
    final re = RegExp(r'\.' + escaped + r'\s*\(');
    return re.hasMatch(js);
  }

  // ── Helpers ──

  String _stripHtmlComments(String html) =>
      html.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');

  String _escapeRegex(String s) {
    // RegExp.escape would be nice but isn't in dart:core. Manual escape:
    return s.replaceAllMapped(
      RegExp(r'[\\^$.|?*+()\[\]{}/]'),
      (m) => '\\${m[0]}',
    );
  }
}
