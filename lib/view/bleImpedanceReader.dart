import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEImpedanceReader extends StatefulWidget {
  final String deviceName;
  final String serviceUuid;
  final String characteristicUuid;
  final BluetoothDevice? connectedDevice;

  const BLEImpedanceReader({
    Key? key,
    this.deviceName = 'ESP32_BLE_AD5933',
    required this.serviceUuid,
    required this.characteristicUuid,
    this.connectedDevice,
  }) : super(key: key);

  @override
  State<BLEImpedanceReader> createState() => _BLEImpedanceReaderState();
}

class _BLEImpedanceReaderState extends State<BLEImpedanceReader> {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;
  String sensorValue = 'Waiting for data...';
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _isConnecting = false;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 3;
  StreamSubscription? _valueSubscription;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    print("BLEImpedanceReader initialized");
    print("Service UUID: ${widget.serviceUuid}");
    print("Characteristic UUID: ${widget.characteristicUuid}");

    if (widget.connectedDevice != null) {
      print("Received connected device, skipping scan.");
      connectedDevice = widget.connectedDevice;
      _initBluetooth(skipScan: true);
    } else {
      print("No connected device provided, starting scan.");
      _initBluetooth();
    }
  }

  Future<void> _initBluetooth({bool skipScan = false}) async {
    // Immediate check for setup if skipping scan and adapter is already on
    var currentState = await FlutterBluePlus.adapterState.first;
    if (skipScan && currentState == BluetoothAdapterState.on && connectedDevice != null) {
      print("Bluetooth adapter already on, proceeding to setup device.");
      setState(() {
        _adapterState = currentState; // Update state immediately
      });
      _setupDevice();
    }

    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
      if (state == BluetoothAdapterState.on) {
        if (!skipScan) {
           print("Adapter turned on, starting scan.");
           _startScan(); // Only start scan if not skipping
        } else {
           print("Adapter turned on, but skipping scan.");
           // If skipping scan and adapter just turned on, but device wasn't set up
           // in the immediate check (e.g., connectedDevice was null initially) handle it here.
           // However, given our flow, connectedDevice should be available if skipScan is true.
           // We rely on the immediate check or the connectToDevice success path.
        }
      } else {
        setState(() {
          sensorValue = "Bluetooth is off. Please enable it.";
        });
      }
    });
  }

  Future<void> _startScan() async {
    if (_scanSubscription != null) {
      await _scanSubscription?.cancel();
    }
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (result.device.name == widget.deviceName) {
          _connectToDevice(result.device);
          break;
        }
      }
    });

    try {
      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      setState(() {
        sensorValue = "Scanning for device...";
      });
    } catch (e) {
      print("Scan error: $e");
      setState(() {
        sensorValue = "Scan error";
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      print("Connecting to device: ${device.name} (${device.id})");
      
      if (await device.isConnected) {
        print("Device is already connected");
        connectedDevice = device;
        setState(() {
          _connectionState = BluetoothConnectionState.connected;
          sensorValue = "Connected to ${device.name}";
        });
        await _setupDevice();
        return;
      }

      await device.connect(
        timeout: const Duration(seconds: 60),
      );
      
      print("Successfully connected to device");
      connectedDevice = device;
      setState(() {
        _connectionState = BluetoothConnectionState.connected;
        sensorValue = "Connected to ${device.name}";
      });

      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        print("Connection state changed: $state");
        setState(() {
          _connectionState = state;
        });
        
        if (state == BluetoothConnectionState.disconnected) {
          print("Device disconnected, attempting to reconnect...");
          _handleDisconnection();
        }
      });

      await _setupDevice();

    } catch (e) {
      print("Error connecting to device: $e");
      setState(() {
        sensorValue = "Error connecting to device: ${e.toString()}";
        _connectionState = BluetoothConnectionState.disconnected;
      });
      try {
        await device.disconnect();
      } catch (e) {
        print("Error disconnecting device: $e");
      }
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _setupDevice() async {
    if (connectedDevice == null) return;

    try {
      print("Discovering services...");
      setState(() {
        sensorValue = "Discovering services...";
      });
      List<BluetoothService> services = await connectedDevice!.discoverServices().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("Service discovery timeout");
          throw TimeoutException('Service discovery timeout');
        },
      );
      
      print("Found ${services.length} services");
      
      Guid serviceGuid = Guid(widget.serviceUuid);
      Guid characteristicGuid = Guid(widget.characteristicUuid);
      
      for (var service in services) {
        print("Checking service: ${service.uuid}");
        if (service.uuid == serviceGuid) {
          print("Found target service");
          for (var characteristic in service.characteristics) {
            print("Checking characteristic: ${characteristic.uuid}");
            if (characteristic.uuid == characteristicGuid) {
              print("Found target characteristic");
              targetCharacteristic = characteristic;
              await _setupNotifications();
              return;
            }
          }
        }
      }

      print("Target service or characteristic not found");
      setState(() {
        sensorValue = "Service or characteristic not found";
      });

    } catch (e) {
      print("Error setting up device: $e");
      setState(() {
        sensorValue = "Error setting up device: ${e.toString()}";
      });
    }
  }

  Future<void> _setupNotifications() async {
    try {
      if (targetCharacteristic == null) return;

      print("Enabling notifications...");
      await targetCharacteristic!.setNotifyValue(true).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("Notification setup timeout");
          throw TimeoutException('Notification setup timeout');
        },
      );

      print("Notifications enabled");

      _valueSubscription?.cancel();
      _valueSubscription = targetCharacteristic!.value.listen((value) {
        print("Received raw bytes: $value");
        if (value.isNotEmpty) {
          try {
            String receivedData = String.fromCharCodes(value).trim();
            print("Converted data: $receivedData");

            // Extract number after "Impedance: "
            final match = RegExp(r'Impedance:\s*([\d.]+)').firstMatch(receivedData);
            if (match != null) {
              double reading = double.parse(match.group(1)!);
              print("Parsed reading: $reading");

              setState(() {
                sensorValue = "${reading.toStringAsFixed(2)} Ω"; // Display with standard Ohm symbol
              });
            } else {
              print("Regex match failed for data");
              setState(() {
                sensorValue = "Error: Unexpected data format";
              });
            }
          } catch (e) {
            print("Error parsing data: $e");
            setState(() {
              sensorValue = "Error: Invalid data format";
            });
          }
        }
      });
    } catch (e) {
      print("Error setting up notifications: $e");
      setState(() {
        sensorValue = "Error setting up notifications";
      });
    }
  }

  Future<void> _handleDisconnection() async {
    if (_isReconnecting) return;

    _isReconnecting = true;
    _reconnectAttempts = 0;

    while (_reconnectAttempts < maxReconnectAttempts && connectedDevice != null) {
      try {
        print("Reconnection attempt ${_reconnectAttempts + 1} of $maxReconnectAttempts");
        await Future.delayed(const Duration(seconds: 2));

        if (connectedDevice != null) {
          await _connectToDevice(connectedDevice!);
          if (_connectionState == BluetoothConnectionState.connected) {
            print("Successfully reconnected");
            _isReconnecting = false;
            return;
          }
        }

        _reconnectAttempts++;
      } catch (e) {
        print("Reconnection attempt failed: $e");
        _reconnectAttempts++;
      }
    }

    _isReconnecting = false;
    setState(() {
      sensorValue = "Connection lost. Please try reconnecting manually.";
      _connectionState = BluetoothConnectionState.disconnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Impedance Reader', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (connectedDevice != null) {
                _connectToDevice(connectedDevice!);
              } else {
                _startScan();
              }
            },
            tooltip: 'Reconnect',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Bluetooth & Connection Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusCard(title: "Bluetooth", value: _adapterState.name, isActive: _adapterState == BluetoothAdapterState.on),
                _statusCard(title: "Connection", value: _connectionState.name, isActive: _connectionState == BluetoothConnectionState.connected),
              ],
            ),
            const SizedBox(height: 30),

            // Impedance Value Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Impedance Reading",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sensorValue,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard({required String title, required String value, required bool isActive}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? Colors.green.shade200 : Colors.red.shade200),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("Disposing BLEImpedanceReader");
    _valueSubscription?.cancel();
    _scanSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    if (connectedDevice != null) {
      connectedDevice!.disconnect();
    }
    super.dispose();
  }
}
