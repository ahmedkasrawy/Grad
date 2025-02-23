import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grad/gmailVerify.dart';
import 'package:grad/userinfo/basicDetails.dart';
import 'package:grad/view/bluetooth_scan.dart';
import 'package:grad/view/home_screen.dart';
import 'package:grad/view/login_screen.dart';
import 'package:grad/view/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAAc7DdlSzGWMEN5Ys0vCVfO5o6wRNPR2I",
        appId: "1:428578952765:android:03ba1036d4dc9de450bc54",
        messagingSenderId: "428578952765",
        projectId: "glooko-f5a9c",
        storageBucket: "glooko-f5a9c.firebasestorage.app",
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Set SplashScreen as the initial screen
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the LoginScreen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/glookogif.gif',
          fit: BoxFit.fitHeight,
          height: double.infinity,//
          width: 700// Adjust the GIF to fill the screen
        ),
      ),
    );
  }
}
