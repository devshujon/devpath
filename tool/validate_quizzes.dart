// Run with: dart run tool/validate_quizzes.dart
// Exits non-zero if any quiz file has issues. Hook into pre-ship checklist.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final quizDir = Directory(args.isNotEmpty ? args[0] : 'assets/quizzes');

  if (!quizDir.existsSync()) {
    stderr.writeln('Directory not found: ${quizDir.path}');
    exit(1);
  }

  var errors = 0;
  var fileCount = 0;
  var questionCount = 0;

  final entities = quizDir.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in entities) {
    if (!file.path.endsWith('.json')) continue;
    fileCount++;

    Map<String, dynamic> data;
    try {
      data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    } catch (e) {
      stderr.writeln('${file.path}: JSON parse failed — $e');
      errors++;
      continue;
    }

    final list = data['questions'] as List? ?? [];
    final seenIds = <String>{};

    for (var i = 0; i < list.length; i++) {
      questionCount++;
      final q = list[i] as Map<String, dynamic>;
      final id = q['id']?.toString() ?? '<no id>';
      final loc = '${file.path}[$i / id=$id]';

      if (!seenIds.add(id)) {
        stderr.writeln('$loc: duplicate question id');
        errors++;
      }

      final text = (q['question'] as String?)?.trim() ?? '';
      if (text.isEmpty) {
        stderr.writeln('$loc: empty question text');
        errors++;
      }

      final rawOptions = q['options'];
      if (rawOptions is! List) {
        stderr.writeln('$loc: options is not a list');
        errors++;
        continue;
      }
      final options = rawOptions.cast<String>();

      if (options.length < 2 || options.length > 6) {
        stderr.writeln(
            '$loc: expected 2-6 options, got ${options.length}');
        errors++;
      }

      for (var j = 0; j < options.length; j++) {
        if (options[j].trim().isEmpty) {
          stderr.writeln('$loc: option $j is empty');
          errors++;
        }
      }

      final normalized = options.map((o) => o.trim().toLowerCase()).toList();
      if (normalized.toSet().length != normalized.length) {
        final dups = <String>{};
        for (var j = 0; j < normalized.length; j++) {
          if (normalized.indexOf(normalized[j]) != j) dups.add(options[j]);
        }
        stderr.writeln('$loc: DUPLICATE OPTIONS: $dups');
        errors++;
      }

      final idx = q['correctIndex'];
      if (idx is! int || idx < 0 || idx >= options.length) {
        stderr.writeln(
            '$loc: invalid correctIndex "$idx" (options=${options.length})');
        errors++;
      }

      final level = q['level']?.toString();
      if (!const ['beginner', 'intermediate', 'advanced'].contains(level)) {
        stderr.writeln('$loc: invalid level "$level"');
        errors++;
      }
    }
  }

  stdout.writeln('Checked $fileCount file(s), $questionCount question(s).');
  if (errors > 0) {
    stderr.writeln('$errors error(s) found.');
    exit(1);
  }
  stdout.writeln('All quiz JSON files valid.');
}
