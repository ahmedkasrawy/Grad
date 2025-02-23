import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class BluetoothConnection extends GetxController {
  final flutterBlue = FlutterBluePlus();

  // Observable list to store scanned devices
  final scannedDevices = <ScanResult>[].obs;

  // Subscription for scan results
  StreamSubscription<List<ScanResult>>? scanSubscription;

  // Method to start scanning for devices
  Future<void> startScan() async {
    if (!PlatformUtils.isMobile) {
      print("Bluetooth scanning is not supported on this platform.");
      return;
    }

    try {
      // Clear previously scanned devices
      scannedDevices.clear();

      // Start scanning for devices
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 60));

      // Listen to scan results and update the list
      scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          // Add only unique devices
          if (!scannedDevices.any((device) => device.device.id == result.device.id)) {
            scannedDevices.add(result);
          }
        }
      });
    } catch (e) {
      print("Error during scanning: $e");
    } finally {
      // Ensure scanning stops after timeout
      await FlutterBluePlus.stopScan();
    }
  }

  // Method to stop scanning manually
  Future<void> stopScan() async {
    if (!PlatformUtils.isMobile) {
      print("Bluetooth scanning is not supported on this platform.");
      return;
    }

    try {
      // Cancel the subscription if it's active
      await scanSubscription?.cancel();

      // Stop scanning
      await FlutterBluePlus.stopScan();
      print("Scanning stopped");
    } catch (e) {
      print("Error stopping scan: $e");
    }
  }

  // Method to connect to a selected device
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (!PlatformUtils.isMobile) {
      print("Bluetooth connections are not supported on this platform.");
      return;
    }

    try {
      await device.connect();
      print("Connected to ${device.name}");
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  // Method to disconnect from a device
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    if (!PlatformUtils.isMobile) {
      print("Bluetooth disconnections are not supported on this platform.");
      return;
    }

    try {
      await device.disconnect();
      print("Disconnected from ${device.name}");
    } catch (e) {
      print("Error disconnecting from device: $e");
    }
  }

  // Clean up when the controller is disposed
  @override
  void onClose() {
    // Cancel the scan subscription when the controller is disposed
    scanSubscription?.cancel();
    super.onClose();
  }
}

class PlatformUtils {
  static bool get isMobile {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isIOS || Platform.isAndroid;
    }
  }

  static bool get isDesktop {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isLinux || Platform.isFuchsia || Platform.isWindows || Platform.isMacOS;
    }
  }

  static bool get isWeb {
    return kIsWeb;
  }
}
