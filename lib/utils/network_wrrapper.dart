// ============================================================
// FILE 3: lib/utils/network_wrapper.dart
// ⭐ FILE INI YANG PALING PENTING - IMPORT INI SAJA! ⭐
// ============================================================

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../repositories/network_repository.dart';

/// 🌐 NetworkWrapper - Wrap any page with this for auto network checking
/// 
/// CARA PAKAI:
/// ```dart
/// import '../utils/network_wrapper.dart';
/// 
/// return NetworkWrapper(
///   child: YourExistingPageWidget(),
/// );
/// ```
class NetworkWrapper extends StatefulWidget {
  final Widget child;
  
  /// Tampilkan snackbar saat koneksi berubah
  final bool showSnackbar;
  
  /// Tampilkan overlay saat tidak ada koneksi
  final bool showOverlay;
  
  /// Tampilkan loading saat cek koneksi pertama kali
  final bool showInitialLoading;

  const NetworkWrapper({
    Key? key,
    required this.child,
    this.showSnackbar = true,
    this.showOverlay = true,
    this.showInitialLoading = false,
  }) : super(key: key);

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  final NetworkRepository _repository = NetworkRepository();
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isConnected = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _startMonitoring();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final isConnected = await _repository.isConnected();
    
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        _isChecking = false;
      });

      if (!isConnected && widget.showSnackbar) {
        _showNoConnectionSnackbar();
      }
    }
  }

  void _startMonitoring() {
    _subscription = _repository.monitorConnection().listen((result) async {
      await Future.delayed(const Duration(seconds: 1));
      
      final isConnected = await _repository.isConnected();
      
      if (mounted && _isConnected != isConnected) {
        setState(() => _isConnected = isConnected);

        if (widget.showSnackbar) {
          if (isConnected) {
            _showConnectedSnackbar();
          } else {
            _showNoConnectionSnackbar();
          }
        }
      }
    });
  }

  void _showNoConnectionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No internet connection',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _initConnectivity,
        ),
      ),
    );
  }

  void _showConnectedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Connected to internet',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading saat cek koneksi pertama (optional)
    if (_isChecking && widget.showInitialLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                'Checking connection...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Widget utama (halaman Anda)
        widget.child,
        
        // Overlay saat tidak ada koneksi
        if (!_isConnected && widget.showOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Internet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F36),
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please check your internet connection\nand try again',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _initConnectivity,
                          icon: const Icon(Icons.refresh_rounded, size: 22),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.3,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 📶 OfflineIndicator - Small badge untuk AppBar
/// 
/// CARA PAKAI:
/// ```dart
/// import '../utils/network_wrapper.dart';
/// 
/// AppBar(
///   title: Text('My Page'),
///   actions: [
///     OfflineIndicator(),
///   ],
/// )
/// ```
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({Key? key}) : super(key: key);

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final NetworkRepository _repository = NetworkRepository();
  bool _isConnected = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    final isConnected = await _repository.isConnected();
    if (mounted && _isConnected != isConnected) {
      setState(() => _isConnected = isConnected);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}