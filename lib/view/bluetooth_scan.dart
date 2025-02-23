import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grad/controller/bluetooth_connection.dart';
import 'bluetooth_connection.dart';

class BluetoothScreen extends StatelessWidget {
  final BluetoothConnection bluetoothController = Get.put(BluetoothConnection());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Devices"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: bluetoothController.startScan,
            child: const Text("Scan for Devices"),
          ),
          ElevatedButton(
            onPressed: bluetoothController.stopScan,
            child: const Text("Stop Scanning"),
          ),
          Expanded(
            child: Obx(() {
              if (bluetoothController.scannedDevices.isEmpty) {
                return const Center(
                  child: Text(
                    "No devices found. Please scan again.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: bluetoothController.scannedDevices.length,
                itemBuilder: (context, index) {
                  final device = bluetoothController.scannedDevices[index];
                  return ListTile(
                    title: Text(
                      device.device.name.isNotEmpty
                          ? device.device.name
                          : "Unnamed Device",
                    ),
                    subtitle: Text(device.device.id.toString()),
                    trailing: ElevatedButton(
                      onPressed: () {
                        bluetoothController.connectToDevice(device.device);
                      },
                      child: const Text("Connect"),
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
