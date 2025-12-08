import '../services/network_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Repository untuk mengelola logika koneksi internet
class NetworkRepository {
  final NetworkService _service = NetworkService();

  /// Cek apakah ada koneksi internet
  Future<Map<String, dynamic>> checkConnection() async {
    final hasConnection = await _service.hasConnection();
    final connectionType = await _service.getConnectionType();

    return {
      'hasConnection': hasConnection,
      'connectionType': _getConnectionTypeName(connectionType),
      'timestamp': DateTime.now(),
    };
  }

  /// Stream untuk monitoring koneksi real-time
  Stream<ConnectivityResult> monitorConnection() {
    return _service.onConnectivityChanged;
  }

  /// Convert ConnectivityResult ke string yang mudah dibaca
  String _getConnectionTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  /// Cek koneksi dan return boolean
  Future<bool> isConnected() async {
    return await _service.hasConnection();
  }
}
