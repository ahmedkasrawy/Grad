import 'package:flutter/material.dart';
import 'bar_graph.dart'; // Ensure this import points to the correct file

class GlucoseStats extends StatefulWidget {
  @override
  State<GlucoseStats> createState() => _GlucoseStatsState();
}

class _GlucoseStatsState extends State<GlucoseStats> {
  List<double> weeklySummary = [95, 110, 120, 105, 130, 100, 115];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Subtitle
          Text(
            'Weekly Glucose Levels',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Last 7 days',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16.0),

          // Bar Graph
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 175, // Fixed height for the graph
                width: constraints.maxWidth, // Use available width
                child: MyBarGraph(weeklySummary: weeklySummary),
              );
            },
          ),
        ],
      ),
    );
  }
}