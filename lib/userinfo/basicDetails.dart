import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grad/view/home_screen.dart';

class BasicDetails extends StatefulWidget {
  const BasicDetails({super.key});

  @override
  State<BasicDetails> createState() => _BasicDetailsState();
}

class _BasicDetailsState extends State<BasicDetails> {
  String? _selectedGender;
  String? _selectedDiabetesType;
  String? _selectedTherapy;
  String? _selectedMeasurementUnit;
  String? _selectedWeight;
  String? _selectedHeight;
  String? _selectedAge;
  String? _selectedGlucoseLevel;
  String? _selectedSugarGoal;
  String? _selectedBodyFat;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _diabetesTypes = ['Type 1', 'Type 2', 'Gestational', 'Prediabetes'];
  final List<String> _therapies = ['Insulin', 'Oral Medication', 'Lifestyle Changes'];
  final List<String> _measurementUnits = ['mg/dL', 'mmol/L'];
  final List<String> _weights = List.generate(121, (index) => '${30 + index} kg');
  final List<String> _heights = List.generate(101, (index) => '${140 + index} cm');
  final List<String> _ages = List.generate(91, (index) => '${10 + index} years');
  final List<String> _glucoseLevels = List.generate(251, (index) => '${50 + index} mg/dL');
  final List<String> _sugarGoals = List.generate(47, (index) => '${70 + (index * 5)} mg/dL');
  final List<String> _bodyFat = List.generate(46, (index) => '${5 + index}%');

  Future<void> _validateAndSubmit() async {
    if (_selectedGender == null ||
        _selectedWeight == null ||
        _selectedHeight == null ||
        _selectedAge == null ||
        _selectedDiabetesType == null ||
        _selectedTherapy == null ||
        _selectedMeasurementUnit == null ||
        _selectedSugarGoal == null ||
        _selectedGlucoseLevel == null ||
        _selectedBodyFat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all details', style: TextStyle(fontSize: 16)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // ✅ Save data with merge = true to preserve previous fields like username/email
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'gender': _selectedGender,
        'weight': _selectedWeight,
        'height': _selectedHeight,
        'age': _selectedAge,
        'diabetesType': _selectedDiabetesType,
        'therapy': _selectedTherapy,
        'measurementUnit': _selectedMeasurementUnit,
        'sugarGoal': _selectedSugarGoal,
        'glucoseLevel': _selectedGlucoseLevel,
        'bodyFat': _selectedBodyFat,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Details saved successfully!', style: TextStyle(fontSize: 16)),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving details: $e', style: const TextStyle(fontSize: 16)),
          backgroundColor: Colors.red,
        ),
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
          'Basic details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about yourself',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                'Your individual parameters are important for Dia for in-depth personalization.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _buildSelectionTile("Your gender", _selectedGender, _genders),
              _buildSelectionTile("Your weight", _selectedWeight, _weights),
              _buildSelectionTile("Your height", _selectedHeight, _heights),
              _buildSelectionTile("Your age", _selectedAge, _ages),
              _buildSelectionTile("Your diabetes type", _selectedDiabetesType, _diabetesTypes),
              _buildSelectionTile("Your therapy", _selectedTherapy, _therapies),
              _buildSelectionTile("Your measurement unit", _selectedMeasurementUnit, _measurementUnits),
              _buildSelectionTile("Your sugar goal", _selectedSugarGoal, _sugarGoals),
              _buildSelectionTile("Your glucose level", _selectedGlucoseLevel, _glucoseLevels),
              _buildSelectionTile("Your body fat percentage", _selectedBodyFat, _bodyFat),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Confirm", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile(String title, String? value, List<String> options) {
    return GestureDetector(
      onTap: () => _showSelectionDialog(title, options, (selected) {
        setState(() {
          switch (title) {
            case "Your gender":
              _selectedGender = selected;
              break;
            case "Your weight":
              _selectedWeight = selected;
              break;
            case "Your height":
              _selectedHeight = selected;
              break;
            case "Your age":
              _selectedAge = selected;
              break;
            case "Your diabetes type":
              _selectedDiabetesType = selected;
              break;
            case "Your therapy":
              _selectedTherapy = selected;
              break;
            case "Your measurement unit":
              _selectedMeasurementUnit = selected;
              break;
            case "Your sugar goal":
              _selectedSugarGoal = selected;
              break;
            case "Your glucose level":
              _selectedGlucoseLevel = selected;
              break;
            case "Your body fat percentage":
              _selectedBodyFat = selected;
              break;
          }
        });
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(value ?? "Select", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _showSelectionDialog(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(options[index]),
                      onTap: () {
                        onSelect(options[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
