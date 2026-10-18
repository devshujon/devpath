import 'package:devpath/features/editor/services/lesson_templates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog has ten starter templates with html buffers', () {
    expect(LessonTemplates.all.length, 10);
    for (final t in LessonTemplates.all) {
      expect(t.html.trim().isNotEmpty, isTrue, reason: t.id);
      expect(t.title.trim().isNotEmpty, isTrue);
    }
  });

  test('legacy lesson ids still resolve', () {
    expect(LessonTemplates.byId('html_basics')?.id, 'basic_html_page');
    expect(LessonTemplates.byId('forms')?.id, 'login_form_ui');
    expect(LessonTemplates.byId('js_basics')?.id, 'simple_quiz_app');
  });

  test('catalog entries are immutable const templates', () {
    final t = LessonTemplates.byId('calculator')!;
    final htmlBefore = t.html;
    expect(htmlBefore.trim().isNotEmpty, isTrue);
    expect(LessonTemplates.byId('calculator')!.html, htmlBefore);
  });
}
