import 'external_file_kind.dart';

/// Parsed Android open intent after content has been read.
class ExternalOpenPayload {
  final String uri;
  final String action;
  final String? mimeType;
  final String displayName;
  final int? sizeBytes;
  final ExternalFileKind kind;
  final String content;

  const ExternalOpenPayload({
    required this.uri,
    required this.action,
    required this.mimeType,
    required this.displayName,
    required this.sizeBytes,
    required this.kind,
    required this.content,
  });

  /// Stable key for deduplicating repeated delivery of the same intent.
  String get dedupeKey => '$action|$uri|${content.length}';
}

/// Raw intent metadata from Android before reading bytes.
class ExternalOpenIntent {
  final String uri;
  final String action;
  final String? mimeType;
  final String? displayName;
  final int? sizeBytes;
  final String? inlineText;

  const ExternalOpenIntent({
    required this.uri,
    required this.action,
    this.mimeType,
    this.displayName,
    this.sizeBytes,
    this.inlineText,
  });

  factory ExternalOpenIntent.fromMap(Map<dynamic, dynamic> map) {
    return ExternalOpenIntent(
      uri: map['uri'] as String? ?? '',
      action: map['action'] as String? ?? 'view',
      mimeType: map['mimeType'] as String?,
      displayName: map['displayName'] as String?,
      sizeBytes: (map['sizeBytes'] as num?)?.toInt(),
      inlineText: map['inlineText'] as String?,
    );
  }

  bool get isValid => uri.isNotEmpty || (inlineText != null && inlineText!.isNotEmpty);
}
