import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();
  
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStream => _connectionStatusController.stream;
  bool _isOnline = true;
  
  bool get isOnline => _isOnline;
  
  Future<void> initialize() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
      
      _connectivity.onConnectivityChanged.listen((results) {
        if (results.isNotEmpty) {
          _updateConnectionStatus(results.first);
        }
      });
    } catch (e) {
      Logger.error('Error initializing NetworkService: $e');
      _isOnline = true; // Default to online
    }
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (wasOnline != _isOnline) {
      _connectionStatusController.add(_isOnline);
      if (kDebugMode) {
        Logger.info('Network status changed: ${_isOnline ? "Online" : "Offline"}');
      }
    }
  }
  
  void dispose() {
    _connectionStatusController.close();
  }
}
