import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();

  // Observes network availability without assuming the API is reachable.
  Stream<bool> get changes => _connectivity.onConnectivityChanged
      .map(
        (results) => results.any((result) => result != ConnectivityResult.none),
      )
      .distinct();

  // Checks whether the device currently has a network interface available.
  Future<bool> isAvailable() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
