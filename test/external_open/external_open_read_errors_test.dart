import 'package:devpath/features/external_open/services/android_open_file_bridge.dart';
import 'package:devpath/features/external_open/services/external_open_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Documents expected user-facing read error mapping (physical QA reference).
void main() {
  test('read error codes map to stable messages', () {
    final coordinator = ExternalOpenCoordinator.instance;
    expect(
      coordinator.messageForReadError('empty'),
      'The file is empty.',
    );
    expect(
      coordinator.messageForReadError('permission_denied'),
      contains('Permission'),
    );
    expect(
      coordinator.messageForReadError('too_large'),
      contains('1 MB'),
    );
  });

  test('ExternalOpenTooLargeException is distinct type', () {
    expect(ExternalOpenTooLargeException(2).bytes, 2);
  });
}
