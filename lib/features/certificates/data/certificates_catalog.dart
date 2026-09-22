import 'package:flutter/material.dart';

import '../../learning/models/lesson.dart' show LessonTrack;
import '../models/certificate.dart';

/// Four certificates. NO lesson IDs are hardcoded here — track-based
/// gating queries [LessonsCatalog.byTrack] at evaluation time, so
/// growing the catalog automatically extends the requirement.
class CertificatesCatalog {
  CertificatesCatalog._();

  static const List<Certificate> all = [
    _html,
    _css,
    _javascript,
    _graduate,
  ];

  static Certificate? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}

const _html = Certificate(
  id: 'cert_html',
  kind: CertificateKind.html,
  title: 'HTML Beginner Certificate',
  description:
      'Awarded for completing every lesson in the HTML curriculum track.',
  icon: Icons.code,
  accentColor: Color(0xFFE17055),
  requiredTrack: LessonTrack.html,
);

const _css = Certificate(
  id: 'cert_css',
  kind: CertificateKind.css,
  title: 'CSS Certificate',
  description:
      'Awarded for completing every lesson in the CSS curriculum track.',
  icon: Icons.palette_outlined,
  accentColor: Color(0xFF0984E3),
  requiredTrack: LessonTrack.css,
);

const _javascript = Certificate(
  id: 'cert_js',
  kind: CertificateKind.javascript,
  title: 'JavaScript Certificate',
  description:
      'Awarded for completing every lesson in the JavaScript curriculum track.',
  icon: Icons.javascript_outlined,
  accentColor: Color(0xFFFFB020),
  requiredTrack: LessonTrack.js,
);

const _graduate = Certificate(
  id: 'cert_graduate',
  kind: CertificateKind.graduate,
  title: 'DevPath Graduate Certificate',
  description:
      'Awarded for completing every lesson and every coding challenge in DevPath.',
  icon: Icons.school_outlined,
  accentColor: Color(0xFF6C5CE7),
  requireAllLessons: true,
  requireAllChallenges: true,
);
