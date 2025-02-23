import 'package:flutter/material.dart';

import 'bottom app bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2; // Set Profile as the active tab

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic (Modify based on your screen routes)
    if (index == 0) {
      Navigator.pop(context); // Go back to Home
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
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🟢 Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 12),

            // 🟢 User Information
            const Text(
              "Kiso",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Text(
              "kiso@gmail.com",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 🟢 Profile Menu Options
            _buildProfileOption(Icons.person_outline, "Profile", context),
            _buildProfileOption(Icons.health_and_safety_outlined, "Health info", context),
            _buildProfileOption(Icons.water_drop_outlined, "Target Glucose range", context),
            _buildProfileOption(Icons.privacy_tip_outlined, "Privacy Policy", context),
            _buildProfileOption(Icons.logout, "Log out", context, isLogout: true),
          ],
        ),
      ),

      // 🟢 Custom Bottom App Bar
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _selectedIndex,
      ),
    );
  }

  // 🔹 Helper Widget to Create Profile Options0
  Widget _buildProfileOption(IconData icon, String title, BuildContext context, {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        // TODO: Add navigation logic here if needed
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.red : Colors.black, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
