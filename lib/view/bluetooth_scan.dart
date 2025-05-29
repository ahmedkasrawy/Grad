import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grad/controller/bluetooth_connection.dart'; // your BluetoothConnection controller import

class BluetoothScreen extends StatelessWidget {
  final BluetoothConnection bluetoothController = Get.put(BluetoothConnection());

  // Replace these with your actual BLE UUIDs
  final String serviceUuid = "12345678-1234-1234-1234-1234567890AB";
  final String characteristicUuid = "ABCD1234-5678-1234-5678-1234567890AB";

  BluetoothScreen({super.key});

  void _connectDevice(BuildContext context, device) async {
    try {
      await bluetoothController.connectToDevice(
        device,
        serviceUuid: serviceUuid,
        characteristicUuid: characteristicUuid,
      );
      Get.snackbar(
        "Connection",
        "Connected to ${device.name.isNotEmpty ? device.name : 'Unnamed Device'}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade200,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        "Connection Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade200,
        colorText: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Connect Device",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset('assets/glooko.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  "Connect your glucose meter",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Make sure your device is turned on and in pairing mode",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Scan Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() {
              return ElevatedButton(
                onPressed: bluetoothController.isScanning.value
                    ? bluetoothController.stopScan
                    : bluetoothController.startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (bluetoothController.isScanning.value)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      const Icon(Icons.bluetooth_searching),
                    const SizedBox(width: 10),
                    Text(
                      bluetoothController.isScanning.value ? "Scanning..." : "Start Scanning",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Device List
          Expanded(
            child: Obx(() {
              if (bluetoothController.scannedDevices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bluetooth_disabled,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bluetoothController.isScanning.value
                            ? "Searching for devices..."
                            : "No devices found",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!bluetoothController.isScanning.value)
                        TextButton(
                          onPressed: bluetoothController.startScan,
                          child: const Text("Try Again"),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: bluetoothController.scannedDevices.length,
                itemBuilder: (context, index) {
                  final device = bluetoothController.scannedDevices[index];
                  final deviceName = device.device.name.isNotEmpty ? device.device.name : "Unnamed Device";

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: const Icon(Icons.bluetooth, color: Colors.blue),
                      title: Text(
                        deviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        device.device.id.toString(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _connectDevice(context, device.device),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Connect"),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
