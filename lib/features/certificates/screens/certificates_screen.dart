import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../models/certificate.dart';
import '../providers/certificates_provider.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});
  static const route = '/certificates';

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CertificatesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificatesProvider>();
    final ctx = provider.snapshotContext();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: provider.totalCount == 0
                ? 0
                : provider.earnedCount / provider.totalCount,
            minHeight: 4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderSummary(
            earned: provider.earnedCount,
            total: provider.totalCount,
          ),
          const SizedBox(height: 20),
          ...provider.all.map((cert) {
            final earned = provider.isEarned(cert.id);
            final earnedAt = provider.earnedAt(cert.id);
            final progress = cert.progress(ctx);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CertificateRow(
                certificate: cert,
                earned: earned,
                earnedAt: earnedAt,
                progress: progress,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.certificateDetail,
                  arguments: CertificateDetailArguments(
                    certificateId: cert.id,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  final int earned;
  final int total;
  const _HeaderSummary({required this.earned, required this.total});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF6C5CE7);
    final ratio = total == 0 ? 0.0 : earned / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.3 : 0.2),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Certificates',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '$earned of $total earned',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateRow extends StatelessWidget {
  final Certificate certificate;
  final bool earned;
  final DateTime? earnedAt;
  final double progress;
  final VoidCallback onTap;

  const _CertificateRow({
    required this.certificate,
    required this.earned,
    required this.earnedAt,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141820) : Colors.white;
    final accent = certificate.accentColor;
    final borderColor = earned
        ? accent.withValues(alpha: 0.5)
        : (isDark
            ? const Color(0xFF262B35)
            : const Color(0xFFE4E7EE));

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: earned ? 1.2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  earned ? certificate.icon : Icons.lock_outline,
                  color:
                      earned ? accent : Theme.of(context).disabledColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            certificate.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (earned)
                          Icon(Icons.check_circle, color: accent, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      certificate.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    if (earned)
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 11,
                              color: Theme.of(context).disabledColor),
                          const SizedBox(width: 3),
                          Text(
                            earnedAt != null
                                ? 'Earned ${_formatDate(earnedAt!)}'
                                : 'Earned',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: accent.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation(accent),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${(progress * 100).round()}% complete',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
