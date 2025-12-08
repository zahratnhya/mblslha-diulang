import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../repositories/network_repository.dart';

/// Widget wrapper untuk memeriksa koneksi internet
/// Wrap widget apapun dengan NetworkCheckerWidget untuk auto-detect koneksi
class NetworkCheckerWidget extends StatefulWidget {
  final Widget child;
  final bool showSnackbar;
  final bool showOverlay;

  const NetworkCheckerWidget({
    Key? key,
    required this.child,
    this.showSnackbar = true,
    this.showOverlay = true,
  }) : super(key: key);

  @override
  State<NetworkCheckerWidget> createState() => _NetworkCheckerWidgetState();
}

class _NetworkCheckerWidgetState extends State<NetworkCheckerWidget> {
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

  /// Initial connectivity check
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

  /// Monitor perubahan koneksi
  void _startMonitoring() {
    _subscription = _repository.monitorConnection().listen((result) async {
      // Delay untuk memastikan koneksi benar-benar stabil
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

  /// Show snackbar ketika tidak ada koneksi
  void _showNoConnectionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white),
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

  /// Show snackbar ketika koneksi kembali
  void _showConnectedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_rounded, color: Colors.white),
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
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      children: [
        widget.child,
        
        // Overlay ketika tidak ada koneksi
        if (!_isConnected && widget.showOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: 60,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F36),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please check your internet connection\nand try again',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _initConnectivity,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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

