/// Connectivity abstraction.
///
/// Used by the network layer to short-circuit requests when the device is
/// offline and by the refresh interceptor before attempting a token refresh.
abstract class NetworkInfo {
  Future<bool> get isConnected;

  /// Emits `true`/`false` as connectivity changes.
  Stream<bool> get onConnectivityChanged;
}
