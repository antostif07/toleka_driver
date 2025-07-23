import 'package:flutter/material.dart';
import 'package:toleka_driver/app/module/home/widgets/driver_stats.dart';

// Assuming you have these widgets in separate files:
import 'animated_finding_bar.dart'; // The widget we just created

class FindingRidesWidget extends StatelessWidget {
  const FindingRidesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        const Padding(
          padding: EdgeInsets.only(top: 24.0, bottom: 16.0),
          child: Text(
            'Recherche de courses en cours', // "Finding ride requests"
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Animated "Scanning" Bar
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: AnimatedFindingBar(),
        ),

        // Online Stats
        // We can reuse the previously created widget for this
        const DriverStats(),
      ],
    );
  }
}