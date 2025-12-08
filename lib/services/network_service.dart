import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service untuk memeriksa koneksi internet
class NetworkService {
  final Connectivity _connectivity = Connectivity();
  
  /// Stream untuk mendengarkan perubahan koneksi
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Cek status koneksi saat ini
  Future<bool> hasConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      // Jika tidak ada koneksi WiFi atau Mobile data
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Double check dengan ping ke Google DNS
      return await _checkInternetAccess();
    } catch (e) {
      print('Error checking connection: $e');
      return false;
    }
  }

  /// Ping ke server untuk memastikan ada akses internet
  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      print('Error checking internet access: $e');
      return false;
    }
  }

  /// Cek tipe koneksi (WiFi, Mobile, None)
  Future<ConnectivityResult> getConnectionType() async {
    return await _connectivity.checkConnectivity();
  }
}