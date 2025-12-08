import 'package:flutter/material.dart';
import 'dart:async';
import '../repositories/network_repository.dart';

/// Small indicator untuk menampilkan status koneksi di AppBar
class NetworkStatusIndicator extends StatefulWidget {
  const NetworkStatusIndicator({Key? key}) : super(key: key);

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
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
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 4),
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