import 'package:devpath/features/editor/providers/playground_provider.dart';
import 'package:devpath/features/editor/services/lesson_templates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tabs preserve independent buffers when switching', () {
    final p = PlaygroundProvider();
    p.updateCurrent('<!-- html edit -->');
    p.switchTab(PlaygroundTab.css);
    p.updateCurrent('body{}');
    p.switchTab(PlaygroundTab.js);
    p.updateCurrent('console.log(1)');
    p.switchTab(PlaygroundTab.html);
    expect(p.htmlDraft, contains('html edit'));
    p.switchTab(PlaygroundTab.css);
    expect(p.cssDraft, 'body{}');
    p.switchTab(PlaygroundTab.js);
    expect(p.jsDraft, contains('console.log'));
  });

  test('run commits drafts without clearing editor buffers', () {
    final p = PlaygroundProvider();
    p.updateCurrent('<p>draft</p>');
    p.run();
    expect(p.htmlDraft, contains('draft'));
    expect(p.htmlCommitted, contains('draft'));
    p.updateCurrent('<p>after run</p>');
    expect(p.htmlCommitted, contains('draft'));
    expect(p.htmlDraft, contains('after run'));
  });

  test('loadLesson copies template without mutating catalog', () {
    final template = LessonTemplates.byId('todo_list')!;
    final htmlBefore = template.html;
    final p = PlaygroundProvider();
    p.loadLesson(template);
    expect(p.htmlDraft, htmlBefore);
    expect(p.projectId, isNull);
    expect(LessonTemplates.byId('todo_list')!.html, htmlBefore);
  });

  test('loadProject restores all three buffers', () {
    final p = PlaygroundProvider();
    p.loadStarterCode({
      'html': '<h1>P</h1>',
      'css': 'h1{color:red}',
      'js': 'void f(){}',
    });
    expect(p.htmlDraft, contains('P'));
    expect(p.cssDraft, contains('red'));
    expect(p.jsDraft, contains('f'));
  });
}
