import 'package:flutter/material.dart';
import 'package:grad/searchfood.dart'; // Import your FoodSearchPage
import 'package:grad/view/bluetooth_scan.dart';
import 'package:grad/view/profile.dart';

import 'home_screen.dart'; // Import your ProfileScreen

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomAppBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: currentIndex == 0 ? Colors.blue : Colors.grey),
            onPressed: () {
              if (currentIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.restaurant, color: currentIndex == 1 ? Colors.blue : Colors.grey),
            onPressed: () {
              if (currentIndex != 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodSearchPage()),
                );
              }
            },
          ),
          // Floating Action Button for Bluetooth
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BluetoothScreen()),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.person, color: currentIndex == 2 ? Colors.blue : Colors.grey),
            onPressed: () {
              if (currentIndex != 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
