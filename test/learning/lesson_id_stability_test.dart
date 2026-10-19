import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards against accidental ID renames that would orphan user progress.
void main() {
  test('core web lesson ids unchanged', () {
    const expected = {
      'h1_heading',
      'b01_html',
      'b02_css',
      'b03_js',
      'a04_mini_projects',
    };
    for (final id in expected) {
      expect(LessonsCatalog.byId(id), isNotNull, reason: id);
    }
  });

  test('extended track id scheme stable', () {
    expect(LessonsCatalog.byId('php_01')?.title, 'What Is PHP?');
    expect(LessonsCatalog.byId('php_24')?.title, 'Prepared Statements');
    expect(LessonsCatalog.byId('sql_36')?.title, 'SQL Injection Prevention');
    expect(LessonsCatalog.byId('typescript_10')?.title, 'Generics');
    expect(LessonsCatalog.byId('web_essentials_23')?.title, 'API Error Handling');
  });
}
