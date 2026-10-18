import 'package:flutter/material.dart';

enum UnsavedChangesAction { discard, save, cancel }

/// Confirmation when leaving an editor with unsaved changes.
Future<UnsavedChangesAction?> showUnsavedChangesDialog(BuildContext context) {
  return showDialog<UnsavedChangesAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Unsaved changes'),
      content: const Text(
        'You have unsaved edits. Save before leaving?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, UnsavedChangesAction.discard),
          child: const Text('Discard'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, UnsavedChangesAction.cancel),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, UnsavedChangesAction.save),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
