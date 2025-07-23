import 'package:flutter/material.dart';

class AnimatedFindingBar extends StatefulWidget {
  const AnimatedFindingBar({super.key});

  @override
  State<AnimatedFindingBar> createState() => _AnimatedFindingBarState();
}

class _AnimatedFindingBarState extends State<AnimatedFindingBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // The speed of the animation
    )..repeat(reverse: true); // This makes the animation go back and forth

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gives us the max width to calculate the animation's travel distance.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final segmentWidth = maxWidth * 0.4; // The moving bar is 40% of the total width

        return SizedBox(
          height: 4, // The thickness of the bar
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 1. The background line with a gradient fade
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withAlpha((0.1 * 255).toInt()),
                          Colors.red.withAlpha((0.5 * 255).toInt()),
                          Colors.red.withAlpha((0.1 * 255).toInt()),
                        ],
                      ),
                    ),
                  ),
                  // 2. The moving segment
                  Positioned(
                    left: _animation.value * (maxWidth - segmentWidth),
                    child: Container(
                      width: segmentWidth,
                      height: 4,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}