import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity connectivity;

  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    return _isConnected(connectivityResult);
  }

  bool _isConnected(ConnectivityResult result) {
    return 
           result == ConnectivityResult.wifi ||
           result == ConnectivityResult.mobile ||
           result == ConnectivityResult.ethernet ||
           result == ConnectivityResult.vpn;
  }

  Stream<ConnectivityResult> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }
}