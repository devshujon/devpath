import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/tmp/devpath_test_docs';
}

void installFakePathProvider() {
  PathProviderPlatform.instance = FakePathProviderPlatform();
}
