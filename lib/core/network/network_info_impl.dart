import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(
        (results) => results.any((result) => result != ConnectivityResult.none),
      );
}
