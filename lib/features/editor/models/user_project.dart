import 'dart:convert';

/// A user-saved playground project.
///
/// Stored as JSON in SharedPreferences (one key per project). Use this
/// model rather than the older `Project` class (which is for the
/// Hive-backed multi-file Editor and is unrelated to playground saves).
class UserProject {
  final String id;
  final String title;
  final String htmlCode;
  final String cssCode;
  final String jsCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpened;

  /// If this project was started from a lesson template, the lesson's
  /// stable id is recorded here so the user can re-enter the lesson
  /// flow and so analytics can attribute completions to lessons.
  final String? lessonId;

  /// Optional small base64-PNG thumbnail. Not generated automatically;
  /// reserved for a future "snapshot preview" feature. Kept here so the
  /// schema is stable.
  final String? thumbnail;

  const UserProject({
    required this.id,
    required this.title,
    required this.htmlCode,
    required this.cssCode,
    required this.jsCode,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpened,
    this.lessonId,
    this.thumbnail,
  });

  UserProject copyWith({
    String? id,
    String? title,
    String? htmlCode,
    String? cssCode,
    String? jsCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastOpened,
    String? lessonId,
    String? thumbnail,
    bool clearLessonId = false,
    bool clearThumbnail = false,
    bool clearLastOpened = false,
  }) {
    return UserProject(
      id: id ?? this.id,
      title: title ?? this.title,
      htmlCode: htmlCode ?? this.htmlCode,
      cssCode: cssCode ?? this.cssCode,
      jsCode: jsCode ?? this.jsCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpened:
          clearLastOpened ? null : (lastOpened ?? this.lastOpened),
      lessonId: clearLessonId ? null : (lessonId ?? this.lessonId),
      thumbnail: clearThumbnail ? null : (thumbnail ?? this.thumbnail),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'htmlCode': htmlCode,
        'cssCode': cssCode,
        'jsCode': jsCode,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (lastOpened != null) 'lastOpened': lastOpened!.toIso8601String(),
        if (lessonId != null) 'lessonId': lessonId,
        if (thumbnail != null) 'thumbnail': thumbnail,
      };

  factory UserProject.fromJson(Map<String, dynamic> json) {
    return UserProject(
      id: json['id'] as String,
      title: json['title'] as String,
      htmlCode: json['htmlCode'] as String? ?? '',
      cssCode: json['cssCode'] as String? ?? '',
      jsCode: json['jsCode'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastOpened: json['lastOpened'] != null
          ? DateTime.parse(json['lastOpened'] as String)
          : null,
      lessonId: json['lessonId'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  String encode() => jsonEncode(toJson());

  static UserProject decode(String raw) =>
      UserProject.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserProject && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
