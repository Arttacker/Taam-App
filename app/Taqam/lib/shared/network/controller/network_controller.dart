import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taqam/shared/style/color.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  var _isConnected = true.obs; // Observable to track internet connection status

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnection();
  }

  void _checkInitialConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    bool isConnected = connectivityResult != ConnectivityResult.none;
    if (isConnected != _isConnected.value) {
      _isConnected.value = isConnected;
      _showConnectionMessage(isConnected);
    }
  }

  void _showConnectionMessage(bool isConnected) {
    Get.rawSnackbar(
      messageText: Text(
        isConnected ? 'Internet has been restored' : 'No internet connection',
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      isDismissible: false,
      duration: isConnected ? Duration(seconds: 5) : Duration(seconds: 10),
      backgroundColor: isConnected ? ColorsManager.mainColor : ColorsManager.mainBackgroundColor2,
      icon: Icon(
        isConnected ? Icons.wifi_outlined : Icons.wifi_off,
        color: Colors.black38,
        size: 25,
      ),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.FLOATING,
      borderRadius: 15,
      padding: EdgeInsets.all(15.0),
    );
  }
}