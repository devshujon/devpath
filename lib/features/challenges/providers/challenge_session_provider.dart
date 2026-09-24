import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/challenge.dart';
import '../models/validation_result.dart';
import '../services/challenge_validator.dart';

/// Editor tab marker. Local to challenges so we don't couple to
/// PlaygroundProvider's enum (which lives in the editor feature).
enum ChallengeTab { html, css, js }

extension ChallengeTabLabel on ChallengeTab {
  String get label => switch (this) {
        ChallengeTab.html => 'HTML',
        ChallengeTab.css => 'CSS',
        ChallengeTab.js => 'JS',
      };

  String get filename => switch (this) {
        ChallengeTab.html => 'index.html',
        ChallengeTab.css => 'style.css',
        ChallengeTab.js => 'script.js',
      };
}

/// State for one challenge-solving session. Created when a user opens
/// a challenge; destroyed when they leave.
///
/// Follows the same draft/committed pattern as PlaygroundProvider:
/// drafts update silently on every keystroke; the preview only reloads
/// on Run / Submit / Reset / Show Solution.
class ChallengeSessionProvider extends ChangeNotifier {
  static const _validator = ChallengeValidator();

  final Challenge challenge;

  // Drafts — silent
  String _htmlDraft;
  String _cssDraft;
  String _jsDraft;

  // Committed — what the preview renders
  String _htmlCommitted;
  String _cssCommitted;
  String _jsCommitted;

  ChallengeTab _selectedTab = ChallengeTab.html;
  int _runVersion = 0;

  ValidationResult? _lastResult;
  bool _hintShown = false;
  bool _solutionShown = false;

  ChallengeSessionProvider(this.challenge)
      : _htmlDraft = challenge.starterHtml,
        _cssDraft = challenge.starterCss,
        _jsDraft = challenge.starterJs,
        _htmlCommitted = challenge.starterHtml,
        _cssCommitted = challenge.starterCss,
        _jsCommitted = challenge.starterJs;

  // ── Getters ──
  String get htmlDraft => _htmlDraft;
  String get cssDraft => _cssDraft;
  String get jsDraft => _jsDraft;
  String get htmlCommitted => _htmlCommitted;
  String get cssCommitted => _cssCommitted;
  String get jsCommitted => _jsCommitted;
  ChallengeTab get selectedTab => _selectedTab;
  int get runVersion => _runVersion;
  ValidationResult? get lastResult => _lastResult;
  bool get hintShown => _hintShown;
  bool get solutionShown => _solutionShown;

  String get currentDraft => switch (_selectedTab) {
        ChallengeTab.html => _htmlDraft,
        ChallengeTab.css => _cssDraft,
        ChallengeTab.js => _jsDraft,
      };

  // ── Draft updates ──
  void updateCurrent(String code) {
    switch (_selectedTab) {
      case ChallengeTab.html:
        if (_htmlDraft == code) return;
        _htmlDraft = code;
      case ChallengeTab.css:
        if (_cssDraft == code) return;
        _cssDraft = code;
      case ChallengeTab.js:
        if (_jsDraft == code) return;
        _jsDraft = code;
    }
    // No notify — keystroke shouldn't rebuild
  }

  void switchTab(ChallengeTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  void run() {
    _htmlCommitted = _htmlDraft;
    _cssCommitted = _cssDraft;
    _jsCommitted = _jsDraft;
    _runVersion++;
    notifyListeners();
  }

  void reset() {
    _htmlDraft = challenge.starterHtml;
    _cssDraft = challenge.starterCss;
    _jsDraft = challenge.starterJs;
    _htmlCommitted = challenge.starterHtml;
    _cssCommitted = challenge.starterCss;
    _jsCommitted = challenge.starterJs;
    _hintShown = false;
    _solutionShown = false;
    _lastResult = null;
    _runVersion++;
    notifyListeners();
  }

  Future<String> copyCurrentTab() async {
    await Clipboard.setData(ClipboardData(text: currentDraft));
    return _selectedTab.label;
  }

  // ── Hints & solution ──
  void toggleHint() {
    _hintShown = !_hintShown;
    notifyListeners();
  }

  /// Load the official solution into the editor buffers and commit. The
  /// user can study it side-by-side with the preview. Marks
  /// solutionShown so the UI can note this affected submission rights.
  void revealSolution() {
    _htmlDraft = challenge.solution['html'] ?? _htmlDraft;
    _cssDraft = challenge.solution['css'] ?? _cssDraft;
    _jsDraft = challenge.solution['js'] ?? _jsDraft;
    _htmlCommitted = _htmlDraft;
    _cssCommitted = _cssDraft;
    _jsCommitted = _jsDraft;
    _solutionShown = true;
    _runVersion++;
    notifyListeners();
  }

  // ── Submission ──

  /// Validates the current draft against [challenge.expectedRules]. Also
  /// commits drafts to the preview so the user sees what the validator
  /// saw. Stores the result for UI inspection.
  ValidationResult submit() {
    // Always run on submit so the preview reflects the validated source.
    _htmlCommitted = _htmlDraft;
    _cssCommitted = _cssDraft;
    _jsCommitted = _jsDraft;
    _runVersion++;

    _lastResult = _validator.validate(
      html: _htmlDraft,
      css: _cssDraft,
      js: _jsDraft,
      expected: challenge.expectedRules,
    );
    notifyListeners();
    return _lastResult!;
  }
}
