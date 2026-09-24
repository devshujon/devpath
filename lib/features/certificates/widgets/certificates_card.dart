import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/certificates_provider.dart';

class CertificatesCard extends StatelessWidget {
  final VoidCallback onTap;

  const CertificatesCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificatesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF6C5CE7);
    final earned = provider.earnedCount;
    final total = provider.totalCount;
    final ratio = total == 0 ? 0.0 : earned / total;

    return Material(
      color: isDark ? const Color(0xFF141820) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF262B35)
                  : const Color(0xFFE4E7EE),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Certificates',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '$earned / $total',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      earned == 0
                          ? 'Complete a track to earn your first certificate'
                          : earned == total
                              ? "You've earned every certificate!"
                              : '$earned earned · keep going',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          backgroundColor: accent.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
