import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'quiz_question_timer_config.dart';

/// Countdown driven by scheduled tick deltas (works with Flutter test `pump`).
class QuizQuestionTimer {
  QuizQuestionTimer({
    Duration? duration,
    this.onExpired,
    this.onTick,
    Duration tickInterval = const Duration(milliseconds: 250),
  })  : duration = duration ?? QuizQuestionTimerConfig.perQuestionDuration,
        _tickInterval = tickInterval;

  final Duration duration;
  final Duration _tickInterval;
  final VoidCallback? onExpired;
  final void Function(Duration remaining)? onTick;

  Timer? _tickTimer;
  int _remainingMs = 0;
  bool _stopped = false;
  bool _expired = false;
  bool _paused = false;

  bool get isExpired => _expired;
  bool get isRunning => !_stopped && !_expired && !_paused && _tickTimer != null;

  Duration remaining() {
    if (_expired || _stopped) return Duration.zero;
    return Duration(milliseconds: math.max(0, _remainingMs));
  }

  void start() {
    stop(keepExpired: false);
    _remainingMs = duration.inMilliseconds;
    _stopped = false;
    _expired = false;
    _paused = false;
    _scheduleTick();
    onTick?.call(remaining());
  }

  void stop({bool keepExpired = true}) {
    _tickTimer?.cancel();
    _tickTimer = null;
    _stopped = true;
    if (!keepExpired) {
      _expired = false;
    }
    _paused = false;
  }

  void pause() {
    if (_stopped || _expired || _paused) return;
    _paused = true;
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  void resume() {
    if (!_paused || _stopped || _expired) return;
    _paused = false;
    _scheduleTick();
    onTick?.call(remaining());
  }

  void dispose() {
    stop(keepExpired: true);
  }

  void _scheduleTick() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  void _onTick() {
    if (_stopped || _expired || _paused) return;
    _remainingMs = math.max(0, _remainingMs - _tickInterval.inMilliseconds);
    final left = remaining();
    onTick?.call(left);
    if (_remainingMs <= 0) {
      _expired = true;
      _stopped = true;
      _tickTimer?.cancel();
      _tickTimer = null;
      onExpired?.call();
    }
  }

  @visibleForTesting
  void debugFireExpiryForTests() {
    _remainingMs = 0;
    _expired = true;
    _stopped = true;
    _tickTimer?.cancel();
    _tickTimer = null;
    onExpired?.call();
  }
}
