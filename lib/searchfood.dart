import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grad/view/home_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(NutritionApp());
}

class NutritionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutrition Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FoodSearchPage(),
    );
  }
}

class FoodSearchPage extends StatefulWidget {
  @override
  _FoodSearchPageState createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _foodList = [];
  bool _isLoading = false;

  Future<void> _searchFood(String query) async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = '1IRsiQBaaRU6HvPhVzkdsA==YTmFiZSIX3Bb4NHg';
    final url = Uri.parse('https://api.api-ninjas.com/v1/nutrition?query=$query');

    try {
      final response = await http.get(url, headers: {'X-Api-Key': apiKey});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _foodList = data;
        });
      } else {
        _showError('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNutritionDetails(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(food['name'] ?? 'Food Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Calories: ${food['calories']}'),
            Text('Serving Size: ${food['serving_size_g']} g'),
            Text('Total Fat: ${food['fat_total_g']} g'),
            Text('Saturated Fat: ${food['fat_saturated_g']} g'),
            Text('Protein: ${food['protein_g']} g'),
            Text('Sodium: ${food['sodium_mg']} mg'),
            Text('Potassium: ${food['potassium_mg']} mg'),
            Text('Cholesterol: ${food['cholesterol_mg']} mg'),
            Text('Carbohydrates: ${food['carbohydrates_total_g']} g'),
            Text('Fiber: ${food['fiber_g']} g'),
            Text('Sugar: ${food['sugar_g']} g'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );                      },
                    ),
                    Expanded(
                      child: Text(
                        'Search Nutrition Info',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16.0),
                      labelText: 'Enter food name',
                      labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: Colors.blue.shade700),
                        onPressed: () => _searchFood(_controller.text),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                _isLoading
                    ? Center(
                  child: CircularProgressIndicator(color: Colors.blue.shade700),
                )
                    : _foodList.isEmpty
                    ? Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _foodList.length,
                  itemBuilder: (context, index) {
                    final food = _foodList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(12.0),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _showNutritionDetails(food),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.fastfood,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Text(
                                    food['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
