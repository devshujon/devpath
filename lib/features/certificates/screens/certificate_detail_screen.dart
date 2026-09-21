import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/certificates_catalog.dart';
import '../models/certificate.dart';
import '../providers/certificates_provider.dart';
import '../services/certificate_image.dart';
import '../widgets/certificate_view.dart';

class CertificateDetailScreen extends StatefulWidget {
  const CertificateDetailScreen({super.key});
  static const route = '/certificate-detail';

  @override
  State<CertificateDetailScreen> createState() =>
      _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as CertificateDetailArguments?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Open a certificate from the list.')),
      );
    }
    final certificate = CertificatesCatalog.byId(args.certificateId);
    if (certificate == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Certificate not found: ${args.certificateId}'),
        ),
      );
    }

    final provider = context.watch<CertificatesProvider>();
    final ctx = provider.snapshotContext();
    final earned = provider.isEarned(certificate.id);
    final earnedAt = provider.earnedAt(certificate.id);
    final progress = certificate.progress(ctx);

    return Scaffold(
      appBar: AppBar(title: Text(certificate.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // The RepaintBoundary is what gets captured for sharing.
          // Locked state shows the same view with a PREVIEW watermark.
          RepaintBoundary(
            key: _boundaryKey,
            child: CertificateView(
              certificate: certificate,
              issuedAt: earned ? earnedAt : null,
              showPreviewWatermark: !earned,
            ),
          ),
          const SizedBox(height: 20),
          _StatusBlock(
            earned: earned,
            earnedAt: earnedAt,
            progress: progress,
            accentColor: certificate.accentColor,
          ),
          const SizedBox(height: 16),
          Text(
            certificate.description,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.5),
          ),
          if (!earned) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: certificate.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: certificate.accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Keep completing lessons and challenges to unlock "
                      "this certificate. It'll appear here automatically.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: certificate.accentColor,
            ),
            icon: _sharing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.share),
            label: Text(earned ? 'Share certificate' : 'Share preview'),
            onPressed: _sharing ? null : () => _share(context, certificate),
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, Certificate certificate) async {
    setState(() => _sharing = true);
    try {
      final path = await CertificateImage.instance.shareFromBoundary(
        boundaryKey: _boundaryKey,
        certificate: certificate,
      );
      if (!context.mounted) return;
      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not generate certificate image. Try again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

class _StatusBlock extends StatelessWidget {
  final bool earned;
  final DateTime? earnedAt;
  final double progress;
  final Color accentColor;

  const _StatusBlock({
    required this.earned,
    required this.earnedAt,
    required this.progress,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (earned) {
      return Row(
        children: [
          Icon(Icons.verified, color: accentColor, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earned',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                ),
                if (earnedAt != null)
                  Text(
                    'Issued on ${_formatDate(earnedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Progress',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: accentColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(accentColor),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class CertificateDetailArguments {
  final String certificateId;
  const CertificateDetailArguments({required this.certificateId});
}
