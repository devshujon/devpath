import 'package:flutter/material.dart';

import '../models/challenge.dart';

class InstructionsCard extends StatefulWidget {
  final Challenge challenge;

  const InstructionsCard({super.key, required this.challenge});

  @override
  State<InstructionsCard> createState() => _InstructionsCardState();
}

class _InstructionsCardState extends State<InstructionsCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);
    final ch = widget.challenge;

    return Material(
      color: bg,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    _DifficultyDot(color: ch.difficulty.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ch.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ch.difficulty.label} · +${ch.xpReward} XP',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? const Color(0xFF8A929D)
                                      : const Color(0xFF5D6670),
                                ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ch.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    ...ch.instructions.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: ch.difficulty.color
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${e.key + 1}',
                                    style: TextStyle(
                                      color: ch.difficulty.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              secondChild: const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyDot extends StatelessWidget {
  final Color color;
  const _DifficultyDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
