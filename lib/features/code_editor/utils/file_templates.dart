import '../models/editor_file_type.dart';

class FileTemplates {
  FileTemplates._();

  static String starter(EditorFileKind kind) => switch (kind) {
        EditorFileKind.html => '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Page</title>
</head>
<body>

</body>
</html>''',
        EditorFileKind.css => '''body {
    margin: 0;
}''',
        EditorFileKind.javascript => 'console.log("Hello World");',
        EditorFileKind.php => '''<?php

echo "Hello World";
''',
        EditorFileKind.json => '''{
  "name": "example"
}''',
        EditorFileKind.xml => '''<?xml version="1.0" encoding="UTF-8"?>
<root></root>''',
        EditorFileKind.markdown => '# New document\n',
        EditorFileKind.text => '',
      };

  static String defaultFileName(EditorFileKind kind) =>
      'untitled.${kind.defaultExtension}';
}
