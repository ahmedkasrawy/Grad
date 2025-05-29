// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class GlucosePredictor {
//   Interpreter? _interpreter;
//   bool _isModelLoaded = false;

//   // Normalization parameters fetched from Firestore
//   Map<String, double> _means = {};
//   Map<String, double> _stds = {};

//   Future<void> loadModel() async {
//     try {
//       print('Attempting to load TFLite model...');

//       if (_isModelLoaded && _interpreter != null) {
//         print('Model already loaded');
//         return;
//       }

//       _interpreter = await Interpreter.fromAsset('assets/model.tflite');

//       if (_interpreter == null) {
//         throw Exception('Failed to load model: interpreter is null');
//       }

//       print('Model loaded successfully');
//       print('Input tensor shape: ${_interpreter!.getInputTensor(0).shape}');
//       print('Output tensor shape: ${_interpreter!.getOutputTensor(0).shape}');

//       _isModelLoaded = true;
//     } catch (e, stackTrace) {
//       print('Error loading TFLite model: $e');
//       print('Stack trace: $stackTrace');
//       _isModelLoaded = false;
//       _interpreter = null;
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>> predict(double impedance) async {
//     if (!_isModelLoaded || _interpreter == null) {
//       throw Exception('Model not loaded. Call loadModel() first.');
//     }

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) throw Exception('User not logged in');

//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();

//       if (!doc.exists) throw Exception('User data not found');

//       final data = doc.data()!;
//       final weightStr = data['weight'] as String?;
//       final heightStr = data['height'] as String?;

//       if (weightStr == null || heightStr == null) {
//         throw Exception('User data is incomplete');
//       }

//       final weight = double.parse(weightStr.split(' ')[0]);
//       final height = double.parse(heightStr.split(' ')[0]);

//       print('Using weight from Firebase: $weight kg');
//       print('Using height from Firebase: $height cm');

//       // Fetch normalization parameters from Firestore
//       await _fetchNormalizationParams();

//       final normalizedImpedance = _normalize(impedance, 'impedance');
//       final normalizedWeight = _normalize(weight, 'weight');
//       final normalizedHeight = _normalize(height, 'height');

//       print('Normalized values:');
//       print('Impedance: $normalizedImpedance');
//       print('Weight: $normalizedWeight');
//       print('Height: $normalizedHeight');

//       var input = [[normalizedImpedance, normalizedWeight, normalizedHeight]];
//       var output = List.filled(1, 0.0).reshape([1, 1]);

//       _interpreter!.run(input, output);

//       final prediction = output[0][0];
//       print('Raw prediction: $prediction');

//       return {
//         'glucose': prediction,
//         'impedance': impedance,
//         'weight': weight,
//         'height': height,
//       };
//     } catch (e, stackTrace) {
//       print('Error making prediction: $e');
//       print('Stack trace: $stackTrace');
//       rethrow;
//     }
//   }

//   Future<void> _fetchNormalizationParams() async {
//     final doc = await FirebaseFirestore.instance
//         .collection('normalization')
//         .doc('glucose_model')
//         .get();

//     if (!doc.exists) throw Exception('Normalization data not found');

//     final data = doc.data()!;
//     _means = {
//       'impedance': data['impedance_mean'],
//       'weight': data['weight_mean'],
//       'height': data['height_mean'],
//     };

//     _stds = {
//       'impedance': data['impedance_std'],
//       'weight': data['weight_std'],
//       'height': data['height_std'],
//     };

//     print('Fetched normalization parameters from Firestore:');
//     print('Means: $_means');
//     print('Stds: $_stds');
//   }

//   double _normalize(double value, String feature) {
//     return (value - _means[feature]!) / _stds[feature]!;
//   }

//   void dispose() {
//     _interpreter?.close();
//     _interpreter = null;
//     _isModelLoaded = false;
//   }
// }
