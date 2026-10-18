/// Simple undo/redo for a single text buffer.
class EditorUndoStack {
  final List<String> _past = [];
  String _present = '';
  final List<String> _future = [];
  bool _grouping = false;

  String get present => _present;

  void reset(String initial) {
    _past.clear();
    _future.clear();
    _present = initial;
    _grouping = false;
  }

  void record(String next, {bool forceCheckpoint = false}) {
    if (next == _present) return;
    if (!forceCheckpoint && _grouping) {
      _present = next;
      return;
    }
    _past.add(_present);
    if (_past.length > 80) _past.removeAt(0);
    _present = next;
    _future.clear();
    _grouping = true;
  }

  void endGroup() => _grouping = false;

  String? undo() {
    if (_past.isEmpty) return null;
    _future.add(_present);
    _present = _past.removeLast();
    _grouping = false;
    return _present;
  }

  String? redo() {
    if (_future.isEmpty) return null;
    _past.add(_present);
    _present = _future.removeLast();
    _grouping = false;
    return _present;
  }

  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;
}
