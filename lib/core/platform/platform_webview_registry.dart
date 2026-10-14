/// Widgets with Android platform views register a hard release hook so the
/// quiz launcher can tear down native surfaces before pushing the quiz route.
class PlatformWebViewRegistry {
  PlatformWebViewRegistry._();
  static final PlatformWebViewRegistry instance = PlatformWebViewRegistry._();

  final Set<Future<void> Function()> _releaseHooks = {};

  void register(Future<void> Function() release) {
    _releaseHooks.add(release);
  }

  void unregister(Future<void> Function() release) {
    _releaseHooks.remove(release);
  }

  Future<void> releaseAll() async {
    final hooks = _releaseHooks.toList(growable: false);
    for (final hook in hooks) {
      await hook();
    }
  }
}
