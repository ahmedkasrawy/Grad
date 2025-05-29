import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:grad/view/bleImpedanceReader.dart';

class BluetoothConnection extends GetxController {
  final flutterBlue = FlutterBluePlus();

  final scannedDevices = <ScanResult>[].obs;
  final isScanning = false.obs;

  StreamSubscription<List<ScanResult>>? scanSubscription;

  Future<bool> _checkAndRequestPermissions() async {
    if (!PlatformUtils.isMobile) return false;

    var locationStatus = await Permission.location.request();
    if (!locationStatus.isGranted) {
      print("Location permission not granted");
      return false;
    }

    if (Platform.isAndroid) {
      var bluetoothScanStatus = await Permission.bluetoothScan.request();
      var bluetoothConnectStatus = await Permission.bluetoothConnect.request();

      if (!bluetoothScanStatus.isGranted || !bluetoothConnectStatus.isGranted) {
        print("Bluetooth permissions not granted");
        return false;
      }
    }

    return true;
  }

  Future<void> startScan() async {
    if (!PlatformUtils.isMobile) {
      print("Bluetooth scanning is not supported on this platform.");
      return;
    }

    try {
      bool hasPermissions = await _checkAndRequestPermissions();
      if (!hasPermissions) {
        print("Required permissions not granted");
        return;
      }

      var adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print("Bluetooth is not turned on");
        return;
      }

      isScanning.value = true;
      scannedDevices.clear();

      await FlutterBluePlus.stopScan();
      await scanSubscription?.cancel();

      scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          if (!scannedDevices.any((d) => d.device.id == result.device.id)) {
            scannedDevices.add(result);
          }
        }
      }, onError: (error) {
        print("Error in scan results: $error");
        stopScan();
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 120),
        androidUsesFineLocation: true,
      );

      print("Started scanning...");
    } catch (e) {
      print("Error during scanning: $e");
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> stopScan() async {
    if (!PlatformUtils.isMobile) {
      print("Bluetooth scanning is not supported on this platform.");
      return;
    }

    try {
      isScanning.value = false;
      await scanSubscription?.cancel();
      scanSubscription = null;
      await FlutterBluePlus.stopScan();
      print("Scanning stopped");
    } catch (e) {
      print("Error stopping scan: $e");
    }
  }

  bool _isConnecting = false;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;

  Future<void> connectToDevice(BluetoothDevice device, {
    required String serviceUuid,
    required String characteristicUuid,
  }) async {
    if (!PlatformUtils.isMobile) {
      print("Bluetooth connections are not supported on this platform.");
      return;
    }

    if (_isConnecting) {
      print("Already connecting to a device...");
      return;
    }

    _isConnecting = true;

    try {
      print("Checking permissions...");
      bool hasPermissions = await _checkAndRequestPermissions();
      if (!hasPermissions) {
        print("Permission check failed");
        return;
      }

      var adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print("Bluetooth is not turned on");
        return;
      }

      print("Connecting to device ${device.name} (${device.id})...");
      // Remove autoConnect and use default MTU
      await device.connect(
        timeout: const Duration(seconds: 60),
      );

      // Check connection state
      bool isConnected = await device.isConnected;
      print("Device connected: $isConnected");
      if (!isConnected) throw Exception("Device disconnected immediately after connect.");

      connectedDevice = device;

      // Listen for connection state changes
      await _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        print("Connection state changed: $state");
        if (state == BluetoothConnectionState.disconnected) {
          print("Device disconnected");
          _handleDisconnection();
        }
      });

      // Wait a short time before service discovery
      await Future.delayed(const Duration(seconds: 1));

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      print("Discovered ${services.length} services");

      Guid serviceGuid = Guid(serviceUuid);
      Guid characteristicGuid = Guid(characteristicUuid);

      BluetoothCharacteristic? characteristic;

      for (var service in services) {
        if (service.uuid == serviceGuid) {
          print("Found target service: ${service.uuid}");
          for (var c in service.characteristics) {
            if (c.uuid == characteristicGuid) {
              characteristic = c;
              print("Found target characteristic: ${c.uuid}");
              break;
            }
          }
          if (characteristic != null) break;
        }
      }

      if (characteristic == null) {
        throw Exception("Target characteristic not found");
      }

      targetCharacteristic = characteristic;

      // Enable notifications
      await characteristic.setNotifyValue(true);

      print("Notifications enabled");

      // Listen for incoming data
      // characteristic.value.listen((value) {
      //   print("Received data: $value");
      //   // Handle your incoming BLE data here
      // });

      print("Device setup complete");
      
      // Navigate to BLEImpedanceReader after successful connection
      print("Navigating to BLEImpedanceReader");
      Get.off(() => BLEImpedanceReader(
        serviceUuid: serviceUuid,
        characteristicUuid: characteristicUuid,
        connectedDevice: device,
      ));

    } catch (e) {
      print("Error connecting or setting up device: $e");
      try {
        await device.disconnect();
      } catch (_) {}
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _handleDisconnection() async {
    print("Attempting to reconnect...");
    if (connectedDevice == null) return;

    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        print("Reconnect attempt $attempts");
        await Future.delayed(const Duration(seconds: 2));
        await connectedDevice!.connect(autoConnect: true);
        bool isConnected = await connectedDevice!.isConnected;
        if (isConnected) {
          print("Reconnected successfully");
          return;
        }
      } catch (e) {
        print("Reconnect attempt failed: $e");
      }
    }
    print("Failed to reconnect after $maxAttempts attempts");
  }

  Future<void> disconnectFromDevice() async {
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
        print("Disconnected from device");
        connectedDevice = null;
      } catch (e) {
        print("Error disconnecting: $e");
      }
    }
  }

  @override
  void onClose() {
    scanSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    super.onClose();
  }
}

class PlatformUtils {
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isLinux || Platform.isMacOS || Platform.isWindows || Platform.isFuchsia;
  }

  static bool get isWeb => kIsWeb;
}
