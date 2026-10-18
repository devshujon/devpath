import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/challenge.dart';
import '../providers/daily_challenge_provider.dart';

class DailyChallengeCard extends StatelessWidget {
  /// Callback receives the challenge to open. Parent decides routing.
  final void Function(Challenge challenge) onContinue;

  const DailyChallengeCard({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyChallengeProvider>();
    final challenge = daily.todaysChallenge;
    final completed = daily.completedToday;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amber = const Color(0xFFFFB020);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: completed
              ? [
                  const Color(0xFF00B894),
                  const Color(0xFF00B894).withValues(alpha: 0.7),
                ]
              : [amber, amber.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (completed
                    ? const Color(0xFF00B894)
                    : amber)
                .withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  completed ? Icons.check : Icons.bolt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      completed
                          ? "Daily Challenge — done!"
                          : "Today's Challenge",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!completed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${daily.xpForToday()} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            challenge.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                    completed ? const Color(0xFF00B894) : amber,
                elevation: 0,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: Icon(
                completed ? Icons.replay : Icons.play_arrow,
                size: 18,
              ),
              label: Text(
                completed ? 'Try again' : 'Start',
              ),
              onPressed: () => onContinue(challenge),
            ),
          ),
        ],
      ),
    );
  }
}
