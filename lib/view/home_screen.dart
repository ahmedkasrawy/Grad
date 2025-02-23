import 'package:flutter/material.dart';
import 'package:grad/searchfood.dart';
import 'package:grad/view/profile.dart';
import 'bottom app bar.dart';
import 'glucose_stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> myLevels = [
    {"name": "Insulin Doses", "image": "assets/insulin.png"},
    {"name": "Carbs Intake", "image": "assets/carbs.png"},
    {"name": "Blood Pressure", "image": "assets/blood-pressure.png"},
    {"name": "Heart Rate", "image": "assets/heart-rate.png"},
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => FoodSearchPage()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟢 Header Section (Greeting, Centered Logo & Notification)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hello,",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black87),
                        ),
                        Text(
                          "Kiso 👋",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset('assets/glooko.png', width: 120), // Logo Centered
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, size: 28),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🟢 Glucose Summary Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: 0.5,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            strokeWidth: 10,
                          ),
                        ),
                        Column(
                          children: const [
                            Text("50.0", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text("118/78.0", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.circle, size: 10, color: Colors.green),
                        SizedBox(width: 5),
                        Text("Blood Sugar", style: TextStyle(fontSize: 14, color: Colors.black87)),
                        SizedBox(width: 15),
                        Icon(Icons.circle, size: 10, color: Colors.purple),
                        SizedBox(width: 5),
                        Text("Glycemic load", style: TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🟢 Restored Original Buttons Section (Insulin, Carbs, Blood Pressure, Heart Rate)
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: myLevels.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (myLevels[index]["name"] == "Carbs Intake") {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FoodSearchPage()));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(myLevels[index]["image"]!, width: 40, height: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              myLevels[index]["name"]!,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 🟢 Weekly Glucose Graph Section
              const Text("Week", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GlucoseStats(), // Graph component placeholder
            ],
          ),
        ),
      ),

      // 🟢 Reusable Custom Bottom App Bar
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _selectedIndex,
      ),
    );
  }
}
