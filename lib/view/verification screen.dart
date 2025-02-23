import 'dart:async';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isResendEnabled = false;
  int countdown = 30;
  Timer? countdownTimer;

  void verifyOTP() {
    String otp = otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    // Add OTP verification logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP Verified Successfully')),
    );

    // Navigate to the next screen
  }

  void startCountdown() {
    setState(() {
      isResendEnabled = false;
      countdown = 30;
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          isResendEnabled = true;
        });
      }
    });
  }

  void resendOTP() {
    // Logic to resend OTP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP has been resent')),
    );

    startCountdown();
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
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
          "Verify Your Email",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Enter the 6-digit verification code sent to your email.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // OTP Input Field
            TextField(
              controller: otpController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                counterText: "",
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resend Code Button with Countdown
            TextButton(
              onPressed: isResendEnabled ? resendOTP : null,
              child: Text(
                isResendEnabled ? "Resend Code" : "Resend Code in $countdown s",
                style: const TextStyle(fontSize: 16, color: Colors.red, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
